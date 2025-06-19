struct SMTDIdiotCheck
(

	function fileSizeChk = 
	(
		chkMessage = "IC: Checked FileSize"
		curSize = ( getFileSize ( maxFilePath + maxFileName ) ) as integer 
		
		if curSize > 100000000 then
		(
			if curSize > 500000000 then ( return #("fail", 1, #( "Filesize over 500MB, reference or cache scene elements externally." ), chkMessage ) )
			else( return #("fail", 0, #( "Filesize over 100MB, reference or cache scene elements externally." ), chkMessage ) )
		)

		return #("pass", 0,"0", chkMessage )
	),
	
	-- Ensures there is a camera in your scene
	function noCamerasChk =
	(
		chkMessage = "IC: Checked that there is a camera in scene"

		camObjs = (for obj in objects where (iskindof obj camera) collect obj)

		if camObjs.count != 0 then()else
		(
			return #("fail", 1, #( "No cameras in your scene!" ),  chkMessage )
		)

		return #("pass", 0,"0", chkMessage )
	),
	
	-- checks to see if any cameras have a multipass camera effect enabled
	function cameraMultiPassChk =
	(
		results = #()
		chkMessage = "IC: Checked Cameras for multipass effects"

		camObjs = (for obj in objects where (iskindof obj camera) collect obj)

		for cam in camObjs do
		(			
			try
			(
				if cam.mpassEnabled == true then
				(
					--result = ( "\" " + (cam.name) + " \"  has multipass enabled! ")
					result = ( "' " + (cam.name) + " '  has multipass enabled! ")
					join results #( result )
				)else()
			)catch()			
		)

		if results.count >= 1
		then
		(
			return #("fail", 3, results, chkMessage )
		)

		return #("pass", 0,"0", chkMessage )
	),

	-- checks to see if the frame rate is set to 24 fps
	function frameRateChk =
	(
		chkMessage = "IC: Checked frame rate"

		if framerate != 24
		then
		(
			return #("fail", 4, #( "Framerate not set to 24fps!"  ) , chkMessage )
		)

		return #("pass", 0,"0", chkMessage )
	),

	-- checks to see if the file is saved into an autoback folder
	function MTautobackChk =
	(
		fileString = maxFilePath 
		chkMessage = "IC: Checked to make sure scene file not saved in the MT_Autobak Folder"

		if fileString == ""
		then
		(
			return #("fail", 1, #( "File not saved!"  ) )
		)
		else()
		
		try( fileStringEnd = substring fileString (filestring.count - 11) 999 )catch()

		if fileStringEnd == @"MT_autoback\" 
		then
		(
			return #("fail", 1, #( "Move your scene out of the Autobak folder to be able to submit!!!"  ) , chkMessage )
		)

		return #("pass", 0,"0", chkMessage )

	),

	-- Looks for any active hairfarm render effects, which probably shouldnt be on if you are rendering with Vray
	function activeHairFarmEffects =
	(
		collectedEffects = for num in 1 to numEffects collect (getEffect num)
		chkMessage = "IC: Checked to make hair farm is not rendering as an render effect"

		for collectedEffect in collectedEffects do 
		(
		 	if ( ( classof collectedEffect ) == Hair_Farm_RendererrenderEffect ) and ( IsActive collectedEffect ) 
			then ( return #( "fail", 4, #( "ATTN: '"+ (collectedEffect as string) +"' is enabled, not advised if rendering using vray hair." ) , chkMessage ) )
		)

		return #("pass", 0,"0", chkMessage )
	),

	function getMissingPluginsChk =
	(
		results = #()
		chkMessage = "IC: Checked to make hair farm is not rendering as an render effect"

		missingInstances = LPM_deadlineInfo.plugins_missingInstances

		for missingClassInstances in missingInstances do 
		(
			result = (  " '" + missingClassInstances[1] + "'  has " + ( ( missingClassInstances.count - 1 ) as string ) + " missing instances "  ) --( "\" " + (cam.name) + " \"  has multipass enabled! ")
			join results #( result )
		)

		if results.count >= 1
		then
		(
			return #("fail", 2, results, chkMessage )
		)

		return #("pass", 0,"0", chkMessage )
	),

	function normalBump_check =
	(

		chkMessage = "IC: Checked for any Normal_Bump texturemap instances"

		results = #()
		nb_instances = #()
		nb_instances = getClassInstances Normal_Bump 


		if nb_instances.count > 0
		then
		(
			result = (  " There are " + ( nb_instances.count as string ) + " instances of the Normal_Bump texturemap, it should be switched to a vray normal map"  ) 
			join results #( result )

			return #("fail", 2, results, chkMessage )
		)

	 	return #("pass", 0,"0", chkMessage )
	),

	function renderLockedView =
	(

		chkMessage = "IC: Checked if rendereing a locked viewport"
		results = #()

		if rendUseActiveView == false
		then
		(

			result = (  " A locked view is set to render, this will be unlocked to ensure the correct camera is being rendered"  )
			join results #( result )

			return #("fail", 2, results, chkMessage )
		)

	 	return #("pass", 0,"0", chkMessage )
	),

 	function renderHiddenLights =
 	(

	 	results = #()
	 	chkMessage = "IC: Checked if rendereing hidden lights disabled"
	 	re = renderers.current 
		
		-- TryCatch because this is a VRAY Property that will fail on non-vray renders
		try(
			if re.options_hiddenLights == false 
			then 
			(
				result = (  " Hidden lights are disabled and will not render, this is not advised"  )
				join results #( result )

				return #("fail", 2, results, chkMessage )
			)
		)catch()

	  	return #("pass", 0,"0", chkMessage )

 	),

	function checkAssetsAreInProject =
	(
		-- Setup
		chkMessage = "IC: Checked if all references are in the current project"
		sceneAssets = #()
		curFileParts = (filterString maxFilePath @"\")
		outList = #()
		str = ""

		-- Get the project folder
		for i in 1 to curFileParts.count do
		(
			if curFileParts[i] == "Projects" or curFileParts[i] == "Pitches" then
			(
				for j in 1 to i do
				(
					str = str + curFileParts[j] + @"\"
				)
			
				str = ( str + curFileParts[ ( i + 1 ) ] )
				exit
			)
			else ( str = "" )
		)

		-- collect all referenced things in the scene
		curProjectDir = str
		ATSOps.Refresh() 
		ATSOps.getFiles &sceneAssets 

		-- Check if the assets match the project 
		for sceneAsset in sceneAssets do 
		(
			if curProjectDir == ( substring sceneAsset 1 curProjectDir.count) 
			then ()
			else
			(
				-- Exceptions test, below add any test to permit an asset through
				skip = false 

				if sceneAsset == "D:\\tmp.exr" then ( skip = true )
				if ( ( filenameFromPath sceneAsset ) == "1.exr" ) then ( skip = true )

				-- if the asset is skippable, it will not flag an error
				if ( skip == false ) then ( append outList sceneAsset )
			)
		)

		if outList.count > 0 then
		(
			return #("fail", 5, #(outList.count as string + " Files not in Project"), chkMessage)
		)

		return #("pass", 0,"0", chkMessage )
	)
)

-- SMTDIdiotCheckObj = SMTDIdiotCheck()
-- SMTDIdiotCheckObj.getMissingPluginsChk()
