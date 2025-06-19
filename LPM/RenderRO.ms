rollout LPM_RenderRo "Output Dialog" width:500 height:220
(
	GroupBox 		grp_output 				"Options" 		pos:[5,5] width:490 height:120

	label 			lab_directory 			"Directory:" 	pos:[10,25]
	dotNetControl 		edt_directoryText   "System.Windows.Forms.TextBox" pos:[60  ,lab_directory.pos[2]-2] width:385 height:20
	button 				btn_directoryPick 	"Set" 			pos:[447 ,lab_directory.pos[2]-2] width:20 height:19
	button 				btn_directoryOpen 	"..." 			pos:[468 ,lab_directory.pos[2]-2] width:20 height:19

	label 			lab_filename 			"Filename:" 	pos:[13  ,50] 
	dotNetControl 		edt_filenameText 	"System.Windows.Forms.TextBox" pos:[60  ,lab_filename.pos[2]-2] width:370 height:20
	label 				lab_extension 		"####.ext" 		pos:[432 ,lab_filename.pos[2]] width:55 height:16
	dropdownList 		ddl_addToken 		"" 				pos:[edt_filenameText.pos[1],70] width:290 height:21 items:#(@"Add Token", @"\ = Directory", @"$Cam = Camera", @"$Max = Max Filename", @"$Pass = Pass Name", @"$Shot = Shot Name", @"$Date = Current date", @"$RDate = YYYY.MM.DD")
	button 				btn_resetFilename 	"Reset" 		pos:[ddl_addToken.width + ddl_addToken.pos[1],ddl_addToken.pos[2]] width:75 height:21

	label 			lab_filetype 			"Filetype:" 	pos:[12,100] height:20
	edittext 			edt_filetype 		"" 				pos:[60  ,lab_filetype.pos[2]-2] width:48 height:20 enabled:true readOnly:true	
	button 				btn_filetypePick 	"Pick" 			pos:[110  ,lab_filetype.pos[2]-2] width:40 height:20
	label 				lab_vrayExr 		"NOTE: V-Ray Renders always revert to .EXR" pos:[160  ,lab_filetype.pos[2]+1] height:20 enabled:false

	GroupBox 		grp_preview 			"Preview" 		pos:[5,130] width:490 height:80
		dotNetControl 	rtb_preview 		"System.Windows.Forms.RichTextBox" pos:[10,grp_preview.pos[2]+15] width:480 height:60

	fn updatePathPreview=
	(
		-- Bring in the output path functions
		output_pathFunctions 	= output_pathFunctionsStr()

		-- Update the various ui items
		rtb_preview.text 		= output_pathFunctions.genPreviewOutput()
		edt_directoryText.text 	= LPM_Root.rootDir
		edt_filenameText.text 	= LPM_Root.pathString
		edt_filetype.text 		= LPM_Root.fileType
	)

	on edt_directoryText TextChanged do
	(
		LPM_Root.rootDir = edt_directoryText.text
		updatePathPreview()
	)

	on edt_filenameText TextChanged do
	(
		LPM_Root.pathString = edt_filenameText.text
		updatePathPreview()
	)

	on btn_directoryOpen pressed do
	(
		shellLaunch LPM_Root.rootDir ""
	)

	on btn_resetFilename pressed do
	(
		LPM_Root.pathString="$Shot\\$Pass\\$Pass"
		updatePathPreview()
	)

	on ddl_addToken selected picked do
	(
		selectedString = ddl_addToken.items[picked]
		case selectedString of 
		(
			@"\ = Directory" : LPM_Root.pathString+="\\"
			@"$Cam = Camera" : LPM_Root.pathString+="$Cam"	
			@"$Max = Max Filename" : LPM_Root.pathString+="$Max"
			@"$Pass = Pass Name" : LPM_Root.pathString+="$Pass"
			@"$Shot = Shot Name" : LPM_Root.pathString+="$Shot"
			@"$Date = Current date" : LPM_Root.pathString+="$Date"
			@"$RDate = YYYY.MM.DD" : LPM_Root.pathString+="$RDate"
		)
		ddl_addToken.selection=1
		updatePathPreview()
	)

	on LPM_RenderRo open do
	(
		rtb_preview.BackColor = (dotNetClass "System.Drawing.Color").FromArgb 50 50 50
		rtb_preview.ForeColor = (dotNetClass "System.Drawing.Color").White
		rtb_preview.Font = dotNetObject "System.Drawing.Font" "Consolas" 8.5
		rtb_preview.ReadOnly = true

			-- Style both dotNet text boxes
		edt_directoryText.BackColor = (dotNetClass "System.Drawing.Color").FromArgb 60 60 60
		edt_directoryText.ForeColor = (dotNetClass "System.Drawing.Color").White
		edt_filenameText.BackColor = (dotNetClass "System.Drawing.Color").FromArgb 60 60 60
		edt_filenameText.ForeColor = (dotNetClass "System.Drawing.Color").White

		if maxfilepath != "" then
		(
			ProjRenderPath = LPM_Root.rootDir
			if ProjRenderPath != "" then LPM_Root.rootdir = ProjRenderPath
		)
		updatePathPreview()
	)

	on btn_directoryPick pressed do
	(
		LPM_Fun.pickOutputRoot()
		updatePathPreview()
	)

	on btn_filetypePick pressed do
	(
		thePath = getBitmapSaveFileName caption:"Enter the File Type" filename:("XXX." + LPM_Root.fileType)
		if thePath != undefined then
		(
			theType = getFilenameType thePath
			if theType != "" then
			(
				theType = substring theType 2 -1
				LPM_Root.fileType = theType
				edt_filetype.text = theType
			)
		)

	updatePathPreview()
	
	)
)

createDialog LPM_RenderRo pos:(LPM_Fun.getRoPos LPM_RenderRo.width)