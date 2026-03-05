# LPM (Layer Pass Manager) for 3ds Max

## Project Overview

LPM v3.00.04 is a MaxScript-based layer pass management system for Autodesk 3ds Max. It provides hierarchical shot/pass organization, multi-renderer support (V-Ray, Scanline), render farm integration (Deadline 10), and Nuke/After Effects export.

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
The rename system uses a **custom TextBox overlay** (NOT native TreeView LabelEdit):
- `editBox` (dotNetControl TextBox) is positioned over the node being edited
- `showEditBox()` disables the TreeView and focuses the TextBox
- `commitEditBox()` saves the edit data back to the node's tag value
- `hideEditBox()` hides the TextBox, re-enables TreeView, returns focus

**Key event flow:**
- Enter/F2 on TreeView → `renameNode()` → `showEditBox()`
- Enter/F2 on editBox → `commitEditBox()` → saves + `hideEditBox()`
- ESC on editBox → `hideEditBox()` (cancel)
- Click outside (lostFocus) → `hideEditBox()` (cancel)

**Known .NET compatibility issue (3dsMax 2024→2026):**
The .NET framework update in 3dsMax 2026 changed how single-line TextBox controls handle the Enter key. Enter is treated as a "dialog key" and consumed before reaching key event handlers unless `AcceptsReturn = true` is set. The fix also uses `keyDown` instead of `keyUp` for more reliable key capture, with `e.SuppressKeyPress = true` to prevent default processing.

A `editJustCompleted` guard flag prevents re-entry into rename mode when the Enter/F2 keyUp propagates to the TreeView after a commit.

### Shot Version Increment/Decrement (Treeview.ms)
- Alt+NumPad8 → increment shot version string
- Alt+NumPad2 → decrement shot version string
- Implemented in `offsetSelectedShot()`, calls `LPM_Fun.offsetVersionString()`
- Only fires when TreeView has focus (not during editBox rename)

### Custom Double-Click Detection (Treeview.ms)
The TreeView uses manual timing-based "slow double-click" detection (600-1100ms delta) in the `MouseUp` handler for rename, separate from the native `MouseDoubleClick` event which opens properties dialogs.

## Renderer Support
- `LPM/renderers/renderer_vray7.20.08.ms` — V-Ray 7.20
- `LPM/renderers/renderer_vray7.00.04.ms` — V-Ray 7.0
- `LPM/renderers/Default_Scanline_Renderer.ms` — Default scanline
- V-Ray 6 support was removed in recent updates

## Version
Current: `3.00.04` (defined in `LPM/VersionNumber.ms`)

## Development Notes
- No automated test framework — manual testing in 3ds Max required
- Icons are BMP files in `LPM/Icons/`, referenced by index in ImageList (order matters!)
- Custom Attributes use uniqueID tuples for version management
- Scene load callbacks registered via `preFileOpenCallback_Add/Remove`
