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
	local op = LPM_Fun.firstChildByType theShot "tyPreview"
	if (op != undefined) then
	(
		useTyPreviewSettings = (op.viewportSource == 2)
		if (op.outputFormat != undefined) and (op.outputFormat != "") then outFormat = op.outputFormat
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
			-- Capture the active viewport (already set to the render camera) with its current
			-- display settings; omit camera_node so tyPreview uses the active viewport.
			tyPreview \
				frameRange_list:frameStr frameRange_nth:rendNThFrame \
				resolution_width:renderWidth resolution_height:renderHeight \
				appearance_alpha:alphaOn \
				output_type:outType output_framerate:(frameRate as float) output_filename:outFile
		)
	)
	catch
	(
		format "LPM TyPreview ERROR: %\n" (getCurrentException())
	)
)
