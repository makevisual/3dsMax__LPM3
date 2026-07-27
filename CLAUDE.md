# LPM (Layer Pass Manager) for 3ds Max

## Project Overview

LPM v3.01.00 is a MaxScript-based layer pass management system for Autodesk 3ds Max. It provides hierarchical shot/pass organization, multi-renderer support (V-Ray, Scanline), render farm integration (Deadline 10), and Nuke/After Effects export.

## Key Architecture

### Entry Points
- `LPM/Include.ms` — Master loader script, initializes all modules
- `LPM/Include.mcr` — Macroscript for toolbar buttons
- `LPM/Treeview.ms` — Main UI rollout (`LPM_treeview_rollout`) with TreeView hierarchy

### Core Files
- `LPM/Functions.ms` — `LPM_Fun_Struct` core utility functions
- `LPM/Render.ms` — `LPM_RenderAPI` rendering engine
- `LPM/CA.ms` — Custom Attribute definitions (data model persistence)
- `LPM/Globals.ms` — Global variables and namespace definitions
- `LPM/rcMenus.ms` — Right-click context menus

### Data Model
LPM stores persistent data using MaxScript Custom Attributes (CA) attached to scene objects:
- `rootCA` — Master settings (render type, paths, deadline config)
- `passCA` — Per-pass configuration (output paths, VRay settings)
- `LPM_shotCA` — Shot-level settings
- `objectSetCA` / `lightSetCA` — Dynamic object/light grouping
- And ~10 more CAs for operators, render elements, etc.

### .NET Controls (dotNetControl)
The UI uses `System.Windows.Forms` controls hosted in MaxScript via `dotNetControl`:
- **TreeView** — Main shot/pass hierarchy (`tv` in Treeview.ms)
- **TextBox** — Inline rename overlay (`editBox` in Treeview.ms), path inputs
- **ListView** — Multi-selection lists (modifiers, layers, render elements)
- **ImageList** — Icons for TreeView nodes

### Global References
- `LPM_Root` — Scene root object with custom attributes
- `LPM_Fun` — Functions struct instance
- `LPM_renderAPI` — Render system instance
- `LPM_activePass` — Currently selected pass
- `LPM_Operators` — Operator manager
- `LPM_treeview_rollout` — Main UI rollout instance

## Critical Implementation Details

### TreeView Inline Rename System (Treeview.ms)
The rename system uses **native TreeView LabelEdit** (`tv.LabelEdit = true`) with zero custom state flags:
- `renameNode(iNode)` calls `iNode.BeginEdit()` (used by right-click context menus)
- `BeforeLabelEdit` blocks root nodes (level 0) only — all other nodes are renameable
- `AfterLabelEdit` commits the new name to the node's tag value and calls `updateTV()`

**Rename triggers:**
- F2 on TreeView → native LabelEdit behavior
- Slow double-click → native LabelEdit behavior
- Right-click context menu → Rename → `renameNode()` via `rcMenus.ms`
- Enter commits an active edit, Escape cancels

**3dsMax 2026 .NET Core 8 compatibility:**
`PreviewKeyDown` sets `e.IsInputKey = true` for Enter and Escape, then explicitly calls `EndEdit(false)` (commit) or `EndEdit(true)` (cancel) using `tv.selectedNode.IsEditing` to detect active edits. This is required because the .NET Core 8 hosting layer consumes these keys as dialog keys before they reach the native edit control.

### Shot Version Increment/Decrement (Treeview.ms)
- Alt+NumPad8 → increment shot version string
- Alt+NumPad2 → decrement shot version string
- Implemented in `offsetSelectedShot()`, calls `LPM_Fun.offsetVersionString()`
- Only fires when TreeView has focus (not during label edit)

## Renderer Support
- `LPM/renderers/renderer_vray7.20.08.ms` — V-Ray 7.20
- `LPM/renderers/renderer_vray7.00.04.ms` — V-Ray 7.0
- `LPM/renderers/Default_Scanline_Renderer.ms` — Default scanline
- V-Ray 6 support was removed in recent updates

## Preview / TyPreview Integration
The "Preview - TyPreview" processor exports a viewport capture (via tyFlow's
tyPreview utility) instead of running a renderer, while reusing the local-render
scene setup.

- **Processor dropdown** (`Treeview.ms`): `processorList` includes
  `"Preview - TyPreview"`; the `btn_execute` branch gates on `LPM_TyFlowInstalled`
  then calls `LPM_Fun.tyPreviewSubmit()` (Functions.ms), which sets
  `LPM_PreviewBackend` and runs `renderSubmit #tyPreview`.
- **Reuse via dispatch seam, not a parallel pipeline:** `#tyPreview` flows
  through the normal `renderSubmit` → `LPM_renderPass` path. `fnPreRenderAction`
  takes a `previewExport:` flag that skips renderer-only work (Deadline operators,
  render-element output assignment, `renderer_dispatch.ms`) while still applying
  visibility, camera, frame range, resolution, and script operators, and building
  the shot output path into `LPM_Root.fullOutputPath`. `fnPostRenderAction`
  restores normally.
