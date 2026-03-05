struct output_pathFunctionsStr 
(
	-- Genereates the output filepath and stores it on the root
	function genDefaultOutput =
	(

		fullFilePath 			= " "
		fullFilePath 			+= LPM_Root.rootDir
		fullFilePath 			+= LPM_Root.pathString
		fullFilePath 			+= "."
		fullFilePath 			+= LPM_Root.fileType

		LPM_Root.fullOutputPath = fullFilePath
	),

	-- Return the fully frame padded preview of the output
	function genPreviewOutput =
	(

		genDefaultOutput()

    	thePath=getFilenamePath LPM_Root.fullOutputPath
    	theFile=getFilenameFile LPM_Root.fullOutputPath
    	theType=getFilenameType LPM_Root.fullOutputPath

		previewFilePath = ( thePath + theFile + ".####" + theType )

		return previewFilePath
	)
)

---- For Testing ----
-- output_pathFunctions = output_pathFunctionsStr()
-- output_pathFunctions.genPreviewOutput()