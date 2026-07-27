-- TyPreview preview backend (self-contained).
--
-- Invoked via preview_dispatch.ms from LPM_renderPass when the "Preview - TyPreview"
-- processor runs. By this point fnPreRenderAction has already applied the shot/pass scene
-- state: object/light visibility, the active viewport camera, frame range and resolution
-- (3ds Max system globals rendStart/rendEnd/renderWidth/... are set), and script operators.
--
-- This file only translates that state into a single tyPreview() export call, applying LPM's
-- authority over tyPreview's persisted settings: output path & filename, frame range, active
-- camera, and resolution. tyPreview's own appearance settings (Mode/Style/lights/AA/...) are
-- left to tyPreview unless the operator requests the active viewport.
--
-- Inputs (globals, set by LPM_renderPass before filein):
--   LPM_RenderDispatchThePass / LPM_RenderDispatchTheShot
--   LPM_Root.fullOutputPath  (built by getPassPath during fnPreRenderAction)
--   LPM_Root.renderCamera
-- See https://docs.tyflow.com/tyflow_utilities/tyPreview/ for the tyPreview() argument list.

(
	local thePass = LPM_RenderDispatchThePass
	local theShot = LPM_RenderDispatchTheShot

	-- TyPreview operator options (child of the shot). viewportSource: 1 = active viewport, 2 = tyPreview.
	local useTyPreviewSettings = false
	local outFormat = "exr"
	local disableContainerNesting = true   -- mp4 only; defaults on (matches the operator's default).
	local forceDotDelimiter = true         -- image sequences only; defaults on even without an operator (see rename below).
	local op = LPM_Fun.firstChildByType theShot "tyPreview"
	if (op != undefined) then
	(
		useTyPreviewSettings = (op.viewportSource == 2)
		if (op.outputFormat != undefined) and (op.outputFormat != "") then outFormat = op.outputFormat
		if (op.disableContainerNesting != undefined) then disableContainerNesting = op.disableContainerNesting
		if (op.forceDotDelimiter != undefined) then forceDotDelimiter = op.forceDotDelimiter
	)

	-- mp4 is a single video file (output_type 0); everything else is an image sequence (output_type 1).
	-- Alpha is enabled for formats that support it; tyPreview ignores it for the rest.
	local outType = (if (outFormat == "mp4") then 0 else 1)
	local alphaOn = (outFormat == "exr") or (outFormat == "png") or (outFormat == "tif")

	-- Frame range string (tyPreview frameRange_list accepts "10, 20, 30-50" syntax).
	-- Derived from the applied common-props frame settings.
	fn _toFrame t = ( (t as integer) / ticksperframe )
	local frameStr = ""
	case rendTimeType of
	(
		1: frameStr = (_toFrame currentTime) as string                                              -- single / current frame
		2: frameStr = ((_toFrame animationRange.start) as string) + "-" + ((_toFrame animationRange.end) as string)  -- active segment
		3: frameStr = ((_toFrame rendStart) as string) + "-" + ((_toFrame rendEnd) as string)        -- custom range
		4: frameStr = rendPickupFrames                                                               -- frame pickup list
		default: frameStr = ((_toFrame animationRange.start) as string) + "-" + ((_toFrame animationRange.end) as string)
	)

	-- Output path follows the shot output (LPM authority), with the operator's chosen format
	-- applied as the extension. Ensure the directory exists.
	local outFile = LPM_Root.fullOutputPath
	outFile = (getFilenamePath outFile) + (getFilenameFile outFile) + "." + outFormat

	-- Container files (mp4) with nesting disabled: write the video beside the shot folder
	-- (i.e. in the shot folder's parent) named "<shot>_<pass>", so animators can browse
	-- versions without digging through the per-shot/per-pass subfolders. The shot folder is
	-- located within the resolved output path by name (honours custom path templates); we fall
	-- back to LPM_Root.rootDir if it can't be found. Image sequences are left nested as normal.
	if (outType == 0) and disableContainerNesting and (isValidNode theShot) then
	(
		local shotName = LPM_Fun.getName theShot.name
		local passName = LPM_Fun.generatePassName thePass

		-- Find the shot folder's parent by walking the resolved directory components.
		local dirStr = getFilenamePath LPM_Root.fullOutputPath
		local parts = filterString dirStr "\\/"
		local parentDir = LPM_Root.rootDir
		for i = 1 to parts.count while (parentDir == LPM_Root.rootDir) do
		(
			if ((parts[i] == shotName) or (matchPattern parts[i] pattern:(shotName + "*"))) then
			(
				-- Rebuild the absolute path up to (but not including) the shot folder.
				local rebuilt = ""
				for j = 1 to (i - 1) do rebuilt += (parts[j] + "\\")
				-- Preserve a leading UNC / drive prefix that filterString collapses.
				if (matchPattern dirStr pattern:"\\\\*") then rebuilt = "\\\\" + rebuilt
				if (rebuilt != "") then parentDir = rebuilt
			)
		)

		if (parentDir != "") and (parentDir[parentDir.count] != "\\") then parentDir += "\\"
		outFile = parentDir + shotName + "_" + passName + "." + outFormat
	)

	try ( makeDir (getFilenamePath outFile) all:true ) catch()

	-- Camera to preview. Prefer the ACTIVE VIEWPORT's camera: fnPreRenderAction / setCommonProps
	-- already pointed the active viewport at the pass camera (cp._Camera), and that camera is what
	-- carries the user's per-camera tyPreview settings. LPM_Root.renderCamera is frequently undefined
	-- during the render pass (this setup drives the camera through commonProps, not the global render
	-- camera), so it is only a fallback. Without this, camArg was undefined and BOTH modes fell through
	-- to the active-viewport defaults branch (Mode 2 ignored the camera's saved shading style).
	local camArg = (try(viewport.getCamera())catch(undefined))
	if not (isValidNode camArg) then
	(
		if (isValidNode LPM_Root.renderCamera) then camArg = LPM_Root.renderCamera else camArg = undefined
	)

	format "LPM TyPreview: pass:% shot:% frames:% res:%x% fmt:% alpha:% out:% viewportSource:%\n" \
		(try(LPM_Fun.generatePassName thePass)catch("?")) \
		(if isValidNode theShot then (LPM_Fun.getName theShot.name) else "-") \
		frameStr renderWidth renderHeight outFormat alphaOn outFile \
		(if useTyPreviewSettings then "tyPreview" else "active")

	try
	(
		-- output_type: 0 = mp4 video, 1 = image sequence (format = extension in output_filename).
		-- output_framerate only applies to mp4; harmless for image sequences.
		if useTyPreviewSettings and (camArg != undefined) then
		(
			-- Use the target camera's stored tyPreview appearance settings, overriding only
			-- the LPM-authority settings below. fnPreRenderAction may have left the active viewport
			-- on a different camera (setCommonProps -> viewport.setCamera cp._Camera) or in a stale
			-- Nitrous state; tyPreview's shading style follows the active viewport, so re-assert the
			-- previewed camera and force a redraw first (mirrors the working standalone conditions).
			if (isValidNode camArg) then ( viewport.setCamera camArg )
			forceCompleteRedraw()
			tyPreview camera_node:camArg \
				frameRange_list:frameStr frameRange_nth:rendNThFrame \
				resolution_width:renderWidth resolution_height:renderHeight \
				appearance_alpha:alphaOn \
				output_type:outType output_framerate:(frameRate as float) output_filename:outFile
		)
		else
		(
			-- Active-viewport mode: produce a clean, default-appearance preview that does NOT inherit
			-- the render camera's customised tyPreview settings.
			--
			-- tyPreview stores appearance settings per-camera (internally, no MAXScript getter) and
			-- PERSISTS any appearance_* override onto whichever camera it previews. Pinning defaults on
			-- the previewed camera (or omitting camera_node, which resolves the active-viewport camera)
			-- would overwrite the very settings that the "Use TyPreview viewport settings" mode relies
			-- on. To stay non-destructive we preview from a throwaway copy of the previewed camera
			-- (identical transform/lens) and pin the defaults on IT, then delete it -- the real camera's
			-- saved settings are never touched.
			--
			-- appearance_lights: 0=one_default, 1=scene, 2=two_default. appearance_override: 0=none.
			local tmpCam = undefined
			local tmpTarget = undefined
			try ( if (isValidNode camArg) then
			(
				tmpCam = copy camArg
				tmpCam.name = (uniqueName "LPM_tyPreviewTmpCam_")
				tmpTarget = tmpCam.target		-- target cameras copy a target node too; clean it up
			) ) catch ( format "LPM TyPreview: temp camera copy failed, using active viewport: %\n" (getCurrentException()) )

			-- Everything after the copy is wrapped so any failure (viewport setup or a tyPreview
			-- call, including the fallback) still reaches the cleanup below -- a throwaway camera
			-- must never be left in the scene. (MAXScript has no finally; this is the equivalent.)
			local appearancePinned = false
			try
			(
				-- Re-assert the previewed camera as the active viewport and force a redraw (same
				-- reason as Mode 2 above): tyPreview's capture follows the active viewport's state.
				if (isValidNode tmpCam) then ( viewport.setCamera tmpCam )
				forceCompleteRedraw()

				-- If the copy failed, tmpCam stays undefined and we fall back to the active viewport.
				try
				(
					if (isValidNode tmpCam) then
					(
						tyPreview camera_node:tmpCam \
							frameRange_list:frameStr frameRange_nth:rendNThFrame \
							resolution_width:renderWidth resolution_height:renderHeight \
							appearance_mode:0 appearance_style:0 appearance_lights:1 appearance_override:0 \
							appearance_edgedFaces:false appearance_antiAliasing:true appearance_safeFrames:false \
							appearance_multipass:false appearance_textures:true appearance_transparency:true \
							appearance_ao:false appearance_shadows:true appearance_progressiveRefinement:false \
							appearance_alpha:alphaOn \
							output_type:outType output_framerate:(frameRate as float) output_filename:outFile
					)
					else
					(
						tyPreview \
							frameRange_list:frameStr frameRange_nth:rendNThFrame \
							resolution_width:renderWidth resolution_height:renderHeight \
							appearance_mode:0 appearance_style:0 appearance_lights:1 appearance_override:0 \
							appearance_edgedFaces:false appearance_antiAliasing:true appearance_safeFrames:false \
							appearance_multipass:false appearance_textures:true appearance_transparency:true \
							appearance_ao:false appearance_shadows:true appearance_progressiveRefinement:false \
							appearance_alpha:alphaOn \
							output_type:outType output_framerate:(frameRate as float) output_filename:outFile
					)
					appearancePinned = true
				)
				catch
				(
					format "LPM TyPreview: appearance pin failed (unexpected appearance_* arg on this build), falling back: %\n" (getCurrentException())
				)

				if not appearancePinned then
				(
					if (isValidNode tmpCam) then
					(
						tyPreview camera_node:tmpCam \
							frameRange_list:frameStr frameRange_nth:rendNThFrame \
							resolution_width:renderWidth resolution_height:renderHeight \
							appearance_alpha:alphaOn \
							output_type:outType output_framerate:(frameRate as float) output_filename:outFile
					)
					else
					(
						tyPreview \
							frameRange_list:frameStr frameRange_nth:rendNThFrame \
							resolution_width:renderWidth resolution_height:renderHeight \
							appearance_alpha:alphaOn \
							output_type:outType output_framerate:(frameRate as float) output_filename:outFile
					)
				)
			)
			catch
			(
				format "LPM TyPreview: active-viewport export failed: %\n" (getCurrentException())
			)

			-- Always remove the throwaway camera (and its target), even if the export above threw,
			-- so failed previews never leave LPM_tyPreviewTmpCam_ nodes behind.
			try ( if (isValidNode tmpCam) then delete tmpCam ) catch()
			try ( if (isValidNode tmpTarget) then delete tmpTarget ) catch()
		)
	)
	catch
	(
		format "LPM TyPreview ERROR: %\n" (getCurrentException())
	)

	-- ---------------------------------------------------------------------------------------------
	-- Frame delimiter (post-export rename -- HACKFIX). tyFlow's tyPreview() writes image sequences
	-- as "<name>_####.<ext>" (it owns the underscore; there is no tyPreview arg to change it). LPM's
	-- house convention is "<name>.####.<ext>", so we rename the frames tyPreview just wrote. Image
	-- sequences only (outType 1 -- mp4 has no frame token); gated by the operator's forceDotDelimiter
	-- (default on). See the "Frame delimiter" note in CLAUDE.md. This is deliberately a post-process
	-- on disk and depends on tyFlow's current naming behaviour.
	-- ---------------------------------------------------------------------------------------------
	if (outType == 1) and forceDotDelimiter then
	(
		-- Non-destructive lock test: can this existing file be deleted/overwritten? Opens an exclusive
		-- write handle via .NET -- FileShare.None succeeds only if no other process/machine holds the
		-- file open, exactly the precondition for a safe delete+rename -- then closes it immediately.
		-- FileMode.Open reads/creates/truncates nothing, so it is a metadata round-trip, not a data read.
		fn _canReplaceFile path =
		(
			local ok = false
			try
			(
				local fs = dotNetObject "System.IO.FileStream" path \
					(dotNetClass "System.IO.FileMode").Open \
					(dotNetClass "System.IO.FileAccess").ReadWrite \
					(dotNetClass "System.IO.FileShare").None
				fs.Close()
				ok = true
			)
			catch ( ok = false )
			ok
		)

		fn _isAllDigits s =
		(
			local ok = (s.count > 0)
			for i = 1 to s.count while ok do ( if (findString "0123456789" s[i]) == undefined then ok = false )
			ok
		)

		local outDir   = getFilenamePath outFile
		local baseName = getFilenameFile outFile        -- "<shot>_<pass>" (no extension)
		local ext      = getFilenameType outFile        -- ".exr"
		local prefix   = baseName + "_"

		-- Pair each underscore frame tyPreview just wrote with its dotted target. The frame token must
		-- be all digits so unrelated files that share the prefix are never touched. (Dotted targets do
		-- not match the "<base>_*" glob, so re-runs never double-process.)
		local written = getFiles (outDir + prefix + "*" + ext)
		local srcList = #()
		local dstList = #()
		for f in written do
		(
			local stem = getFilenameFile f              -- "<baseName>_<frame>"
			if (matchPattern stem pattern:(prefix + "*")) then
			(
				-- explicit count (not "-1") to avoid MaxScript parsing " -1" as subtraction
				local frameTok = substring stem (prefix.count + 1) (stem.count - prefix.count)
				if (_isAllDigits frameTok) then
				(
					append srcList f
					append dstList (outDir + baseName + "." + frameTok + ext)
				)
			)
		)

		if (srcList.count > 0) then
		(
			-- Pre-flight (all-or-nothing): only over targets that already exist. If ANY is locked we abort
			-- the whole rename for this pass -- deleting nothing -- so a previously-good dotted sequence is
			-- never partially destroyed. Fast path: nothing to overwrite -> skip straight to the rename.
			local existing = #()
			for d in dstList where (doesFileExist d) do append existing d

			local locked = false
			local cancelled = false
			if (existing.count > 0) then
			(
				progressStart "LPM TyPreview: checking existing output for locks"
				local n = existing.count
				for i = 1 to n while (not locked and not cancelled) do
				(
					if (getProgressCancel()) then cancelled = true
					else
					(
						progressUpdate (100.0 * i / n)
						if (not (_canReplaceFile existing[i])) then locked = true   -- stop at the first lock
					)
				)
				progressEnd()
			)

			if cancelled then
			(
				format "LPM TyPreview: lock check cancelled -- frames left with underscore delimiter.\n"
			)
			else if locked then
			(
				format "LPM TyPreview: existing target frame(s) locked by another machine -- leaving this run as underscore files; prior version left intact.\n"
				if (isValidNode theShot) and ((findItem LPM_PreviewLockedShots theShot) == 0) then
					append LPM_PreviewLockedShots theShot
			)
			else
			(
				-- Commit: pre-flight clear (or nothing to overwrite). Delete-then-rename with progress.
				local renamed = 0
				local failed = 0
				progressStart "LPM TyPreview: renaming frames to \".\" delimiter"
				local n = srcList.count
				for i = 1 to n while (not (getProgressCancel())) do
				(
					progressUpdate (100.0 * i / n)
					local cleared = true
					if (doesFileExist dstList[i]) then cleared = (try(deleteFile dstList[i])catch(false))
					if cleared then
					(
						if (try(renameFile srcList[i] dstList[i])catch(false)) then renamed += 1
						else ( failed += 1; format "LPM TyPreview: rename failed for %\n" srcList[i] )
					)
					else ( failed += 1; format "LPM TyPreview: could not remove existing target %\n" dstList[i] )
				)
				progressEnd()
				format "LPM TyPreview: renamed % frame(s) to '.' delimiter (failed: %)\n" renamed failed
			)
		)
	)
)
