-- Sources
-- U:\3dsMax2020\3dsmax2020_x64_plugins\Nukeem
-- http://www.scriptspot.com/3ds-max/scripts/nukeem-max-to-nuke-exporter

-- Modified 
-- 3/3/2020 by Aaron Dabelow theonlyaaron@gmail.com 
-- Modified to run without macroscript and be launched from external filein command 

-- LPM integration - 03/04/2020


-- TODO: Rework this from absolute paths, come on Neil...
  struct LPM_NukeEM_Settings_Str
 (
 	frameStart = 1000,
 	frameEnd = 1100,
 	NukeEm_Camera = undefined,
 	NukeEm_ResX = 2112,
 	NukeEm_ResY = 1188,
 	NukeEm_FrameRange = undefined, 
 	NukeEm_OutputPath = "U:\\users\\Neil_B\\Test\\TestOutput\\LPM_NukeEm",
 	NukeEm_FrameInt = .5

 )

 LPM_NukeEM_Settings = LPM_NukeEM_Settings_Str()


--Temp Variables
showScript = false
sceneGenerator = true
createEnv = true
nukeScriptCheck = true




try( destroydialog NukeEmDialog ) catch()

fn getCamDetails selCam =
(

		local f_length, hap, vap
		struct camdatastruct  (f_length,hap,vap)
		if classof selCam == Main_Camera then
		(
			tmpFOV=selCam.lens.fov_type
			selCam.lens.fov_type=3
			f_length =selCam.lens.focal_length
			hap = selCam.lens.filmgate
			selCam.lens.fov_type=tmpFOV
		)
		else if classof selCam == VRayPhysicalCamera then
		(
			local tempDType,tempDM,focDist
			tempDType = units.DisplayType
			tempDMType = units.MetricType
			
			units.DisplayType = #metric
			units.MetricType = #millimeters
			
			if selCam.specify_focus==true then (focDist = units.formatValue (selCam.focus_distance)) else (focDist = units.formatValue (selCam.target_distance))
			
			units.MetricType = tempDMType
			units.DisplayType = tempDType
			
			focDist = "19343,392043\""
			focDist = filterstring focDist ".;:?//\"',abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
			focDist = (focDist[1]+"."+focDist[2]) as float
			if (focDist - selCam.focal_length) == 0.0 do (focDist += .01)
			
			f_length = ((focDist*selCam.focal_length)/(focDist - selCam.focal_length))*(selCam.zoom_factor)
			hap = selCam.film_width
		)
		else if classof selCam == Physical then
		(
			tempHap = getRendApertureWidth()
			setRendApertureWidth(selCam.film_width_mm)
			f_length = cameraFOV.FOVtoMM selCam.fov 
			setRendApertureWidth(tempHap)
			hap = selcam.film_width_mm
		)
		else
		(
			tmpFOV = selCam.fovType
			selCam.fovType=2
			f_length = cameraFOV.FOVtoMM selCam.fov 
			hap = getRendApertureWidth()
			selCam.fovType = tmpFOV
		)
		vap=(hap/GetRendImageAspect())
		return camdatastruct f_length hap vap
)

fn getCamFOV camdata =
(
	return [(2*atan(camData.hap/(2*camData.f_length))),(2*atan(camData.vap/(2*camData.f_length)))]
)

fn reconcile3D pPos cam =
(
	fov = getCamFOV (getCamDetails cam)
	tempPoint = point pos:pPos
	pPos = in coordsys cam tempPoint.pos
	delete tempPoint
	pPos /= (pPos.z*-1)
	return (([pPos.x,pPos.y]/[(tan((FOV.x/2))),(tan((FOV.y/2)))])/2)+0.5
	--return (([(atan(pPos.x/(pPos.z*-1.0))),(atan(pPos.y/(pPos.z*-1.0)))]/fov)+0.5)
)

