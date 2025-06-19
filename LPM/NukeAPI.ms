-- global LPM_NukeAPI -- should be declared in LPM Globals.ms

struct LPM_NukeAPI_str
(
	nukeFilePath 	= undefined,
	nukeData 		= undefined,

	function getFileData  = 
	(
		--TODO: get FPS from file as well ( LPM_NukeAPI.nukeData.fps )

		filePart = "Root {"
		nukeFile = openFile LPM_NukeAPI.nukeFilePath mode:"r"
		nukeFileParts = #()

		while not eof nukeFile do
		(
			if (readLine nukeFile) == filePart then exit   
		)
		
		while not eof nukeFile do
		(
			curline = (readLine nukeFile)
		
			if curline == "}" then exit  
			else
			(
				append nukeFileParts curline
			)
		)
		
		close nukeFile
		
		-- Search throuh the entries for certian file types and add them to the data object
		for nukeFilePart in nukeFileParts do 
		(
		  	curEntry = nukeFilePart
			curEntryParts = ( filterstring curEntry " " )
		
			if curEntryParts[1] == "name" 			then LPM_NukeAPI.nukeData.name 			= ( execute ( substring curEntry ( curEntryParts[1].count + 3 ) curEntry.count ) )
			if curEntryParts[1] == "first_frame" 	then LPM_NukeAPI.nukeData.first_frame 	= ( execute ( substring curEntry ( curEntryParts[1].count + 3 ) curEntry.count ) )
			if curEntryParts[1] == "last_frame" 	then LPM_NukeAPI.nukeData.last_frame 	= ( execute ( substring curEntry ( curEntryParts[1].count + 3 ) curEntry.count ) )
			if curEntryParts[1] == "format" 		then LPM_NukeAPI.nukeData.format 		= ( execute ( substring curEntry ( curEntryParts[1].count + 3 ) curEntry.count ) )
		)
	),

	function inferFileData = 
	(
		-- Find Project Dir Shot name and Project Name
		pathParts 		= filterstring LPM_NukeAPI.nukeData.name @"/"  -- Slash may need to be switched?
		projectPath = "" 
		for i in 1 to pathParts.count do 
		(
			projectPath += ( pathParts[i] + @"\" )

			if pathParts[i] == "Projects"
			then
			(
			projectPath += ( pathParts[ (i+1 ) ] + @"\" )
			LPM_NukeAPI.nukeData.project_dir = projectPath
			LPM_NukeAPI.nukeData.project_name = pathParts[ (i+1 ) ]
			LPM_NukeAPI.nukeData.shot_name = pathParts[ (i+3 ) ]
			LPM_NukeAPI.nukeData.shot_dir = ( projectPath + pathParts[ (i+2 ) ] + @"\" + pathParts[ (i+3 )] + @"\")
			exit
			)
		)

		-- Find Resolution 
		formatParts = filterstring nukeData.format " "
		nukeData.resolution = [( formatParts[1] as float ),( formatParts[2] as float ) ]

		nukeData.reference_dir = ( nukeData.shot_dir + @"Reference\v001\" )
		nukeData.output_dir = ( nukeData.shot_dir + @"Image_Sequences\" )
	),

	function checkData = 
	(
		-- Function checkData 
		print ( "name: " 				+ LPM_NukeAPI.nukeData.name )
		print ( "first_frame: " 		+ LPM_NukeAPI.nukeData.first_frame as string )
		print ( "last_frame: " 			+ LPM_NukeAPI.nukeData.last_frame as string )
		print ( "format: " 				+ LPM_NukeAPI.nukeData.format )
		print ( "resolution: " 			+ LPM_NukeAPI.nukeData.resolution as string )
		print ( "shot_name: " 			+ LPM_NukeAPI.nukeData.shot_name as string )
		print ( "shot_dir: " 			+ LPM_NukeAPI.nukeData.shot_dir )
		print ( "project_name: " 		+ LPM_NukeAPI.nukeData.project_name )
		print ( "project_dir: " 		+ LPM_NukeAPI.nukeData.project_dir )
		print ( "reference_dir: " 		+ LPM_NukeAPI.nukeData.reference_dir )
-- 		print ( "reference_file: " 		+ LPM_NukeAPI.nukeData.reference_file ) --todo: turn back on
		print ( "reference_duration: " 	+ LPM_NukeAPI.nukeData.reference_duration as string )
		print ( "reference_range: " 	+ LPM_NukeAPI.nukeData.reference_range as string )
		print ( "output_dir: " 			+ LPM_NukeAPI.nukeData.output_dir )
	),

	function init = (
		-- Function init 
		struct LPM_NukeDataStr
		(
			-- properties read from nuke script
			name 					= undefined,
			first_frame 			= undefined,
			last_frame 				= undefined,
			format 					= undefined,
			fps 					= undefined,

			-- properties inferred from nuke script
			resolution				= undefined,
			shot_name 				= undefined,
			shot_dir 				= undefined,
			project_name			= undefined,
			project_dir				= undefined,
			reference_dir 			= undefined,
			reference_file 			= undefined,
			reference_duration		= undefined,
			reference_range	 		= undefined,
			reference_start	 		= undefined,
			output_dir 				= undefined,

			end 					= "end"
		)

		LPM_NukeAPI.nukeData 	= LPM_NukeDataStr() 
	),

	function readNukeFile = 
	(
		LPM_NukeAPI.getFileData()
		LPM_NukeAPI.inferFileData()
	),

	function createIFL = (
		-- Function createIFL 

		-- get the jpg files, and count, in the directory, and prep the .ifl filename
		curDir 		= LPM_NukeAPI.nukeData.reference_dir
		curFiles 	= #()
		curFiles 	= getfiles ( curDir + "\*.jpg" )
		iflFileName = ( curDir + ( getfilenamefile curFiles[1] + ".ifl" ) )
		LPM_NukeAPI.nukeData.reference_duration = curFiles.count

		-- Get the start frame, and initialize the end frame
		curName 	= getfilenamefile iflFileName
		startFrame 	= ( ( substring curname ( curname.count - 3 ) 4 ) as integer )
		endFrame 	= startFrame
		LPM_NukeAPI.nukeData.reference_range = [ startFrame, startFrame]
		LPM_NukeAPI.nukeData.reference_start = startFrame

		-- make a new ifl file
		iflFile = createfile iflFileName

 		try
		(
			for curFile in curFiles do 
			(
				endFrame += 1
				format "%\n" (filenameFromPath curFile) to:iflFile
			)

			LPM_NukeAPI.nukeData.reference_range = [ startFrame, endFrame]
			close iflFile
			if doesFileExist iflFileName then ( LPM_NukeAPI.nukeData.reference_file = iflFileName )

		)
 		catch ( close iflFile )


		
	),

	function max_setFrameRange = 
	(
		-- Function max_setFrameRange body
		animationRange = ( interval LPM_NukeAPI.nukeData.first_frame LPM_NukeAPI.nukeData.last_frame )

		LPM_Root.children[1].children[1].children[1].commonProps[3].value = true
		LPM_Root.children[1].children[1].children[1].commonProps[4].value = 3
		LPM_Root.children[1].children[1].children[1].commonProps[6].value = LPM_NukeAPI.nukeData.first_frame
		LPM_Root.children[1].children[1].children[1].commonProps[7].value = LPM_NukeAPI.nukeData.last_frame




	),

	function max_setResolution = (
		-- Function max_setResolution body
			LPM_NukeAPI.nukeData.resolution
			renderWidth = LPM_NukeAPI.nukeData.resolution[1]
			renderHeight = LPM_NukeAPI.nukeData.resolution[2] 

			LPM_Root.children[1].children[1].children[1].commonProps[9].value = true
			LPM_Root.children[1].children[1].children[1].commonProps[10].value = LPM_NukeAPI.nukeData.resolution[1]
			LPM_Root.children[1].children[1].children[1].commonProps[11].value = LPM_NukeAPI.nukeData.resolution[2]
	),

	function max_setViewportBackground = (
		-- Function max_setViewportBackground body
			LPM_NukeAPI.createIFL()
			backgroundImageFileName = LPM_NukeAPI.nukeData.reference_file-- todo:turn back on
			setBkgFrameRange [0, LPM_NukeAPI.nukeData.reference_duration, 1]
			setBkgImageAspect #output
			setBkgImageAnimate true
			setBkgStartTime LPM_NukeAPI.nukeData.reference_start -- changed to read the new prop that is the start frame of the IFL

			curName = getfilenamefile LPM_NukeAPI.nukeData.reference_file
			startFrame = ( ( substring curname ( curname.count - 3 ) 4 ) as integer )
			--startFrame

			getBkgStartTime 
	),

	function max_setLPMOutput = (
		-- Function max_setLPMOutput body
			LPM_Root.rootDir = LPM_NukeAPI.nukeData.output_dir
	),

	function max_setLPMShotName = (
		-- Function max_setLPMShotName body
			--LPM_NukeAPI.nukeData.shot_dir

			if LPM_Root.children[1].children[1].name == "LPM_Shot_v001" then
			(
				LPM_Root.children[1].children[1].name = ("LPM_" + LPM_NukeAPI.nukeData.shot_name + "_v001")
			)
	),

	function max_setSaveFile = (
		-- Function max_setSaveFile body

			saveMaxFile ( LPM_NukeAPI.nukeData.shot_dir + "Scenes\\Layout\\" + LPM_NukeAPI.nukeData.shot_name + "_v001.max" )

	),

	function max_configureAndSave = (
	 	-- Function max_configureAndSave body

	 	-- close render dialog
	 	--renderSceneDialog.close()

 	 	max_setFrameRange() 			--good 
 	 	max_setResolution() 			--good 
 	 	max_setViewportBackground() 	--half good, todo: turn viewport on by default
 	 	max_setLPMOutput() 				--good			
 	 	max_setLPMShotName()			--Good
 	 	max_setSaveFile()				--Good: double check file naming convention

	 	renderSceneDialog.update()
	 	--renderSceneDialog.commit()
	 	--renderSceneDialog.open()
	 ),

	function promptAndProcess = (
		-- Function promptAndProcess body
		LPM_NukeAPI.nukeFilePath 	= @"Y:\Projects\Meccano - Fall 2020\SPOT__Meccano_30s\SHOT_Intro-010\Comps\Composite\Meccano_30s__SHOT_Intro-010__Composite_v001.nk"
		max_configureAndSave()
	),


	function ImportNuke NukeScriptDir =
	(
		
		LPM_NukeAPI.init()
	--	---- Set the nuke script
		LPM_NukeAPI.nukeFilePath 	= NukeScriptDir
		LPM_NukeAPI.readNukeFile()
		LPM_NukeAPI.max_configureAndSave()
		--LPM_NukeAPI.checkData()
	),


	ender = undefined 

)

LPM_NukeAPI = LPM_NukeAPI_str()

-- Build the API









--TODO: save ini

-- frameRate = 24
-- units.SystemType = #Inches
-- animationRange = interval 0f 314f
-- renderWidth = 1920
-- renderHeight = 1080
-- renderPixelAspect = 1
-- backgroundImageFileName = "Y:\\Projects\\MediaCom - New Era\\SPOT__MCOM_NE_WIFI\\SHOT__FX_080\\Footage\\Footage01\\ProxyHalf\\SHOT__FX_080_Footage01_ProxyHalf_1000.ifl"
-- setBkgFrameRange [0, 314, 1]
-- setBkgImageAspect #output
-- setBkgImageAnimate true