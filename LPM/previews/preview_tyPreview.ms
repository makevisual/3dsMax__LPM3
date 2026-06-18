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
	local op = LPM_Fun.firstChildByType theShot "tyPreview"
	if (op != undefined) then
	(
		useTyPreviewSettings = (op.viewportSource == 2)
		if (op.outputFormat != undefined) and (op.outputFormat != "") then outFormat = op.outputFormat
		if (op.disableContainerNesting != undefined) then disableContainerNesting = op.disableContainerNesting
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

	-- LPM-authority camera. Already set on the active viewport by fnPreRenderAction.
	local camArg = undefined
	if (isValidNode LPM_Root.renderCamera) then camArg = LPM_Root.renderCamera

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
			-- the LPM-authority settings below.
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
			-- PERSISTS any appearance_* override onto whichever camera it previews. fnPreRenderAction
			-- points the active viewport at LPM_Root.renderCamera, so pinning defaults here without a
			-- camera_node would resolve the render camera and overwrite the very settings that the
			-- "Use TyPreview viewport settings" mode relies on. To stay non-destructive we preview from
			-- a throwaway copy of the render camera (identical transform/lens) and pin the defaults on
			-- IT, then delete it -- the render camera's saved settings are never touched.
			--
			-- appearance_lights: 0=one_default, 1=scene, 2=two_default. appearance_override: 0=none.
			local tmpCam = undefined
			local tmpTarget = undefined
			try ( if (isValidNode LPM_Root.renderCamera) then
			(
				tmpCam = copy LPM_Root.renderCamera
				tmpCam.name = (uniqueName "LPM_tyPreviewTmpCam_")
				tmpTarget = tmpCam.target		-- target cameras copy a target node too; clean it up
			) ) catch ( format "LPM TyPreview: temp camera copy failed, using active viewport: %\n" (getCurrentException()) )

			-- If the copy failed, tmpCam stays undefined and we fall back to the active viewport.
			local appearancePinned = false
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

			-- Always remove the throwaway camera (and its target), leaving the scene untouched.
			try ( if (isValidNode tmpCam) then delete tmpCam ) catch()
			try ( if (isValidNode tmpTarget) then delete tmpTarget ) catch()
		)
	)
	catch
	(
		format "LPM TyPreview ERROR: %\n" (getCurrentException())
	)
)
