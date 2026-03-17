# LPM Codebase Review & Improvement Plan

## Context

This is a comprehensive review of the LPM (Layer Pass Manager) v3.00.04 codebase — a MaxScript-based tool for Autodesk 3ds Max providing hierarchical shot/pass organization, multi-renderer support, Deadline 10 farm integration, and Nuke/AE export. The codebase has been developed by multiple authors over time (original author "Neil" + Aaron Dabelow + recent Claude-assisted work). The goal is to catalog all TODOs, issues, and improvement opportunities, then prioritize them into actionable work items.

---

## 1. Explicit TODOs Left by Developers

### Critical / Functional Impact

| # | File : Line | TODO | Notes |
|---|-------------|------|-------|
| 1 | `Render.ms:189` | "Remove these TRY CATCH blocks" | Silent error swallowing in render pipeline — bugs hidden |
| 2 | `Render.ms:973-974` | "finish other implementations here" / "each may be better handled in renderer specific functions" | Incomplete render dispatch architecture |
| 3 | `Render.ms:977, 1311` | "finish the camera hooks" | Camera override hooks not wired up |
| 4 | `Render.ms:1332` | "Put the ONE try catch around this block to restore render on bad execution" | Missing safety net for render failures |
| 5 | `Render.ms:551, 1122` | "soring and restoring vray sun lights is causing errors, disabling override" | Known bug — VRay sun light overrides disabled |
| 6 | `Render.ms:284` | "This is where the V-Ray Light is being modified, needs to be restored" | Lights not being restored after render |
| 7 | `Deadline10.0.ms:80, 1162` | "fix the BATCH Name submission — need different way of updating SMTDSettings" | Batch name submission broken |
| 8 | `Deadline10.0.ms:566` | "Find a better safety net around failed checks" | Weak pre-submit validation |
| 9 | `Deadline10.0.ms:707` | "Fixup to have proper renderer specific handling" | Generic renderer handling in Deadline |
| 10 | `Deadline10.0.ms:916` | "Relink Idiot checks" | Disconnected validation checks |
| 11 | `Functions.ms:1163` | "Fix Filetype Override" | File type override not working |
| 12 | `Functions.ms:1323` | "returning before fully calculating the name... was not working for some reason" | Output path calculation incomplete |
| 13 | `Functions.ms:57` | "This is that noisy section" | Known noisy/problematic code area |

### Renderer TODOs

| # | File : Line | TODO | Notes |
|---|-------------|------|-------|
| 14 | `renderer_vray7.20.08.ms:82` | "Attach the deep hooks" | Deep render output not connected |
| 15 | `renderer_vray7.20.08.ms:231` | "this needs to be made lol" | Function body completely missing |
| 16 | `renderer_vray7.20.08.ms:285` | Bare "TODO:" | Unfinished work |
| 17 | `renderer_vray7.20.08.ms:322-323` | "remove later????" | Uncertain cleanup of post-render actions |
| 18 | `renderer_vray7.00.04.ms` | Same TODOs duplicated from 7.20.08 | Both renderer files share identical issues |
| 19 | `Default_Scanline_Renderer.ms:89` | "Will need some handling around scenes with no camera eventually" | No-camera scenes will crash |

### Operator / Export TODOs

| # | File : Line | TODO | Notes |
|---|-------------|------|-------|
| 20 | `operator_nukeExport.ms:18` | "get the real correct camera" — uses `selection[1]` | Uses selection instead of LPM_Root.renderCamera |
| 21 | `operator_aeExport.ms:18` | Same as above — identical copy | Same bug |
| 22 | `operator_nukeExport.ms:47,59` | Bare "TODO:" | Incomplete implementation |
| 23 | `operator_aeExport.ms:47,59` | Bare "TODO:" | Incomplete implementation |
| 24 | `MAKE_nukeem.ms:12` | "Rework this from absolute paths, come on Neil..." | Hardcoded absolute paths |
| 25 | `NukeAPI.ms:10` | "get FPS from file as well" | Missing FPS parsing |
| 26 | `NukeAPI.ms:89,199,242,287` | Multiple "todo: turn back on" / "save ini" | Disabled features that should be enabled |
| 27 | `Include.ms:31` | "Consider moving these to CA.ms on rootCA" | Hardcoded settings belong in CA |
| 28 | `rcMenu_cameraOverscanOverride.ms:78` | "having issues updating the name" — set to static | Dynamic name generation broken |
| 29 | `rcMenu_renderImage.ms:85` | Same as above | Same bug |
| 30 | `rcMenu_nukeExport.ms:78` | Same as above | Same bug |
| 31 | `rcMenu_aeExport.ms:78` | Same as above | Same bug |
| 32 | `rcMenu_vrayRenderElementsOverride.ms:27` | "try/catch needed because checked events happen when ui is building, need better handling" | UI initialization race condition |