--VARIABLES
struct NukeEmStruct (selObj,selObjSettings,selCam,savePath)
global NukeEm = NukeEmStruct selObj:#() selObjSettings:#()
struct NukeExportLib (



	fn CreateNukeNode NodeType NodeName CustomSettings NodePos:[0,0] inputnum:#null = 
	(
		ExportData = Stringstream ""
		
		format "\n% { \n" NodeType to:ExportData
		format "%" (if inputnum != #null then ("	inputs "+(inputnum as string)+"\n") else ("")) to:ExportData
		format "	name % \n " NodeName to:ExportData
		format "	xpos % \n" (NodePos.x as integer) to:ExportData
		format "	ypos % \n" (NodePos.y as integer)to:ExportData
		for i=1 to CustomSettings.count do (format "%" (CustomSettings[i] as string) to:ExportData) -- Add any other pre-formatted node settings
		format "}\n" to:ExportData	
		
		ExportData
	),
	
	fn getAnimationData objNode framerange:[0,100] =
	(
		struct animDataStruct (CamTransform, Transform, type)
		local AnimData = animDataStruct Transform:#() CamTransform:#() type:(superclassof objNode)
		-- Collect Transform Data
		for t in framerange.x to framerange.y do 
		(
			at time t
			(
				if AnimData.type == camera do 
				(
					append AnimData.CamTransform (getCamDetails objNode)
				)
				append AnimData.Transform objNode.transform
			)
		)
		AnimData
	),

	
	fn collectCameraKnobs AnimData framerange:[0,100] =
	(
		local outputScript
		
		outputScript = stringstream ""
		format "	focal {{curve " to:outputScript
		for j =1 to AnimData.camTransform.count do format "x% % " (j - 1 + framerange.x) (formattedprint AnimData.camTransform[j].f_length format:".8f") to:outputScript
		format "	}}\n"	to:outputScript
		format "	haperture {{curve " to:outputScript
		for j =1 to AnimData.camTransform.count do format "x% % " (j - 1 + framerange.x) (formattedprint AnimData.camTransform[j].hap format:".8f") to:outputScript
		format "	}}\n"	to:outputScript
		format "	vaperture {{curve " to:outputScript
		for j =1 to AnimData.camTransform.count do format "x% % " (j - 1 + framerange.x) (formattedprint AnimData.camTransform[j].vap format:".8f") to:outputScript
		format "	}}\n"	to:outputScript
		
		return outputScript
	),

	fn collectTransformKnobs AnimData rotOrder:"XZY" xformOrder:"SRT" framerange:[0,100] =
	(
		outputScript = stringstream ""
		format "	xform_order %
	rot_order %
	translate {\n		" xformOrder rotOrder to:outputScript
	-- Begin Transform Output -- 
	
		-- X
		format "{curve " to:outputScript
		for j =1 to AnimData.Transform.count do format "x% % " (j - 1 + framerange.x) (formattedprint AnimData.Transform[j].pos.x format:".8f") to:outputScript
		format "}\n		" to:outputScript
		-- Z
		format "{curve " to:outputScript
		for j =1 to AnimData.Transform.count do format "x% % " (j - 1 + framerange.x) (formattedprint AnimData.Transform[j].pos.z format:".8f") to:outputScript
		format "}\n		" to:outputScript
		-- Y
		format "{curve " to:outputScript
		for j =1 to AnimData.Transform.count do format "x% % " (j - 1 + framerange.x) (formattedprint (AnimData.Transform[j].pos.y*-1) format:".8f") to:outputScript
		format "}\n	" to:outputScript
		
		format "}\n	" to:outputScript 
		
		-- Begin Rotation Output -- 
		format "rotate {\n		" to:outputScript 
		for i = 1 to rotOrder.count do
		(
			if rotOrder[i] == "X" then
			(
				-- X
				if AnimData.type == camera then 
				(
					format "{curve " to:outputScript
					for j =1 to AnimData.Transform.count do format "x% % "  (j - 1 + framerange.x) (formattedprint ((quatToEuler2 AnimData.Transform[j].rotation).x-90) format:".8f") to:outputScript
					format "}\n		" to:outputScript
				)
				else 
				(
					format "{curve " to:outputScript
					for j =1 to AnimData.Transform.count do format "x% % "  (j - 1 + framerange.x) (formattedprint ((quatToEuler2 AnimData.Transform[j].rotation).x) format:".8f") to:outputScript
					format "}\n		" to:outputScript
				)
			)
			else if rotOrder[i] == "Z" then
			(
				-- Z
				format "{curve " to:outputScript
				for j =1 to AnimData.Transform.count do format "x% % "  (j - 1 + framerange.x) (formattedprint (quatToEuler2 AnimData.Transform[j].rotation).z format:".8f") to:outputScript
				format "}\n		" to:outputScript
			)
			else if rotOrder[i] == "Y" then
			(
				-- Y
				format "{curve " to:outputScript
				for j =1 to AnimData.Transform.count do format "x% % "  (j - 1 + framerange.x) (formattedprint (((quatToEuler2 AnimData.Transform[j].rotation).y)*-1) format:".8f") to:outputScript
				format "}\n"	to:outputScript
			)
			else ()
		)
		format "	}\n"	to:outputScript
		outputScript
	)
)



fn nukeEm_GetSettings shotRender =
(

	LPM_NukeEM_Settings.NukeEm_Camera = shotRender.children[1].commonProps._camera
	LPM_NukeEM_Settings.NukeEm_OutputPath = (LPM_Root.rootDir + (LPM_Fun.getName shotRender.name))


	if shotRender.children[1].commonProps.timeOutputTgl == true then
	(
		if shotRender.children[1].commonProps._rendTimeType == 1 then
		(
			LPM_NukeEM_Settings.frameStart = (trimRight (currenttime as string) "f") as integer
			LPM_NukeEM_Settings.frameEnd = (trimRight (currenttime as string) "f") as integer

		)
		else if shotRender.children[1].commonProps._rendTimeType == 2 then
		(
			LPM_NukeEM_Settings.frameStart = animationrange.start
			LPM_NukeEM_Settings.frameEnd = animationrange.end
		)
		else if shotRender.children[1].commonProps._rendTimeType == 3 then
		(
			LPM_NukeEM_Settings.frameStart = shotRender.children[1].commonProps._rendStart
			LPM_NukeEM_Settings.frameEnd = shotRender.children[1].commonProps._rendEnd
		)
		else
		(
			LPM_NukeEM_Settings.frameStart = shotRender.children[1].commonProps._rendStart
			LPM_NukeEM_Settings.frameEnd = shotRender.children[1].commonProps._rendEnd
		)
	)
	else 
	(
		LPM_NukeEM_Settings.frameStart = (trimRight (animationRange.start as string) "f") as integer
		LPM_NukeEM_Settings.frameEnd = (trimRight (animationRange.end as string) "f") as integer
		print LPM_NukeEM_Settings.frameStart
	)
	if shotRender.children[1].commonProps.outputSizeTgl == true then
	(
		LPM_NukeEM_Settings.NukeEm_ResX = shotRender.children[1].commonProps._renderWidth
		LPM_NukeEM_Settings.NukeEm_ResY = shotRender.children[1].commonProps._renderHeight
	)
	else
	(

		LPM_NukeEM_Settings.NukeEm_ResX = renderWidth
		LPM_NukeEM_Settings.NukeEm_ResY = renderHeight
	)

)



fn nukeEm_CameraExport shotName = 
(
	undo "Export to Nuke" on
	(
		proceed = true

		if proceed do
		(
			NukeScript = stringstream ""
			disableSceneRedraw()

			--(trimRight(animationRange.start as string) "f")

			local startTime = LPM_NukeEM_Settings.frameStart
			local endTime = LPM_NukeEM_Settings.frameEnd
			local geoStartTime = LPM_NukeEM_Settings.frameStart
			local geoEndTime = LPM_NukeEM_Settings.frameEnd

			if LPM_NukeEM_Settings.NukeEm_Camera != undefined then
			(

				local transformScript, animData
				animData = NukeExportLib.getAnimationData LPM_NukeEM_Settings.NukeEm_Camera  FrameRange:[startTime,endtime]
				transformScript = NukeExportLib.collectTransformKnobs (animData) FrameRange:[startTime,endtime]
				camScript = NukeExportLib.collectCameraKnobs (animData) FrameRange:[startTime,endtime]

				format ((NukeExportLib.CreateNukeNode "Reformat" ("Reformat") #(("	format \"" + (LPM_NukeEM_Settings.NukeEm_ResX as string) + " " + (LPM_NukeEM_Settings.NukeEm_ResY as string) + "\"\n")) NodePos:[150,100]) as string) to:NukeScript
				format "push [stack 0]\n push [stack 0]\n" to:NukeScript

				format ((NukeExportLib.CreateNukeNode "Camera" (LPM_NukeEM_Settings.NukeEm_Camera.name) #((transformScript),(camScript)) NodePos:[150,100]) as string) to:NukeScript
				format "push [stack 0]\n push [stack 0]\n" to:NukeScript

			)
			NukemMoblurOffset = 0.0
			frameBuffer_Renderer_Check = renderers.current as string

			frameBuffer_Renderer_Check= trimRight frameBuffer_Renderer_Check "1234567890_:"
			frameBuffer_Renderer_Check = trimLeft frameBuffer_Renderer_Check "qwertyuiop[]asdfghjkl;'zxcvbnm,./QWERTYUIOP{}ASDFGHJKLZXCVBNM<>?-_1234567890"

			if frameBuffer_Renderer_Check == ":V_Ray_Adv" then
			(
				NukeEmMoblurOffset = renderers.current.moblur_intervalCenter

			)

			if sceneGenerator == true then
			(
				if LPM_NukeEM_Settings.NukeEm_Camera!= undefined then 
				(
					inputs = NukeEm.selObj.count+1; renderInputs = 3
				)			
				else (inputs = NukeEm.selObj.count; renderInputs = 2)
				format "Scene {\ninputs " to:NukeScript
				format "%\n" inputs to:NukeScript
				format"name Scene1\nxpos 0\nypos 100\n}\n" to:NukeScript
				if createEnv == true then (
					format "push 0\n" to:NukeScript
				)
				else
				(
					format ((NukeExportLib.getEnvironmentNode [-200,100]) as string) to:NukeScript
					format ((NukeExportLib.CreateNukeNode "Reformat" "Render_Output_Size" #("format \""+LPM_NukeEM_Settings.NukeEm_ResX as string+" "+LPM_NukeEM_Settings.NukeEm_ResY as string+" 0 0 "+LPM_NukeEM_Settings.NukeEm_ResX as string+" "+LPM_NukeEM_Settings.NukeEm_ResY as string+" "+RenderPixelAspect as string+" 3ds_Max_Render\"") nodepos:[-200,200]) as string) to:NukeScript
				)
				format "ScanlineRender {\ninputs " to:NukeScript
				format "%" renderInputs to:NukeScript
				format ("\nshutteroffset custom\nshuttercustomoffset " + (NukeEmMoblurOffset as string)) to:NukeScript
				format "\nname ScanlineRender1\nxpos 0\nypos 200\n}" to:NukeScript
			)
			setclipboardText NukeScript as string
			if showScript == true do
			(
				debug = newscript()
				format "Root {
 inputs 0
 first_frame %
 last_frame %
 fps %
 format \" % % 0 0 % % 1 3dsmax_render\"
}\n" (LPM_NukeEM_Settings.frameStart as string) (LPM_NukeEM_Settings.frameEnd as string) (framerate as string) (LPM_NukeEM_Settings.NukeEm_ResX as string) (LPM_NukeEM_Settings.NukeEm_ResY as string) (LPM_NukeEM_Settings.NukeEm_ResX as string) (LPM_NukeEM_Settings.NukeEm_ResY as string) to:debug
				
				format (substitutestring (NukeScript as string) "%" "\%") to:debug
			)
			if nukeScriptCheck == true do
			(
				nukefilename = if maxfilename != "" then (getfilenamefile maxfilename) else ("Untitled")
				nukefilepath = (LPM_NukeEM_Settings.NukeEm_OutputPath+"\\"+shotName+".nk")
				nukefile = createfile nukefilepath
				format "Root {
 inputs 0
 first_frame %
 last_frame %
 fps %
 format \" % % 0 0 % % 1 3dsmax_render\"
}\n" (LPM_NukeEM_Settings.frameStart as string) (LPM_NukeEM_Settings.frameEnd as string) (framerate as string) (LPM_NukeEM_Settings.NukeEm_ResX as string) (LPM_NukeEM_Settings.NukeEm_ResY as string) (LPM_NukeEM_Settings.NukeEm_ResX as string) (LPM_NukeEM_Settings.NukeEm_ResY as string) to:nukefile
				format (substitutestring (NukeScript as string) "%" "\%") to:nukefile
				close nukefile
			)
			enableSceneRedraw()

		)	 
	) -- end undo
)
