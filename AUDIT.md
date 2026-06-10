# LPM Codebase Audit

**Scope:** Full read-only audit of the LPM (Layer Pass Manager) MaxScript
codebase (`LPM/**/*.ms`, `*.mcr`, ~50 files, ~17k lines).
**Goal:** deduplication opportunities, inconsistencies, mismatches, and bugs.
**Method:** three parallel exploration passes followed by line-by-line
verification of every high-value finding against the source.

> **Important — MaxScript is case-insensitive.** Identifiers that differ only by
> letter case refer to the *same* variable/function. Several "typo bugs" that a
> naive scan flags are therefore **harmless**. They are listed separately under
> [False positives](#false-positives) so they are not mistaken for real defects.
> Everything in the "Confirmed" sections involves genuinely different identifiers
> or genuinely wrong logic and was verified by reading the code.

## Severity legend
- **CRITICAL** — user-facing failure / runtime error on a normal action.
- **HIGH** — wrong behavior, silent data corruption, or a feature that never works.
- **MEDIUM** — wrong behavior in an edge case, or undefined-value usage.
- **LOW** — cosmetic, docs, or no behavioral effect.

---

## Confirmed bugs

### B1 — Nuke/AE Export right-click menus are undefined  · CRITICAL
**Files:** `LPM/rcMenus/rcMenu_aeExport.ms`, `LPM/rcMenus/rcMenu_nukeExport.ms`,
caller `LPM/Treeview.ms:2122-2123`

`rcMenu_aeExport.ms` and `rcMenu_nukeExport.ms` are verbatim copies of
`rcMenu_cameraOverscanOverride.ms`. All three files define the *same* names:

```maxscript
-- line 1 of all THREE files:
rollout cameraOverscanPropsRoll "Camera Overscan Override 1.0" width:225 height:130
-- line 103 of all THREE files:
rcMenu rc_CameraOverscanPropsMenu
```

But the TreeView right-click handler invokes export-specific menu names that are
**never defined anywhere in the repo**:

```maxscript
-- Treeview.ms:2122-2123
"nukeExport":popUpMenu rc_nukeExportPropsMenu
"aeExport":  popUpMenu rc_aeExportPropsMenu
```

**Impact:** right-clicking a Nuke Export or After Effects Export node calls
`popUpMenu` on an undefined variable → runtime error; the export context menus
are unreachable.
**Fix:** rewrite the two export rcMenu files so each defines its own
`rollout …PropsRoll` + `rcMenu rc_nukeExportPropsMenu` / `rc_aeExportPropsMenu`,
backed by the already-defined `nukeExportPropsCA` / `aeExportPropsCA`
(`CA.ms:231,248`). Until then those nodes have no working menu.

### B2 — `__DeleteAll` never deletes (core CA write path)  · HIGH
**File:** `LPM/CA.ms:508-525`

```maxscript
fn __DeleteAll IKey=
(
    IKey=toLower IKey
    i=1
    while(i<Keys.count) do            -- (a) off-by-one: '<' skips the last key
    (
        if(Keys[i]==LKey) then        -- (b) 'LKey' is undefined; param is 'IKey'
        ( ... deleteItem ... )
        else i+=1
    )
)
```

`LKey` is a genuinely different (undefined) identifier from the parameter `IKey`,
so the comparison is always false and nothing is ever deleted. `__DeleteAll` is
the delete-before-add step inside `setValue` (`CA.ms:594`) and `setArray`
(`CA.ms:603`), which are core CA write operations → keys are never cleared,
allowing duplicate/stale entries to accumulate.
**Fix:** `LKey` → `IKey`; also change `while(i<Keys.count)` to `<=` so the final
key is checked.

### B3 — Idiot-check uses assignment instead of comparison  · HIGH
**File:** `LPM/plugins/Deadline10.0.ms:909`

```maxscript
if LPM_IdiotChecksEnabled = False        -- '=' assigns; should be '=='
then ( idiotCheck_skip() )
else ( idiotCheck_run() )
```

`=` assigns `False` to the global (returning `False`), so the branch is constant
**and** the user's toggle — set in `Treeview.ms:1364/1372` — is silently
overwritten on every run. Idiot checks therefore always run and the preference
is destroyed.
**Fix:** `=` → `==`.

### B4 — Material-ID render elements are left misconfigured  · HIGH
**File:** `LPM/Functions.ms:1619-1627`

```maxscript
if isMatID then (
    REManager.AddRenderElement (CMasking_Mask elementname:("am_mID_" + (i as String)))
    heElement = REManager.GetRenderElement (REcount+i-1)   -- assigns 'heElement' (typo)
    theElement.enabled = true                              -- but configures 'theElement'
    theElement.mode = 0
    theElement.materialMonoOn = true
    theElement.materialMono = TmpNumbersArr[i]
)
else (
    REManager.AddRenderElement (CMasking_Mask elementname:("am_oID_" + (i as String)))
    theElement = REManager.GetRenderElement (REcount+i-1)  -- objID branch is correct
    theElement.enabled = true ...
)
```

In the matID branch the freshly-created element is stored in `heElement`
(different identifier), while the configuration writes to `theElement` — which is
either undefined or a stale element from a prior iteration. Material-ID masks are
left disabled / pointed at the wrong element.
**Fix:** `heElement` → `theElement`.

### B5 — `offsetVersionString` drops the name prefix on multi-`_v` names  · MEDIUM
**File:** `LPM/Functions.ms:606-615`

```maxscript
fullString = ""
for i in 1 to ( stringParts.count - 1 ) do
(
    fullString = stringParts[i]   -- overwrites each iteration; should append
    fullString += "_v"
)
fullString += endPartstr
```

`fullString = stringParts[i]` overwrites the accumulator, so for a name split
into 3+ parts by `_v` only the last fragment survives (e.g.
`Shot_v1_v001` → `1_v002`, losing `Shot`). The common single-`_v` case happens
to work, which is why it has gone unnoticed.
**Fix:** `fullString = stringParts[i]` → `fullString += stringParts[i]`.
*(Side note: padding via `endPartInt += 2000; substring … 2 4` caps versions at 3
digits / 0-999 — acceptable but worth knowing.)*

### B6 — Undefined `FrontColor` when creating a TreeView node  · MEDIUM
**File:** `LPM/Treeview.ms:371`

```maxscript
newNode.ForeColor = FrontColor          -- 'FrontColor' is undefined
```

Every other foreground assignment (~40 sites in `Treeview.ms`, plus
`Functions.ms:2022`) uses the global `LPM_FontColor` (`Globals.ms:33`,
initialized `Treeview.ms:76`). `FrontColor` is defined nowhere.
**Fix:** `FrontColor` → `LPM_FontColor`.

---

## Duplicate definitions (second silently overrides the first)

In MaxScript a later `fn` definition in the same scope replaces the earlier one,
so the first becomes dead — and, when bodies differ, misleading.

### D1 — `createRenderImageProps` defined twice, **divergent**  · HIGH
**File:** `LPM/Functions.ms:781` and `:885`

```maxscript
-- :781 (dead) — sets nothing extra, elementOverride commented out
fn createRenderImageProps theName= ( cp=LPM_Fun.createNode theName "renderImage"
    cp.active = true /* cp.elementOverride / cp.activeElement commented */  cp )

-- :885 (effective) — also sets renderEnabled
fn createRenderImageProps theName= ( cp=LPM_Fun.createNode theName "renderImage"
    cp.active = true   cp.renderEnabled = true   cp )
```

Because the bodies differ, this is not just clutter — the dead `:781` version is
a maintenance trap. Keep one (the `:885` behavior appears intended).

### D2 — `generateRenderImageName` defined twice (identical)  · LOW
**File:** `LPM/Functions.ms:1310` and `:1335` — both return `"Render Image"`; the
second carries an incorrect `-- Dabelow nukeExport` comment. Delete one.

### D3 — `replaceByString` defined twice (identical)  · LOW
**File:** `LPM/Functions.ms:1012` and `:1439` — same struct, identical body.
Delete one.

---

## Dead code, incomplete features, stray files

### S1 — Stale backup files committed to git  · MEDIUM
`LPM/Render.ms.backup` and `LPM/Treeview.ms.backup` are tracked and diverge from
the live files (the Treeview backup still has `D:\\tmp.exr` hardcoded output and
the `LPM_FUn` typo). Remove from the repo — they are accidental commits.

### S2 — Unused V-Ray 7.00.04 renderer (near-exact duplicate)  · MEDIUM
**Files:** `LPM/renderer_dispatch.ms:8-9`, `LPM/renderers/renderer_vray7.00.04.ms`

The dispatcher loads only `renderer_vray7.20.08.ms` for any `V_Ray_7*`:

```maxscript
else if matchPattern curRenderer pattern:"V_Ray_7*"
then ( filein ( LPM_Dir + @"renderers\" + "renderer_vray7.20.08.ms" ) )
```

`renderer_vray7.00.04.ms` is never loaded and differs from 7.20.08 by exactly
**one blank line** (line 221). Either delete it or, if real 7.0 support is
intended, add version detection. See refactor **R1**.

### S3 — `Vray7_Override_PostRender()` called but never defined  · LOW
`renderer_vray7.20.08.ms:342` / `renderer_vray7.00.04.ms:343`:

```maxscript
try( Vray7_Override_PostRender() )catch() -- TODO: remove later????
```

No definition exists anywhere; the `try…catch()` swallows the error. Dead call —
remove.

### S4 — Unreachable code after early `return`  · LOW
`LPM/Functions.ms:1318-1330` `generateCameraOverscanName` returns the bare label
before building the FOV/resolution suffix (commented `TODO: … not working for
some reason`). The suffix code below is dead; the overscan node name never shows
its overrides.

### S5 — Stub / missing settings loaders  · LOW (known-incomplete)
`loadCameraOverscanSettings` (`Functions.ms:861`) has a fully commented-out body,
and there are no `loadNukeExportSettings` / `loadAeExportSettings` despite their
`create…Props` and CA counterparts existing. Consistent with the explicit
"placeholder" headers in `operator_aeExport.ms` / `operator_nukeExport.ms`, so
this is tracked as planned-but-unimplemented rather than a regression.

---

## Inconsistencies & documentation

### C1 — Version mismatch between docs and code  · LOW
`CLAUDE.md` states version `3.00.04`; `LPM/VersionNumber.ms` is `3.00.09`
(`LPM_VersionNumber = "3.00.09"`). Update the docs.

### C2 — Metadata key typos `Lenth` → `Length`  · LOW
`renderer_vray7.20.08.ms:292-293` / `renderer_vray7.00.04.ms:293-294`:

```maxscript
"… MAKE3dsMaxMetadata_cameraFocalLenthMM = "        + (… focal_length_mm …)
"… MAKE3dsMaxMetadata_cameraShutterLenthFrames = "  + (… shutter_length_frames …)
```

These strings are written into EXR metadata. No in-repo consumer reads them, but
any downstream Nuke/AE tooling expecting `…FocalLengthMM` / `…ShutterLengthFrames`
will mismatch. Fix only after confirming no pipeline already depends on the
misspelled keys.

### C3 — Case-only inconsistencies (cosmetic)  · LOW
`LPM_fun`/`LPM_Fun`, `getallchildren`/`getAllChildren`, `theSHot`/`theShot`,
`LPM_FUn` (e.g. `passSettingsRO.ms:49`, `IncludePassesRO.ms:26`). Harmless in
MaxScript; optional tidy for readability.

---

## Refactor opportunities (deduplication)

### R1 — Consolidate the V-Ray renderer files
The two `renderer_vray7.*.ms` files differ by one blank line. Collapse to a
single `renderer_vray7.ms` and load it from `renderer_dispatch.ms` for `V_Ray_7*`
(removes ~400 duplicated lines and the divergence risk that produced S2/S3).

### R2 — Generalize the `load<X>Settings` family
`loadRenderImageSettings`, `loadVrayRenderElementsSettings`, etc. all follow
`if isPreviewMode then return false; LPM_SMTDSettings.<field> = cp.<field>`. A
single data-driven loader keyed by node type (a field list per CA) removes the
copy-paste and the class of bug seen in S5 (forgotten loaders).

### R3 — Templatize the rcMenu scaffold
The `rcMenus/` files repeat the same `rollout …PropsRoll` + `rc_*PropsMenu`
(copy-props / edit-props / remove-props) structure. A generator parameterized by
node type would have prevented B1 entirely. The repeated `fnUpdateUI`
(`rcMenus.ms:647,723,793`) blocks are part of the same pattern.

### R4 — Unify light-property application in `Render.ms`
The V-Ray (~197-219) and Standard (~276-300) light-apply branches share
structure that can be factored into one helper with a per-renderer field map.

### R5 — Replace silent `try(…)catch()` blocks
Numerous empty-catch blocks (e.g. `Functions.ms` dialog teardown,
`renderer_vray*.ms:342`) swallow all errors. Where failure should be visible,
log via `format` in the catch; where genuinely best-effort, a short comment
documents intent.

---

## False positives
Flagged by automated scanning but **not** bugs, because MaxScript identifiers are
case-insensitive (these pairs are the same variable):
- `LPM/plugins/maxFileSubmit.ms:64,66` — `theFilename` vs `theFileName`. The full
  path is assigned then saved; works correctly.
- `LPM/Render.ms` — `psCp` vs `psCP` (8 sites). Same variable.
- `LPM/CA.ms:535` — `Ival` vs `IVal`. Same variable.
- `LPM/Functions.ms` — `AAmin`/`AAmax` vs CA `aaMin`/`aaMax`. Same property.
- `LPM/rcMenus.ms:1963,1985,2007` — `theSHot` vs `theShot`. Same variable.
- `operator_renderImage.ms` / `operator_cameraOverscan.ms` — `newCamAnimhanlde`
  is a misspelling but used consistently, so it resolves fine.

---

## Suggested fix order
1. **B1** (export menus throw) and **B3** (idiot-check) — user-visible.
2. **B2** (CA delete) and **B4** (matID elements) — silent correctness.
3. **B6**, **B5**, **D1** — undefined value / dead divergent code.
4. **S1** (remove backups), **D2/D3/S2/S3/S4** — cleanup.
5. **R1–R5** — refactors, ideally with manual 3ds Max verification (no automated
   test framework exists per `CLAUDE.md`).

## Verification notes
No automated tests exist; changes require manual testing in 3ds Max. Minimum
manual checks after any fix: right-click Nuke/AE Export nodes (menu appears);
toggle idiot-checks and submit to Deadline; create a matID mask render element
(it is enabled); rename a shot whose name has multiple `_v` segments and bump the
version.