---

## 2. Bugs & Code Smells Found by Review

### Bugs

| # | Issue | File(s) | Details |
|---|-------|---------|---------|
| B1 | **`operator_nukeExport.ms` and `operator_aeExport.ms` are 100% identical** | Both files | They are byte-for-byte copies — nuke export and AE export do the exact same thing, and both use `selection[1]` instead of the render camera |
| B2 | **`operator_nukeExport.ms:42` has trailing `0`** | Line 42 | `"fov * " + ( curFov as string ) )0` — the `0` after the closing paren is a syntax issue |
| B3 | **`operator_nukeExport/aeExport` reference undefined `curClass`** | Line 27 | `case curClass of` — `curClass` is never defined; should be `classof curCam` |
| B4 | **`operator_cameraOverscan.ms` swaps X/Y** | Lines 56-57, 63-64, 84-85 | `resXOriginal = renderHeight` and `resYOriginal = renderWidth` — X mapped to Height, Y mapped to Width (should be reversed) |
| B5 | **`operator_renderImage.ms` same X/Y swap** | Same pattern | Copy-paste of cameraOverscan bug |
| B6 | **Typo in `Render.ms:1462`** | | "sucsussfully" should be "successfully" |
| B7 | **Typo in `Render.ms:1418`** | | "occured" should be "occurred" |
| B8 | **VRay vrimg2exr path hardcoded to 3ds Max 2014** | `CA.ms:24`, `Render.ms:1297` | `C:\Program Files\Chaos Group\V-Ray\3dsmax 2014 for x64\tools\vrimg2exr.exe` |
| B9 | **Deadline path hardcoded** | `Include.ms:32` | `N:\DeadlineRepository10` — studio-specific path |
| B10 | **mental_ray_renderer references** | `Functions.ms:308,386`, `renderPropsEdit.ms:41`, `renderPropsAdd.ms:37` | Mental Ray was removed from 3ds Max years ago |
| B11 | **`Render.ms:1305`** | "test this" TODO | Untested code in production |
| B12 | **`lightSetProps` global not prefixed** | `Globals.ms:19` | Developer comment: "gave up trying to fix" |

### Not-Implemented Features (UI stubs exist)

| # | Feature | File : Line |
|---|---------|-------------|
| N1 | TyPreview render mode | Removed from dropdown (8b6c34b) — see §7 Roadmap |
| N2 | Nuke Export from render mode dropdown | Removed from dropdown (8b6c34b) — see §7 Roadmap |
| N3 | AE Export from render mode dropdown | Removed from dropdown (8b6c34b) — see §7 Roadmap |
| N4 | "Feature not ready for production" | `Treeview.ms:1138` — `EditNukeExport()` / `EditAeExport()` stubs remain |

---

## 3. Code Quality & Architecture Issues

### Duplicated Code (DRY violations)

| # | Issue | Files |
|---|-------|-------|
| D1 | `operator_nukeExport.ms` and `operator_aeExport.ms` are **identical** | Both 83 lines |
| D2 | `operator_cameraOverscan.ms` and `operator_renderImage.ms` are **near-identical** (just struct/function name differences) | 109 vs 110 lines |
| D3 | `renderer_vray7.00.04.ms` and `renderer_vray7.20.08.ms` share ~90% identical code | 372 vs 383 lines, diff shows only render element handling differs |
| D4 | `rcMenu_cameraOverscanOverride.ms`, `rcMenu_nukeExport.ms`, `rcMenu_aeExport.ms`, `rcMenu_renderImage.ms` share identical TODO comments and similar structure | 4 files |
| D5 | Render preset save/load logic duplicated in `Functions.ms` | Lines 306-372 and 385-434 — same pattern twice |

### Silent Error Swallowing

Over **60+ instances** of `try(...)catch()` with empty catch blocks across the codebase. While some are intentional (dialog cleanup), many hide real errors:
- `Render.ms` — post-render cleanup errors silenced
- `Treeview.ms` — node operations errors silenced
- Renderer files — metadata collection errors silenced
- `rcMenus.ms` — various action errors silenced

### Global State

48 global variables defined in `Globals.ms`. Developer sentiment captured in the opening comment: *"Dear whoever reads this, I inherited this pile of globals, and wish it was not this way, it keeps me up at night."*

Key concerns:
- `LPM_render` and `LPM_Render` are both defined (case collision in MaxScript)
- `lightSetProps` lacks the `LPM_` prefix
- Globals used to pass data between render dispatch phases

