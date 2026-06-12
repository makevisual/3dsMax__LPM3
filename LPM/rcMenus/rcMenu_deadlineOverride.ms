rollout deadlinePropsRoll "Deadline override 1.0" width:370 height:558
(
	local theNode = undefined
	
	checkbox chk_priorityOn "" pos:[12,12]
		groupbox grp_Priority "Priority" width:325 height:45 slign:#left offset:[21,-25] enabled:false
			checkbox chk_priorityOffsetOn "Priority Offset:" slign:#left offset:[30, ( ( grp_Priority.height * -1 ) + 14 ) ] enabled:false
				spinner spn_priorityOffset "" type:#integer range:[-100,100,0] align:#left offset:[120,-20] width:40 enabled:false
			checkbox chk_priorityAbspoluteOn "Priority Absolute:" slign:#left offset:[185, -21 ] enabled:false
				spinner spn_priorityAbsolute "" type:#integer range:[-100,100,0] align:#left offset:[290,-20] width:40 enabled:false
	
	checkbox chk_renderTicks "" pos:[12,62]
		groupbox grp_renderTicks "Render Ticks" width:325 height:45 slign:#left offset:[21,-25] enabled:false
				spinner spn_renderTicksMult "FPS Multiplier" type:#integer range:[1,10000,1] align:#left offset:[35, ( ( grp_renderTicks.height * -1 ) + 14 ) ]  width:60 enabled:false
			

	checkbox chk_TasksOn "" pos:[12,112]
		groupbox grp_Tasks "Tasks" width:325 height:45 slign:#left offset:[21,-25] enabled:false
			spinner spn_taskSize "Task Size: " type:#integer range:[1,9999,1] align:#left width:60 offset:[35, ( ( grp_Tasks.height * -1 ) + 14 ) ] enabled:false

	checkbox chk_GroupOn "" pos:[12,162]
		groupbox grp_Group "Group" width:325 height:50 slign:#left offset:[21,-25] enabled:false
	 		dropdownlist ddl_group "" items:#("") align:#left width:300 offset:[35, ( ( grp_Group.height * -1 ) + 14 ) ] enabled:false

	checkbox chk_LimitsOn "" pos:[12,217]
		groupbox grp_Limits "Limits" width:325 height:285 slign:#left offset:[21,-25] enabled:false
			multilistbox mlt_theLimitGroups "" items:#() height:8 width:300 align:#left offset:[35, ( ( grp_Limits.height * -1 ) + 14 ) ] enabled:false
	 		button btn_LimitAdd @"Add" align:#left width:150 offset:[35,0] enabled:false
	 		button btn_LimitRemove @"Remove" align:#left width:150 offset:[185,-26] enabled:false
	 		multilistbox mlt_setLimitGroups "" items:#() height:8 width:300 align:#left offset:[35, 0 ] enabled:false

	 groupbox grp_repositoryOptions "Deadline Repository ( Connecting... )" width:350 height:45 pos:[10,505]
		label lab_repository @" Connecting..." height:18 style_sunkenedge:true width:325 align:#left offset:[10, ( ( grp_repositoryOptions.height * -1 ) + 14 ) ]

	fn priorityRadioToggle arg_Checkbox = 
	(
		case arg_Checkbox of 
		(
			"Offset":(
			chk_priorityAbspoluteOn.checked = false 
			spn_priorityAbsolute.enabled = false
			chk_priorityOffsetOn.checked = true
			spn_priorityOffset.enabled = true
			)

			"Absolute":(
			chk_priorityAbspoluteOn.checked = true
			spn_priorityAbsolute.enabled = true
			chk_priorityOffsetOn.checked = false
			spn_priorityOffset.enabled = false
			)
		)
	)

	fn toggleState = 
	(
		state = chk_priorityOn.checked
			priorityRadioToggle "Offset"
			grp_Priority.enabled = state
			chk_priorityOffsetOn.enabled = state
			spn_priorityOffset.enabled = state
			chk_priorityAbspoluteOn.enabled = state
			spn_priorityAbsolute.enabled = state

		state = chk_TasksOn.checked 
			grp_Tasks.enabled = state
			spn_taskSize.enabled = state

		state = chk_GroupOn.checked
			grp_Group.enabled = state
			ddl_group.enabled = state

		state = chk_LimitsOn.checked
			grp_Limits.enabled = state
			mlt_theLimitGroups.enabled = state
			btn_LimitAdd.enabled = state
			btn_LimitRemove.enabled = state
			mlt_setLimitGroups.enabled = state
			
		state = chk_renderTicks.checked
			grp_renderTicks.enabled = state
			spn_renderTicksMult.enabled = state
	)

	fn deadline_GetRepo = 
	(
		-- This used to be hard coded, now it runs off of the deadline ini file
		Environment 			= dotNetClass "System.Environment"
		PROGRAMDATA 			= Environment.GetEnvironmentVariable "PROGRAMDATA"
		deadline_ini = ( PROGRAMDATA + @"\Thinkbox\Deadline10\deadline.ini" )
		if doesFileExist deadline_ini then ( deadlineRepo = ( getinisetting deadline_ini "Deadline" "NetworkRoot" ) )

		return deadlineRepo
	)

	fn deadline_ConnectRepo =
	(
		repository = deadline_GetRepo()
		flag = false 

		if repository != ""
		then
		(
			fnScript = ( repository + @"\submission\3dsmax\Main\SubmitMaxToDeadline_Functions.ms" )

			if doesFileExist fnScript then
			(
				try(destroydialog repositoryConnectDialog )catch()

				rollout repositoryConnectDialog "Establishing Repository Connection" width:550 height:50
				(
					label lab1 "Establishing Repository Connection" offset:[0,8]
 					label lab2 "Connecting..." offset:[0,-5]
 					label lab3 "" offset:[0,-5]
				)

				createdialog repositoryConnectDialog
				repositoryConnectDialog.lab1.text 	= ( "Loading: " + ( getfilenamefile fnScript ) )
				repositoryConnectDialog.lab2.text 	= ( "" + ( fnScript ) )
 				repositoryConnectDialog.lab1.enabled = false
				repositoryConnectDialog.lab1.enabled = true
				fileIn fnScript quiet:true
			
				flag=true
			)
		)

		if(flag==false)
		then
		(
			grp_repositoryOptions.text = "Deadline Repository ( Not connected ) "
			lab_repository.text = " None Found! "

		)
		else
		(
			grp_repositoryOptions.text = "Deadline Repository ( Connected ) "
			lab_repository.text = (" " + repository )
			destroydialog repositoryConnectDialog
		)
	)

	fn deadline_GetGroups arg_CP =
	(
		cp = arg_CP

		SMTDFunctions.CollectGroups()
		ddl_group.items = SMTDSettings.Groups

		curGroup = cp.submitGroup

		for i in 1 to SMTDSettings.Groups.count do 
		(
			if SMTDSettings.Groups[i] == curGroup 
			then 
			(
				ddl_group.selection = i 
			)
		)
	)

	fn deadline_GetLimits arg_CP = 
	(
		cp = arg_CP
		newLimits = #()

		SMTDFunctions.CollectLimitGroups()
		mlt_theLimitGroups.items = SMTDSettings.LimitGroups

 		curLimits = cp.submitLimits

		for i in curLimits do join newLimits #(i)

		mlt_setLimitGroups.items = newLimits
	)

	fn limit_add =
	(
		curSel = mlt_setLimitGroups.items 

		for sel in mlt_theLimitGroups.selection do 
		(
			appendIfUnique curSel mlt_theLimitGroups.items[sel]
		)

		mlt_setLimitGroups.items = curSel
	)

	fn smallerNumber a b =
	(
		if (a>b)
		then(return -1)
		else(return 1)
	)

	fn limit_remove =
	(
		curItems = mlt_setLimitGroups.items
		selArray = #()
		for sel in mlt_setLimitGroups.selection do join selArray #(sel)

		qsort selArray smallerNumber

		for sel in selArray do 
		(
			deleteItem curItems sel
		)
		
		mlt_setLimitGroups.items = curItems
	)

	on chk_priorityOffsetOn changed state do 
	(
		if state
		then ( priorityRadioToggle "Offset" )
		else ( priorityRadioToggle "Absolute" )
	)

	on chk_priorityAbspoluteOn changed state do 
	(
		if state
		then ( priorityRadioToggle "Absolute" )
		else ( priorityRadioToggle "Offset" )
	)

	on btn_LimitAdd pressed do 
	(
		limit_add()
	)

	on btn_LimitRemove pressed do 
	(
		limit_remove()
	)

	on chk_priorityOn changed state do toggleState()
	on chk_TasksOn changed state do toggleState()
	on chk_GroupOn changed state do toggleState()
	on chk_LimitsOn changed state do toggleState()
	on chk_renderTicks changed state do toggleState()
	on deadlinePropsRoll open do
	(
 		LPM_treeview_rollout.tv.enabled=false
 		local cp=LPM_treeview_rollout.tv.selectedNode.tag.value
 		theNode=LPM_treeview_rollout.tv.selectedNode

		deadline_ConnectRepo()
		deadline_GetLimits cp
		deadline_GetGroups cp

		chk_priorityOn.checked 					=cp.priorityOn 				
			chk_priorityOffsetOn.checked 		=cp.priorityOffsetOn		
			spn_priorityOffset.value 			=cp.priorityOffset 		
			chk_priorityAbspoluteOn.checked 	=cp.priorityAbsoluteOn	
			spn_priorityAbsolute.value 			=cp.priorityAbsolute 	

		chk_TasksOn.checked 					= cp.taskSizeOn 	
			spn_taskSize.value 					= cp.taskSize 

		chk_GroupOn.checked 					= cp.submitGroupOn 			
		chk_LimitsOn.checked 					= cp.submitLimitsOn
		
		chk_renderTicks.checked 				= cp.renderTicks
		spn_renderTicksMult.value 				= cp.renderTicksMult
		
		toggleState()

			-- Fixing for override
			chk_priorityOffsetOn.checked 		=cp.priorityOffsetOn		
			spn_priorityOffset.value 			=cp.priorityOffset 		
			chk_priorityAbspoluteOn.checked 	=cp.priorityAbsoluteOn	
			spn_priorityAbsolute.value 			=cp.priorityAbsolute 	
 	)
	
	on deadlinePropsRoll close do
	(
		setFocus deadlinePropsRoll
		cp=theNode.tag.value
		
		cp.priorityOn 				= chk_priorityOn.checked
			cp.priorityOffsetOn		= chk_priorityOffsetOn.checked
			cp.priorityOffset 		= spn_priorityOffset.value
			cp.priorityAbsoluteOn	= chk_priorityAbspoluteOn.checked
			cp.priorityAbsolute 	= spn_priorityAbsolute.value

		cp.taskSizeOn 				= chk_TasksOn.checked
			cp.taskSize 			= spn_taskSize.value

		cp.submitGroupOn 			= chk_GroupOn.checked
			cp.submitGroup 			= ddl_group.selected

		cp.submitLimitsOn 			= chk_LimitsOn.checked
			cp.submitLimits 		= mlt_setLimitGroups.items	
			
			
		cp.renderTicks				= chk_renderTicks.checked
		cp.renderTicksMult			= spn_renderTicksMult.value
					
		theNode.text = LPM_Fun.generateDeadlineName cp
		LPM_treeview_rollout.tv.enabled=true
	)
)

rcMenu rc_deadlinePropsMenu
(
	menuItem	editProps	"Edit"
	menuItem 	copyProps 	"Copy"
	menuItem   	removeProps "Remove"
	
	on copyProps picked do
	(
		LPM_treeview_rollout.copyNode=LPM_treeview_rollout.tv.selectedNode.tag.value
	)
	
	on removeProps picked do
	(
		theNode=LPM_treeview_rollout.tv.selectedNode.tag.value
		delete theNode
		LPM_treeview_rollout.tv.selectedNode.remove()
	)
	on editProps picked do
	(		
		createDialog deadlinePropsRoll pos:(LPM_Fun.getRoPos  vrayPropsRoll.width)
	)
	
)
--createDialog deadlinePropsRoll pos:(LPM_Fun.getRoPos  vrayPropsRoll.width)