-- Rollout and utilities to set or retrieve the deadline repository from the environment, or from a manual override.

rollout LPM_RenderRo "Deadline Settings Dialog" width:400 height:150
(
	GroupBox 			grp_options 		"Options" 							pos:[5,5] width:390 height:140

	checkbox  			chk_automatic 		"Automatically Detect Repository ( reccomended )"	pos:[grp_options.pos[1]+10,grp_options.pos[1]+20]
		dotNetControl 	rtb_automaticDir   	"System.Windows.Forms.TextBox" 						pos:[chk_automatic.pos[1]+20  ,chk_automatic.pos[2]+20] width:345 height:20
	
	checkbox  			chk_manual 			"Manually Set Repository"							pos:[chk_automatic.pos[1],chk_automatic.pos[1]+60]
		dotNetControl 	rtb_manualDir   	"System.Windows.Forms.TextBox" 						pos:[chk_manual.pos[1]+20  ,chk_manual.pos[2]+20] width:345 height:20	
		button 			btn_directoryPick 	"Set" 												pos:[chk_manual.pos[1]+20 ,chk_manual.pos[2]+40] width:60 height:19
		button 			btn_directoryOpen 	"Open" 												pos:[chk_manual.pos[1]+20+btn_directoryPick.width ,chk_manual.pos[2]+40] width:60 height:19

	-- Gets a manual path, if one has not been set, returns the LPM Root dir
	fn getDeadlineManualPath = 
	(
		if LPM_Root.deadlinePathManual != undefined
		then (return LPM_Root.deadlinePathManual)
		else (return LPM_Root.rootDir)	
	)

	-- Retrieves the deadline environment variable - set through deadline monitor
	fn getDeadlineAutomaticPath =
	(
		return LPM_FunDeadline.deadline_GetRepoPath()
--		return (dotNetClass "System.Environment").GetEnvironmentVariable "DEADLINE_CUSTOM_PATH"
	)

	-- Set all UI and Data properties if the automatic repository is chosen
	fn setRepositoryAutomatic =
	(
		-- Update Data
		LPM_Root.deadlinePathManualEnabled 	= false 									-- Set override enabled / disabled
		LPM_Root.deadlinePath 				= LPM_FunDeadline.deadline_GetRepoPath()	-- Gets the automatic Deadline Path

		-- Update UI
		chk_automatic.checked 				= true
		chk_manual.checked 					= false
		rtb_automaticDir.ForeColor 			= (dotNetClass "System.Drawing.Color").White
		rtb_manualDir.ForeColor 			= (dotNetClass "System.Drawing.Color").Gray
		btn_directoryPick.enabled			= false
		btn_directoryOpen.enabled			= false
		rtb_automaticDir.text 				= LPM_Root.deadlinePath

		print(LPM_Root.deadlinePath)
	)

	-- Set all UI and Data properties if the manual repository is chosen
	fn setRepositoryManual =
	(
		-- Update Data
		LPM_Root.deadlinePathManualEnabled 	= true 							-- Set override enabled / disabled
		LPM_Root.deadlinePath 				= getDeadlineManualPath() 	-- Set the acutal path to the override value

		-- Update UI
		chk_automatic.checked 				= false
		chk_manual.checked 					= true
		rtb_automaticDir.ForeColor 			= (dotNetClass "System.Drawing.Color").Gray
		rtb_manualDir.ForeColor 			= (dotNetClass "System.Drawing.Color").White
		btn_directoryPick.enabled			= true
		btn_directoryOpen.enabled			= true
		rtb_manualDir.text 					= LPM_Root.deadlinePath

		print(LPM_Root.deadlinePath)
	)

	-- Treat the checkboxes like radio buttons
	fn toggleCheckboxes arg_enabled =
	(
		if arg_enabled == "automatic" 	then(if chk_automatic.checked 	== true then (setRepositoryAutomatic())else(setRepositoryManual()))
		if arg_enabled == "manual"		then(if chk_manual.checked 		== true then (setRepositoryManual())else(setRepositoryAutomatic()))
	)

	-- Prompts user to pick a deadline repository, returns safe directory if no valid one is chosen	
	fn directoryPick =
	(
		thePath=getSavePath caption:"Pick Deadline repository" initialDir:LPM_Root.rootDir
		if(thePath!=undefined) then
		(
			LPM_Root.deadlinePathManual=thePath+"\\"
			return LPM_Root.deadlinePathManual
		)
		return LPM_Root.rootDir
	)

	-- Triggers update logic for the manual / automatic choice 
	on chk_automatic changed state 	do ( toggleCheckboxes "automatic")

	-- Triggers update logic for the manual / automatic choice
	on chk_manual changed state 	do ( toggleCheckboxes "manual" )

	-- Opens the manual directory
	on btn_directoryOpen pressed 	do ( shellLaunch LPM_Root.deadlinePathManual "" )

	-- Prompts user to pick the manual directory, and updates the UI
	on btn_directoryPick pressed do
	(
		directoryPick() 					-- Pick a directory
		setRepositoryManual() 				-- Update the UI
	)

	-- On open, update some .net interfaces, load stored values, and set the UI to appropriate state
	on LPM_RenderRo open do
	(

		-- Style both dotNet text boxes
		rtb_automaticDir.BackColor 			= (dotNetClass "System.Drawing.Color").FromArgb 50 50 50
		rtb_automaticDir.ForeColor 			= (dotNetClass "System.Drawing.Color").White
		rtb_automaticDir.Font 				= dotNetObject "System.Drawing.Font" "Consolas" 8.5
		rtb_automaticDir.ReadOnly 			= true

		rtb_manualDir.BackColor 			= (dotNetClass "System.Drawing.Color").FromArgb 50 50 50
		rtb_manualDir.ForeColor 			= (dotNetClass "System.Drawing.Color").White
		rtb_manualDir.Font 					= dotNetObject "System.Drawing.Font" "Consolas" 8.5
		rtb_manualDir.ReadOnly 				= true

		-- Set the text boxes values
		rtb_automaticDir.text 	= getDeadlineAutomaticPath()
		rtb_manualDir.text 		= getDeadlineManualPath()

		-- Set the properties / interfaces based on stored setting
		if LPM_Root.deadlinePathManualEnabled == false 	then (setRepositoryAutomatic())
		if LPM_Root.deadlinePathManualEnabled == true 	then (setRepositoryManual())
	)
)

createDialog LPM_RenderRo pos:(LPM_Fun.getRoPos LPM_RenderRo.width)