### Renderer Dispatch Brittleness

`renderer_dispatch.ms` matches renderers by exact string comparison of `renderers.current as string`. This means:
- Any VRay point-release or hotfix requires a new entry
- Only 3 specific renderer version strings are supported
- Default case shows an error messagebox with no fallback

### Hardcoded Values

- Deadline repo path: `N:\DeadlineRepository10` (`Include.ms:32`)
- vrimg2exr path: `C:\...\3dsmax 2014 for x64\tools\vrimg2exr.exe` (`CA.ms:24`)
- Icon file paths assume specific directory structure
- Preview sizes are hardcoded dropdown items: `#("10","25","50","75","100","150","200")`

### Debug Print Statements Left In

Multiple `print` statements in operator files that appear to be debug output left from development:
- `operator_cameraOverscan.ms:35,41,45,58-60,66-67,90,101`
- `operator_renderImage.ms` — same pattern
- `operator_nukeExport/aeExport` — same pattern

---

## 4. Recommended Priority Tiers

### Tier 1: Bugs & Correctness (Fix Now)
1. **B3** — `curClass` undefined in nukeExport/aeExport (will crash)
2. **B2** — Trailing `0` syntax issue in nukeExport/aeExport
3. **B4/B5** — X/Y resolution swap in cameraOverscan and renderImage operators
4. **B1/D1** — nukeExport and aeExport are identical copies (should they differ?)
5. **B8** — vrimg2exr hardcoded to 3ds Max 2014 path
6. **B10** — Dead mental_ray_renderer references

### Tier 2: Incomplete Features (Finish or Remove)
7. **#20-21** — Operators using `selection[1]` instead of render camera
8. **#14-16** — Missing VRay deep hooks and empty function bodies
9. **#7** — Deadline batch name submission
10. **N1-N3** — Remove or implement TyPreview/Nuke/AE render modes

### Tier 3: Code Quality (Reduce Tech Debt)
11. **D1-D4** — Consolidate duplicated operator/renderer code
12. **Silent catch blocks** — Add logging to critical catch blocks
13. **Debug prints** — Remove or gate behind a debug flag
14. **B6-B7** — Fix typos in user-facing messages
15. **B9** — Make Deadline path configurable (not hardcoded)
16. **D5** — DRY up render preset save/load in Functions.ms
17. **Renderer dispatch** — Make version matching more flexible (pattern/prefix match)

### Tier 4: Architecture (Longer Term)
18. Reduce global variable count — move toward struct-based encapsulation
19. Establish a consistent error handling strategy
20. Create a base operator class to DRY up the operator pattern
21. Create a base renderer class to DRY up VRay version forks

---

## 5. Proposed Work Items

Based on the above, here are concrete work items we can tackle:

### Quick Wins (can do immediately)
- [x] Fix `curClass` → `classof curCam` in nukeExport/aeExport *(done — 4d966e1)*
- [x] Fix trailing `0` syntax error in nukeExport/aeExport *(done — 4d966e1)*
- [x] Fix X/Y resolution swap in cameraOverscan and renderImage *(done — 4d966e1)*
- [x] Fix typos in user-facing messages ("sucsussfully", "occured", "soring") *(done — 4d966e1, 7523e19)*
- [x] Remove mental_ray_renderer dead code paths *(done — 4d966e1)*
- [x] Update vrimg2exr default path to modern VRay *(done — 4d966e1)*
- [x] Remove leftover debug `print` statements *(done — 4d966e1)*
- [x] Remove vestigial hardcoded Deadline repo path from Include.ms *(done — 8b6c34b)*
- [x] Add logging to silent catch blocks in Render.ms light restoration *(done — 8b6c34b)*
- [x] Remove unimplemented render mode stubs from processor dropdown *(done — 8b6c34b)*