- **Preview backend dispatch** mirrors `renderer_dispatch.ms`: `LPM_renderPass`'s
  `#tyPreview` branch fileins `preview_dispatch.ms`, which routes by
  `LPM_PreviewBackend` to a self-contained backend in `LPM/previews/`
  (`preview_tyPreview.ms` now; future `preview_viewport.ms` for the planned
  "Preview - 3dsMax Viewport" option — add one branch + one file, nothing else).
- **TyPreview backend** (`previews/preview_tyPreview.ms`) translates the applied
  scene state into a single `tyPreview()` call. LPM authority overrides
  tyPreview's persisted settings: `output_filename` (shot output), `frameRange_list`
  / `frameRange_nth`, `camera_node`, `resolution_width`/`height`.
- **TyPreview operator** (property-based, modeled on Camera Overscan; child of the
  shot node): CA `tyPreviewPropsCA` (`CA.ms`), dialog
  `rcMenus/rcMenu_tyPreviewOverride.ms`, wired through the standard operator touch
  points (see `docs/ADDING_AN_OPERATOR.md`). Options: `viewportSource` (1 = active
  viewport, 2 = tyPreview per-camera settings) decides whether the backend passes
  `appearance_*`/`camera_node`; `outputFormat` (`exr`/`png`/`tif`/`jpg`/`mp4`,
  default `exr`) sets the tyPreview `output_filename` extension and `output_type`
  (mp4 = 0/video, others = 1/image sequence). The backend auto-enables
  `appearance_alpha` for alpha-capable formats (exr/png/tif). `forceDotDelimiter`
  (boolean, default **true**) controls the frame-delimiter rename below.
- **Frame delimiter (post-export rename — HACKFIX):** for image sequences,
  `tyPreview()` itself writes frames as `<name>_####.<ext>` — tyFlow owns that
  underscore and exposes **no** argument to change it (LPM only ever supplies a
  bare `<name>.<ext>` as `output_filename`). LPM's house convention is a dot
  (`<name>.####.<ext>`, cf. `output_paths.ms`), so the tyPreview backend **renames
  the frames on disk after the (synchronous) export**, swapping the underscore
  before the trailing digits for a dot. Caveats — this is deliberately fragile:
  - It is a **post-process on disk** that depends on tyFlow's current naming
    scheme; if tyFlow changes how it names sequence frames this silently stops
    matching (guarded to only rename `<base>_<all-digits>.<ext>`).
  - Sequences only (`output_type:1`); **mp4 is never touched** (single file, no
    frame token).
  - Gated by the operator's `forceDotDelimiter` CA field (default on; also defaults
    on when no tyPreview operator exists on the shot).
  - **All-or-nothing per pass.** These files live on the network and may be
    **locked by another machine**. Before deleting/renaming, a non-destructive lock
    test (`System.IO.FileStream` … `FileShare.None`, opened and closed — no bytes
    read) checks every pre-existing dot target; if **any** is locked the whole
    rename is aborted (nothing deleted) so a previously-good sequence is never
    partially destroyed. Fresh frames are left as `_####` files. Locked shots are
    collected in the global `LPM_PreviewLockedShots`, and `tyPreviewSubmit`
    (Functions.ms) then prompts **once** to increment the shot's output version
    (via `offsetVersionString`) so the next preview writes a clean sequence. Re-run
    is manual.
- **Camera-handling pitfalls (read before building the Camera Overscan operator — it duplicates the
  render camera the same way; see `previews/preview_tyPreview.ms` for the working implementation):**
  - **`LPM_Root.renderCamera` is frequently `undefined` during the render pass.** Setups that drive
    the camera through commonProps (`cp._Camera` → `viewport.setCamera`, `Render.ms:85`) set the
    *active viewport* but never populate the global `LPM_Root.renderCamera`. Resolve the live camera
    from `viewport.getCamera()` first, with `LPM_Root.renderCamera` only as a fallback. (This made the
    tyPreview Mode-2 branch — gated on a valid camera — silently fall through to default appearance.)
  - **tyPreview/viewport-capture appearance is stored per-camera, internally, with no MAXScript
    getter; passing `appearance_*` overrides PERSISTS onto the previewed camera.** To apply
    temporary/override appearance without destroying the user's saved per-camera settings, preview
    from a **throwaway `copy` of the camera** (`camera_node:tmpCam`) and `delete` it afterward.
  - **Copying a target camera also copies its target node** — capture `tmpCam.target` and delete it
    too; guard create/delete with `isValidNode` + `try()` so a failure still produces output.
  - **tyPreview captures the ACTIVE VIEWPORT** — `viewport.setCamera <cam>` + `forceCompleteRedraw()`
    right before the call so the intended camera/Nitrous state is what gets captured.

## Version
Current: `3.01.00` (defined in `LPM/VersionNumber.ms`)

## Development Notes
- No automated test framework — manual testing in 3ds Max required
- Icons are BMP files in `LPM/Icons/`, referenced by index in ImageList (order matters!)
- Custom Attributes use uniqueID tuples for version management
- Scene load callbacks registered via `preFileOpenCallback_Add/Remove`
