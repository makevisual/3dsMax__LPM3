(
	local du = DeadlineUtil --this is the interface exposed by the Lightning Plug-in which provides communication between Deadline and 3ds Max
	if du == undefined do --if the script is not being run on Deadline (for testing purposes),
	(
		struct DeadlineUtilStruct --define a stand-in struct with the same methods as the Lightning plug-in
		(
			fn SetTitle title = ( format "Title: %\n" title ),
			fn SetProgress percent = (true),
			fn FailRender msg = ( throw msg ),
			fn GetSubmitInfoEntry key = ( undefined ),
			fn GetSubmitInfoEntryElementCount key = ( 0 ),
			fn GetSubmitInfoEntryElement index key = ( undefined ),
			fn GetJobInfoEntry key = ( undefined ),
			fn GetAuxFilename index = ( undefined ),
			fn GetOutputFilename index = ( undefined ),
			fn LogMessage msg = ( format "%\n" msg ),
			fn WarnMessage msg = ( format "Warning: %\n" msg ),
			CurrentFrame = ((sliderTime as string) as integer),
			CurrentTask = ( -1 ),
			SceneFileName = ( maxFilePath + maxFileName ),
			SceneFilePath = ( maxFilePath ),
			JobsDataFolder = ( "" ),
			PluginsFolder = ( "" )
		)
		du = DeadlineUtilStruct() --create an instance of the stand-in struct
	)--end if
	
	du.SetTitle "tickRender Job" --set the job title 
	du.LogMessage "Starting MAXScript Job..." --output a message to the log
	local st = timestamp() --get the current system time
		
	--
	timedisplaymode=#frameTicks	
	outFileNameNoExt = ""
	for x = 1 to rendOutputFilename.count do
	(
		if rendOutputFilename[x] == "." then exit
		
		outFileNameNoExt += rendOutputFilename[x]
	)
	renderTicksMult = rendNthFrame as float --value stored here during pass kickoff

	theCurrentTime = DeadlineUtil.CurrentFrame

	convertedTime = theCurrentTime / renderTicksMult
	sliderTime = convertedTime
	currentime = convertedTime
		
	numberstring = (theCurrentTime as string)		
	for j in (numberstring.count + 1) to 5 do
	(
		numberstring = "0" + numberstring
	)
	
	fname = outFileNameNoExt + "." + numberstring + ".exr"
	badname = outFileNameNoExt + "." + numberstring
	
	
	rendSaveFile = false	
	renderers.current.output_rawFileName = fname
	rendOutputFilename = fname
		
	du.LogMessage (
	
	"Rendering frame: " + "t: [" + theCurrentTime as string + 
	"] convertedT: [" + (convertedTime as string) + 
	"] renderTicksMult: [" + renderTicksMult as string + 
	"] fname: [" + rendOutputFilename + 
	"] raw: [" + renderers.current.output_rawFileName + 
	"]"
	
	)	
	
	render frame:convertedTime
	
	--IMPORTANT:
	--deadline will save the files using convertedTime (passed to the render function 'frame' argument) as the file number
	--but that's incorrect...and we've baked the proper file number into the filename, so rename accordingly
	
	du.LogMessage ("Searching for files to rename: " + (badname + "*.*"))
	
	badfiles = getfiles (badname + "*.*")
	for badfile in badfiles do
	(
		du.LogMessage ("Found file to rename: " + badfile)
	
		badExt = badfile.count
		dotCount = 0
		for j in badfile.count to 1 by -1 do
		(
			if badfile[j] == "." then 
			(
				dotCount += 1
				
				if (dotCount == 2) then
				(
					badExt = j - 1
				)
			)
		)
			
		if (badExt != badfile.count) then
		(
			goodfile = ""
			for j in 1 to badExt do
			(
				goodfile += badfile[j]
			)
			goodfile += ".exr"
			
			du.LogMessage ("Rename: [" + badfile +"] to [" + goodfile + "]")
			
			renameFile badfile goodfile
		)
		
	)
	
	du.LogMessage ("Finished tickRender Job in "+ ((timestamp() - st)/1000.0) as string + " sec.") --output the job duration
	true--return true if the task has finished successfully, return false to fail the task.
)--end script