### Medium Effort
- [ ] Consolidate nukeExport + aeExport into shared base (they're identical)
- [ ] Consolidate cameraOverscan + renderImage into shared base
- [ ] Extract shared VRay renderer code into a base, with version-specific overrides
- [x] Make Deadline repository path configurable via INI/environment *(already was — vestigial hardcoded line removed in 8b6c34b)*
- [x] Add logging to critical `try()catch()` blocks *(light restoration phase — 8b6c34b)*
- [x] Remove unimplemented render mode stubs from processor dropdown *(done — 8b6c34b; see §7 Roadmap)*

### Larger Effort
- [ ] Redesign renderer dispatch for flexible version matching *(already uses wildcard `matchPattern` — may not need changes)*
- [ ] Finish camera hooks (Render.ms TODO items)
- [ ] Complete the render element handling architecture
- [x] Address Deadline batch name submission *(done — 25cdb89)*

---

## 6. Verification

Since there's no automated test framework, verification would be:
- Manual testing in 3ds Max after each change
- Ensure LPM loads without errors (`Include.ms` runs cleanly)
- Test render preview, local render, and Deadline submission paths
- Test with VRay 7.0, VRay 7.20, and Scanline renderers
- Verify operator pre/post render hooks fire and restore state correctly

---

## 7. Roadmap — Future Render Modes

These three render modes were removed from the processor dropdown (commit 8b6c34b) because they showed "not implemented" messageboxes. They should be re-added to the dropdown once implemented.

### TyPreview
- **Purpose:** Render via tyFlow's TyPreview renderer
- **Status:** No implementation exists — needs full build-out
- **Dropdown entry to restore:** `"Render - TyPreview"`

### Nuke Export
- **Purpose:** Export scene/camera data for Nuke compositing
- **Status:** Stub operator exists (`operator_nukeExport.ms`), `EditNukeExport()` function stub in `Treeview.ms`
- **Related files:** `NukeAPI.ms` (Nuke integration API), `MAKE_nukeem.ms` (hardcoded paths — TODO #24)
- **Related TODOs:** #20 (use `LPM_Root.renderCamera` not `selection[1]`), #22 (bare TODOs), #24-26 (NukeAPI incomplete)
- **Dropdown entry to restore:** `"Export - Nuke Scene"`

### After Effects Export
- **Purpose:** Export camera/scene data for After Effects
- **Status:** Stub operator exists (`operator_aeExport.ms`), `EditAeExport()` function stub in `Treeview.ms`
- **Related TODOs:** #21 (use `LPM_Root.renderCamera`), #23 (bare TODOs)
- **Dropdown entry to restore:** `"Export - After Effects Camera"`

---

## Implementation Plan — Tier 1: Bug Fixes

We will fix these in order, commit, and push to `claude/review-lpm-codebase-i9CUM`.

**Note:** nukeExport and aeExport will remain separate files (they will diverge as features are built out), but both get the same bug fixes applied independently.

### Fix 1: `curClass` → `classof curCam` in nukeExport and aeExport
- **Files:** `LPM/operator_nukeExport.ms:27`, `LPM/operator_aeExport.ms:27`
- **Change:** `case curClass of` → `case (classof curCam) of`
- This is an undefined variable that will crash the operator

### Fix 2: Trailing `0` syntax error in nukeExport and aeExport
- **Files:** `LPM/operator_nukeExport.ms:42`, `LPM/operator_aeExport.ms:42`
- **Change:** Remove the trailing `0` after `)` on the Physical camera paramWire line

### Fix 3: X/Y resolution swap in cameraOverscan and renderImage
- **Files:** `LPM/operator_cameraOverscan.ms:56-57,63-64,84-85`, `LPM/operator_renderImage.ms:56-57,63-64,84-85`
- **Change:** Swap `renderHeight`↔`renderWidth` assignments so X maps to Width and Y maps to Height
- `resXOriginal = renderWidth` (not renderHeight), `resYOriginal = renderHeight` (not renderWidth)

### Fix 4: Typos in user-facing messages
- **File:** `LPM/Render.ms:1462` — "sucsussfully" → "successfully"
- **File:** `LPM/Render.ms:1418` — "occured" → "occurred"
- **File:** `LPM/Render.ms:551,1122` — "soring" → "storing" (in comments)

### Fix 5: Remove dead mental_ray_renderer code paths
- **Files:** `LPM/Functions.ms:308,386`, `LPM/renderPropsEdit.ms:41`, `LPM/renderPropsAdd.ms:37`
- **Change:** Remove `mental_ray_renderer:` case branches (Mental Ray removed from 3ds Max years ago)

### Fix 6: Update vrimg2exr default path
- **Files:** `LPM/CA.ms:24`, `LPM/Render.ms:1297`
- **Change:** Update from 3ds Max 2014 path to a more generic/modern default, or empty string with a note

### Fix 7: Remove leftover debug print statements from operators
- **Files:** `LPM/operator_cameraOverscan.ms`, `LPM/operator_renderImage.ms`, `LPM/operator_nukeExport.ms`, `LPM/operator_aeExport.ms`
- **Change:** Remove `print "Free"`, `print "Target"`, `print "PHYS"`, `print "---original res----"`, `print renderHeight`, `print renderWidth`, `print "---overscan res----"`, etc.

### Verification
- Ensure all .ms files parse without syntax errors (no unmatched parens, no stray characters)
- Review each change for correctness against the surrounding code logic
- Commit with clear message describing all fixes
- Push to branch
