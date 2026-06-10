global SMTDSettings, SMTDFunctions, SMTDIdiotCheck, SMTDLPMInterface, LPM_deadlineInfo

-- This used to only be a part of the LPM Deadline submitter, but now it is making its way around a bit more, need to figure out a better solution
-- Currently it in Deadline10.0.ms in LPM and P4DS_deadlineInfoClass.ms 
struct LPM_deadlineInfoStr
(
	submit_enable 					= true,
	submit_recoveryHold 			= undefined,
	submit_viewToRenderLock 		= undefined,
	submit_timeStamp 				= undefined,
	ic_failCount					= 0,
	ic_failCritical					= false,
	dl_NetworkRoot 					= "",
	dl_fnScript 					= "",
	dl_icScript 					= "",
	dl_groups 						= #(),
	dl_groupChosen 					= "",
	dl_limits 						= #(),
	dl_limitsChosen 				= #(),
	dl_user 						= "",
	dl_jobName 						= "",
	dl_jobComment 					= "",
	dl_batchName 					= "",
	dl_priority 					= 50,
	dl_interruptible 				= false,
	dl_interruptiblePercentage 		= 50,
	dl_taskTimeoutEnabled 			= true,
	dl_taskTimeoutSeconds 			= "300",
	draft_templatesDir 				= "",
	draft_templates 				= #(),
--	draft_templateChosen 			= "",
	draft_templateNames 			= #(),
	sticky_holdOnSubmit 			= false,
	sticky_frameBufferMode 			= 1,
	sticky_frameBufferMode_HOLD		= 1,
	frameBuffer_Renderer_Check		= "",
	sticky_renderElementsExr	 	= true,
	sticky_renderElementsExr_HOLD 	= undefined,
	sticky_submitAsSuspended 		= false,
	framerange_overrideEnabled  	= false,
	framerange_overrideRange 		= #(0,100),
	framerange_overrideRange_HOLD	= #(0,0),
	optimize_enabled 				= false,
	optimize_restoreData 			= #(),
	plugins_missingClasses			= #(),
	plugins_missingInstances		= #()
)

LPM_deadlineInfo = LPM_deadlineInfoStr()

Environment 			= dotNetClass "System.Environment"
PROGRAMDATA 			= Environment.GetEnvironmentVariable "PROGRAMDATA"
DLini = ( PROGRAMDATA + @"\Thinkbox\Deadline10\deadline.ini" )

-- Back to hard coded because of locked and bad ini file from aws thinkbox
LPM_deadlineInfo.dl_NetworkRoot = LPM_Root.deadlinePath

-- This used to be hard coded, now it runs off of the deadline ini file
LPM_deadlineInfo.dl_fnScript = ( LPM_deadlineInfo.dl_NetworkRoot + @"\submission\3dsmax\Main\SubmitMaxToDeadline_Functions.ms" )

-- Idiot Check used to be in the repository, now it has been moved into the LPM directory proper
LPM_deadlineInfo.dl_icScript = (LPM_Dir + "SubmitMaxToDeadline_IdiotCheck.ms" )
LPM_deadlineInfo.draft_templatesDir = ( LPM_deadlineInfo.dl_NetworkRoot + @"\events\DraftEventPlugin\MAKE_Templates\" )

struct LPM_DeadlineAPI
(
	type="Deadline10.0",

	fn submit=
	(
		rollout LPM_DeadlineSubmitRo "Deadline10.0 Submitter" width:315 height:210
		(

			GroupBox grp_jobProperties "Job Properties" pos:[6,6] width:304 height:105																												visible:false
 				label lab_CustomName 						"  Name: "  					align:#left height:15 width:77 									offset:[0 , ( ( grp_jobProperties.height * -1 )  + 15 ) ] 		visible:false
	  			edittext lab_CustomNameField 				""  							align:#left width:230 											offset:[60,-21 ]												visible:false
 				label lab_CustomComment 					"  Comment: "  					align:#left height:15 width:77									offset:[0, 0 ]  												visible:false
				edittext lab_CustomCommentField 			""  							align:#left	width:230											offset:[60,-21 ]												visible:false
				
 				label lab_CustomBatch 						"  Batch: "  					align:#left height:15 width:77									offset:[0, 0 ] 													visible:false
				edittext lab_CustomBatchField 				""  							align:#left width:230 											offset:[60,-21 ]												visible:false
				label lab_DeadlineUser 						"  User: "  					align:#left width:77 											offset:[0, 0 ]													visible:false
	 			label lab_DeadlineUserField 				" Loading User... " 			style_sunkenedge:true  width:225 align:#left height:15 			offset:[64,-21 ]												visible:false

 			GroupBox grp_jobOptions "Job Options" offset:[-7,10] width:304 height:205																																		visible:false
  				label lbl_priority 							"  Priority:" 					align:#left width:100 height:13 								offset:[0, ( ( grp_jobOptions.height * -1 ) + 15 ) ] 			visible:false
	   			progressBar sld_priority 					"" 								align:#left width:182 height:18 range:[0,100,50] type:#integer 	offset:[63,-21 ]												visible:false
   				spinner spn_priority 						"" 								width:47 height:16 type:#integer fieldwidth:35					offset:[1,-22]													visible:false
 				label lbl_group 							"  Group: " 					align:#left height:13 											offset:[0,4]													visible:false
	 			dropdownList ddl_group	 					"" 								align:#left width:118 height:21									offset:[63,-21] 												visible:false
  				button btn_setLimits 						"Set limits" 					align:#left width:88 enabled:true 								offset:[182,-27]												visible:false
	  			button btn_setLimitsClear 					"X" 							align:#left width:20 enabled:true 								offset:[270,-26]												visible:false
				checkbutton btn_submitSuspended 			"      Submit as SUSPENDED " 	align:#left width:291 height:18 								offset:[0, 0 ] 													visible:false
 				dropdownList ddl_SubmitExternalFilesMode 	"" 								width:289 height:21 											offset:[0,0] 													visible:false 			items:#(" Do NOT copy Textures to Repository", " Copy LOCAL Textures to Repository", " Copy ALL Textures to Repository")
				dropdownList ddl_frameBufferMode 			""						 		width:289 height:21 											offset:[0,0] 													visible:false 			items:#(" Use CURRENT frame buffer ", " Use VRAY Frame Buffer ", " Use 3DSMAX Frame Buffer ")
 				checkbox chk_renderElementsExr				" Encode Elements in .EXR" 			checked:true			offset:[-1,-20]		visible:false 	enabled:false
				checkbox chk_IgnoreFiles 					" Ignore Missing External Files"	width:166 height:15 	offset:[-1,0]		visible:false
				checkbox chk_RestartMax 					" Restart 3dsMax between Frames " 	height:15 				offset:[-1,0]		visible:false checked:true
 				checkbox chk_closeOnComplete 				" Close on complete" 				checked:true			offset:[160,-59]	visible:false
  				checkbox chk_IgnoreDLL 						" Ignore Missing DLL(s)"  			height:15				offset:[160,-2]		visible:false

			GroupBox grp_taskOptions "Task Options" offset:[-7,33] width:304 height:115 																																			visible:false
 				checkbox chk_interruptable 				"  Interruptable up to ( in percent ): " 	height:15 checked:false 											offset:[0 , ( ( grp_taskOptions.height * -1 )  + 15 ) ]		visible:false
				spinner spn_interruptablePercent 		"" 											range:[0,100,50] type:#integer width:50 enabled:false				offset:[50,-20]												visible:false
 				checkbox chk_autoStartupTimeout 		"Task Start Timeout ( in seconds ): " 		height:15 checked:true 												offset:[0,0]												visible:false
				spinner spn_autoStartupTimeout 			"" 											range:[60,600,300] type:#integer width:50 							offset:[50,-20]												visible:false
 				label lbl_chunk 						"  Task Chunk Size ( Frames Per Task ):" 	width:211 height:13 align:#left 									offset:[0,3]												visible:false
 				spinner spn_chunkSize 					"" 											width:50 height:16 range:[1,1000,1] type:#integer 					offset:[50,-20]												visible:false
 				dropdownList ddl_OutOfOrderMethod 		"" 											width:200 height:21 												offset:[2,0]												visible:false 		items:#("First To Last (Forward)", "Every Nth, Then Forward", "Every Nth - Block Fill", "Every Nth - Half Raster Refine", "Last To First (Reverse)", "From Both Ends", "From Center", "From Both Ends And From Center", "Random")
 				spinner spn_outOfOrderStep 				"Nth:" 										width:70 height:16 range:[2,1000,10] type:#integer fieldwidth:40 	offset:[3,-25] 	enabled:false								visible:false

 			GroupBox grp_utilities 	"Utilities" 	align:#left width:305 height:90 							offset:[-7,10]																					visible:false
 				button btn_idiotCheck 					"Perform Idiot Check" 			align:#left across:3 height:20 width:294 	offset:[0 , ( ( grp_utilities.height * -1 )  + 15 ) ] 						visible:false
				button btn_removeMissingPlugins 		"Remove Missing Plugins" 		align:#left across:3 height:20 width:144 	offset:[-96 , -55 ] 														visible:false
  				button btn_removeMissingMaps 		"Remove Missing Maps" 			width:149 height:20 align:#left 			offset:[-48,-55]															visible:false
  				button btn_optimizeScene 				"Optimize Scene" 				width:144 height:20 align:#left 			offset:[0,-5]																visible:false
  				checkbutton btn_optimizeSubmit 			"Optimized Submit" 				width:149 height:20 align:#left 			offset:[144,-25]															visible:false

 			GroupBox grp_submit "Submit" offset:[-7,10] width:305 height:106											visible:false
				local bm_idiotCheckRed 		= bitmap 10 28 color:red 													visible:false
				local bm_idiotCheckGreen 	= bitmap 10 28 color:green 													visible:false
				local bm_idiotCheckBlue 	= bitmap 10 28 color:blue 													visible:false
				local bm_idiotCheckOrange 	= bitmap 10 28 color:orange 												visible:false
				checkbutton btn_holdOnSub 	"3Ds Max Hold on submit" 		width:144 height:20 align:#left 			offset:[-1, ( ( grp_submit.height * -1 )  + 15 ) ]										visible:false
				button btn_submitReEval 	"Re-evaluate Submission" 		width:144 height:20 align:#left 			offset:[144,-25]																		visible:false
				imgTag img_idiotcheck_L bitmap:bm_idiotCheckBlue offset:[0,-2]											visible:false
				button btn_submit "<< Please Wait >>" width:270 height:30 offset:[10,-33] align:#left enabled:false 	visible:false
				imgTag img_idiotcheck_R bitmap:bm_idiotCheckBlue offset:[280,-35]  align:#left 							visible:false
 				progressBar prg_submitProgress2 ""  offset:[-1,4] width:292 height:8 color:[0,200,0]					visible:false
  				progressBar prg_submitProgress "" offset:[-1,-4] width:292 height:8 color:[0,0,200]						visible:false

			dotNetControl submitLog "system.windows.forms.RichTextBox" height:170 width:308 pos:[ 3 , 3 ]
			button btn_connectCancel "Cancel" pos:[2,176] width:310 height:30

			-- load sticky settings from the .INI and apply it to the data object
			fn ui_loadStickySettings =
			(
				-- SMTD Settings
				SMTDSettings.Priority 							= LPM_Fun.GetIni "Deadline Settings" "Priority" integer 50
				SMTDSettings.ChunkSize 							= LPM_Fun.GetIni "Deadline Settings" "ChunkSize" integer 1
				SMTDSettings.LimitEnabled 						= LPM_Fun.GetIni "Deadline Settings" "LimitEnabled" booleanClass false
				SMTDSettings.machineLimit 						= LPM_Fun.GetIni "Deadline Settings" "machineLimit" integer 0
				SMTDSettings.OutOfOrderMethod 					= LPM_Fun.GetIni "Deadline Settings" "OutOfOrderMethod" string #normal
				SMTDSettings.OutOfOrderStep 					= LPM_Fun.GetIni "Deadline Settings" "OutOfOrderStep" integer 1
				SMTDSettings.SequentialJob 						= LPM_Fun.GetIni "Deadline Settings" "SequentialJob" booleanClass false
				SMTDSettings.SubmitAsSuspended 					= LPM_Fun.GetIni "Deadline Settings" "SubmitAsSuspended" booleanClass false
				SMTDSettings.IgnoreMissingExternalFiles 		= LPM_Fun.GetIni "Deadline Settings" "IgnoreMissingExternalFiles" booleanClass true
				SMTDSettings.IgnoreMissingDLLs 					= LPM_Fun.GetIni "Deadline Settings" "IgnoreMissingDLLs" booleanClass false

				-- CUSTOM SETTINGS
				LPM_deadlineInfo.sticky_holdOnSubmit 			= LPM_Fun.GetIni "Deadline Settings" "HoldOnSubmit" booleanClass false
				LPM_deadlineInfo.sticky_frameBufferMode			= LPM_Fun.GetIni "Deadline Settings" "FrameBufferMode" integer 1
				LPM_deadlineInfo.sticky_renderElementsExr	 	= LPM_Fun.GetIni "Deadline Settings" "RenderElementsToEXR" booleanClass true
				LPM_deadlineInfo.sticky_submitAsSuspended 		= false 				-- Removed Submit as Suspended as sticky upon user consensus 

				-- UI UPDATES
				spn_chunkSize.value 							= SMTDSettings.ChunkSize
				local theVal 									= findItem #(#normal, #nth, #NthBlock, #NthRasterRefine, #reverse, #fromBothEnds, #FromCenter, #fromBothEndsAndCenter, #random) SMTDSettings.OutOfOrderMethod
				if theVal == 0 do theVal = 1
				ddl_outOfOrderMethod.selection 					= theVal
				btn_submitSuspended.state 						= SMTDSettings.SubmitAsSuspended
				spn_outOfOrderStep.value 						= SMTDSettings.OutOfOrderStep
				ddl_SubmitExternalFilesMode.selection 			= SMTDSettings.SubmitExternalFilesMode
				chk_IgnoreFiles.state 							= SMTDSettings.IgnoreMissingExternalFiles
				chk_IgnoreDLL.state 							= SMTDSettings.IgnoreMissingDLLs
				btn_holdOnSub.checked							= LPM_deadlineInfo.sticky_holdOnSubmit
				LPM_deadlineInfo.submit_recoveryHold			= LPM_deadlineInfo.sticky_holdOnSubmit
				ddl_frameBufferMode.selection 					= LPM_deadlineInfo.sticky_frameBufferMode
				chk_renderElementsExr.checked 					= true
				btn_submitSuspended.checked 					= false
			)

			-- Save sticky settings to the .INI
			fn ui_saveStickySettings =
			(
				-- SMTD Settings
				LPM_Fun.SetIni "Deadline Settings" "Priority" 						SMTDSettings.Priority
				LPM_Fun.SetIni "Deadline Settings" "ChunkSize"						SMTDSettings.ChunkSize
				LPM_Fun.SetIni "Deadline Settings" "LimitEnabled" 					SMTDSettings.LimitEnabled
				LPM_Fun.SetIni "Deadline Settings" "machineLimit" 					SMTDSettings.machineLimit
				LPM_Fun.SetIni "Deadline Settings" "OutOfOrderMethod" 				SMTDSettings.OutOfOrderMethod
				LPM_Fun.SetIni "Deadline Settings" "OutOfOrderStep" 				SMTDSettings.OutOfOrderStep
				LPM_Fun.SetIni "Deadline Settings" "SequentialJob" 					SMTDSettings.SequentialJob
				LPM_Fun.SetIni "Deadline Settings" "SubmitAsSuspended" 				SMTDSettings.SubmitAsSuspended
				LPM_Fun.SetIni "Deadline Settings" "IgnoreMissingExternalFiles" 	SMTDSettings.IgnoreMissingExternalFiles
				LPM_Fun.SetIni "Deadline Settings" "IgnoreMissingDLLs" 				SMTDSettings.IgnoreMissingDLLs
				-- CUSTOM SETTINGS
				LPM_Fun.SetIni "Deadline Settings" "HoldOnSubmit"  					LPM_deadlineInfo.sticky_holdOnSubmit
				LPM_Fun.SetIni "Deadline Settings" "FrameBufferMode"  				LPM_deadlineInfo.sticky_frameBufferMode
				LPM_Fun.SetIni "Deadline Settings" "RenderElementsToEXR"  			LPM_deadlineInfo.sticky_renderElementsExr
				LPM_Fun.SetIni "Deadline Settings" "SubmitAsSuspended"  			LPM_deadlineInfo.sticky_submitAsSuspended
			)

			-- Toggle visibility of the UI items within this function
 			fn ui_visibilityToggle state =
 			(
				LPM_DeadlineSubmitRo.grp_jobProperties.visible = state
					LPM_DeadlineSubmitRo.lab_CustomName.visible = state
					LPM_DeadlineSubmitRo.lab_CustomNameField.visible = state
					LPM_DeadlineSubmitRo.lab_CustomComment.visible = state
					LPM_DeadlineSubmitRo.lab_CustomCommentField.visible = state
					LPM_DeadlineSubmitRo.lab_CustomBatch.visible = state
					LPM_DeadlineSubmitRo.lab_CustomBatchField.visible = state
					LPM_DeadlineSubmitRo.lab_DeadlineUser.visible = state
					LPM_DeadlineSubmitRo.lab_DeadlineUserField.visible = state
				LPM_DeadlineSubmitRo.grp_jobOptions.visible = state
					LPM_DeadlineSubmitRo.lbl_priority.visible = state
					LPM_DeadlineSubmitRo.sld_priority.visible = state
					LPM_DeadlineSubmitRo.spn_priority.visible = state
					LPM_DeadlineSubmitRo.lbl_group.visible = state
					LPM_DeadlineSubmitRo.ddl_group.visible = state
					LPM_DeadlineSubmitRo.btn_setLimits.visible = state
					LPM_DeadlineSubmitRo.btn_setLimitsClear.visible = state
					LPM_DeadlineSubmitRo.btn_submitSuspended.visible = state
					LPM_DeadlineSubmitRo.ddl_SubmitExternalFilesMode.visible = state
					LPM_DeadlineSubmitRo.ddl_frameBufferMode.visible =false -- = state --TODO:Better way to handle this for vray5 pipeline?
					LPM_DeadlineSubmitRo.chk_renderElementsExr.visible = state
					LPM_DeadlineSubmitRo.chk_IgnoreFiles.visible = state
					LPM_DeadlineSubmitRo.chk_RestartMax.visible = state
					LPM_DeadlineSubmitRo.chk_closeOnComplete.visible = state
					LPM_DeadlineSubmitRo.chk_IgnoreDLL.visible = state
				LPM_DeadlineSubmitRo.grp_taskOptions.visible = state
					LPM_DeadlineSubmitRo.chk_interruptable.visible = state
					LPM_DeadlineSubmitRo.spn_interruptablePercent.visible = state
					LPM_DeadlineSubmitRo.chk_autoStartupTimeout.visible = state
					LPM_DeadlineSubmitRo.spn_autoStartupTimeout.visible = state
					LPM_DeadlineSubmitRo.lbl_chunk.visible = state
					LPM_DeadlineSubmitRo.spn_chunkSize.visible = state
					LPM_DeadlineSubmitRo.ddl_OutOfOrderMethod.visible = state
					LPM_DeadlineSubmitRo.spn_outOfOrderStep.visible = state
				LPM_DeadlineSubmitRo.grp_utilities.visible = state
					LPM_DeadlineSubmitRo.btn_idiotCheck.visible = state
					LPM_DeadlineSubmitRo.btn_removeMissingPlugins.visible = state
					LPM_DeadlineSubmitRo.btn_removeMissingMaps.visible = state
					LPM_DeadlineSubmitRo.btn_optimizeScene.visible = state
					LPM_DeadlineSubmitRo.btn_optimizeSubmit.visible = state
					LPM_DeadlineSubmitRo.grp_submit.visible = state
					LPM_DeadlineSubmitRo.btn_holdOnSub.visible = state
					LPM_DeadlineSubmitRo.btn_submitReEval.visible = state
					LPM_DeadlineSubmitRo.img_idiotcheck_L.visible = state
					LPM_DeadlineSubmitRo.btn_submit.visible = state
					LPM_DeadlineSubmitRo.img_idiotcheck_R.visible = state
					LPM_DeadlineSubmitRo.prg_submitProgress2.visible = state
					LPM_DeadlineSubmitRo.prg_submitProgress.visible = state
 			)

 			-- adds a message to the log and apllies a timestamp and color to it
			fn log_append arg_text arg_color =
			(
				curcolor = (dotNetClass "System.Drawing.Color").FromArgb 50 200 50

				case arg_color of
				(
					1:(	curColor = (dotNetClass "System.Drawing.Color").FromArgb 200 50 50 ) 	-- Red
					2:(	curColor = (dotNetClass "System.Drawing.Color").FromArgb 50 200 50 ) 	-- Green
					3:(	curColor = (dotNetClass "System.Drawing.Color").FromArgb 150 175 255 ) 	-- Blue
					4:(	curColor = (dotNetClass "System.Drawing.Color").FromArgb 200 200 200 ) 	-- Gray
					5:(	curColor = (dotNetClass "System.Drawing.Color").FromArgb 255 169 0 ) 	-- Gold
				)

				submitLog.SelectionColor = submitLog.forecolor
				parsedTime 	= filterString localTime " "
				submitLog.appendText ( parsedTime[2] + " " + parsedTime[3] + ": " )
				submitLog.SelectionColor = curColor
				submitLog.appendText ( arg_text + "\n" )
				submitLog.ScrollToCaret()
				submitLog.update()
			)

			-- Set the display and properties of the log
			fn log_init =
			(
				submitLog.BackColor 		= (dotNetClass "System.Drawing.Color").FromArgb 68 68 68
 				submitLog.Multiline 		= true
 				submitLog.ReadOnly 			= true
 				submitLog.ForeColor 		= (dotNetClass "System.Drawing.Color").FromArgb 200 200 200
 				submitLog.WordWrap = off
				submitLog.ScrollBars = submitLog.ScrollBars.Both
				log_append ( "Connecting..." ) 4
			)

			-- Get Missing plugin classes
			fn getMissingPluginClasses =
			(
				str = stringStream ""
				apropos "*missing*" to:str
				seek str 0
				missingClasses = #()
				while not (eof str) do
				(
					ln = readLine str
					tk = filterString ln " "
					if tk.count == 4 then (
						clsName = tk[1]
						try
						(
							val = (execute clsName)
							sc = superClassOf val
							if sc==MAXWrapper or sc==node or sc==material or sc==MAXWrapperNonRefTarg then
							(
								append missingClasses val
							)
							else ()
						)
						catch ()
					)
					else ()
				)
				return missingClasses
			)

			-- Get Missing plugin classe instances
			fn getMissingPluginInstances =
			(
				missingClasses 				= LPM_deadlineInfo.plugins_missingClasses
				missingInstancesByClass 	= #()

				-- Iterate through the missing classes
				for j = 1 to missingClasses.count do
				(
					currentClass 			= missingClasses[j]
					currentClassInstances 	= getClassInstances currentClass

					-- Iterate through the missing instances of that class
					if currentClassInstances.count > 0 then
					(
						-- Make a new array (missingInstances) with the first object the name of the missing class
						missingInstances = #()
						append missingInstances (missingClasses[j] as string)

						for i = 1 to currentClassInstances.count do
						(
							-- add any instances of the missing plugin to the (missingInstances) array
							myClass = classOf currentClass
							append missingInstances myClass
						)

						-- add the collected missing instances and name to the missingInstancesByClass array
						append missingInstancesByClass missingInstances
					)
				)

				-- Return all the missing instances sorted neatly
				return missingInstancesByClass
			)

			-- Replace missing plugin classe instances
			fn replaceMissingPlugins_old =
			(
				missingInstancesByClass = LPM_deadlineInfo.plugins_missingInstances

				for missingInstances in missingInstancesByClass do
				(
					for missingInstance_i in 1 to missingInstances.count do
					(
						missingInstance = missingInstances[missingInstance_i]
						if missingInstance_i != 1 then
						(
							allClasses = missingInstance.classes
							for k = 1 to allClasses.count do
							(

								if allClasses[k].creatable then
								(
									newInst = createInstance allClasses[k]
									q = replaceInstances missingInstance newInst
									exit
								)else()
							)
						)else()
					)
				)
			)

			-- replaces missing plugins with nearest applicalb class
			fn replaceMissingPlugins =
			(
				str = stringStream ""
				apropos "*missing*" to:str
				seek str 0
				cls = #()
				while not (eof str) do (
					ln = readLine str
					tk = filterString ln " "
					if tk.count == 4 then (
						clsName = tk[1]
						try (
							val = (execute clsName)
							sc = superClassOf val
							if sc==MAXWrapper or sc==node or sc==material or sc==MAXWrapperNonRefTarg then (
								append cls val
							) else ()
						) catch ()
					) else ()
				)
				c = 0
				foundMissing = #()
				for j = 1 to cls.count do (
					cc = cls[j]
					ci = getClassInstances cc
					if ci.count > 0 then (
						for i = 1 to ci.count do (
							myClass = classOf cc
							append foundMissing myClass
							allClasses = myClass.classes
							for k = 1 to allClasses.count do (
								if allClasses[k].creatable then (
									newInst = createInstance allClasses[k]
									try (
										q = replaceInstances ci[i] newInst
										c += 1
										exit
									) catch ()
								)
							)
						)
					)
				)
			)

			-- Prompts user to delete missing plugins
			fn replaceMissingPluginsPrompt =
			(

				message = ( "Permanently remove [ " + ( LPM_deadlineInfo.plugins_missingInstances.count as string ) + " ] plugins? \n\nThis cannot be undone, and it is strongly \nreccomended to increment your scene file." )
				result = yesNoCancelBox message
				if result == #yes then
				(
					replaceMissingPlugins()
				)else()
			)

			-- Prompts user to delete missing maps
			fn RemoveMissingMaps =
			(

				ATSOps.CheckNetworkPaths = true -- Turns on status checking for network filepaths
				atsops.Refresh() -- Updates Asset Tracker
				ATSOps.GetFilesByFileSystemStatus #Missing &nullList -- Builds list of assets with "Missing" Status in Asset Tracker

				if nullList.count > 0 do
				(

					mList = #()

					for i = 1 to nullList.count do
					(
						append mList #(pathConfig.stripPathToLeaf nullList[i], nullList[i]) -- Builds sub array and appends to output array
					)
				)


				if nullList.count == 0 then
				(
					messageBox "No missing bitmaps were found"
				)
				if nullList.count > 0 then
				(
					message = ( "Permanently remove [ " + ( nullList.count as string ) + " ] unlinked bitmaps? \n\nThis cannot be undone, and it is strongly \nreccomended to increment your scene file." )
					result = yesNoCancelBox message
					if result == #yes then
					(
						actionMan.executeAction -841213575 "23"
					)
					else()
				)
			)

			-- Collect mmissing plugin instances
			fn collectMissingPluginInstances =
			(
		 		LPM_deadlineInfo.plugins_missingClasses		= getMissingPluginClasses()
		 		LPM_deadlineInfo.plugins_missingInstances	= getMissingPluginInstances()
			)

			fn idiotCheck_logReports report =
			(

				-- Get the filename and parse it into a nice property string 
				filename = ( maxFilePath + maxFileName )
				filename = ( substituteString Filename "\\" "/" )
				filenamePropString = ("filename = \"" + filename + "\"\n" )

				-- Get the username and parse it into a nice property string 
				usernamePropString = ("username = \"" + LPM_deadlineInfo.dl_user + "\"\n" )

				-- Get the time and parse it into a nice formatted string
				curTime = getLocalTime()
				parsedTime = ( ( curTime[1] as string ) + "_" + ( curTime[2] as string ) + "_" + ( curTime[4] as string ) + "__" + ( curTime[5] as string ) + "-" + ( curTime[6] as string ) + "-" + ( curTime[7] as string ) )
				parsedErrors = ( ( report.count ) as string )
				curFilename = ( parsedTime + @"__" + parsedErrors + ".toml" )

				-- Get the location to put the reports into, using the users name
				dir = ( LPM_deadlineInfo.dl_NetworkRoot + @"\reports\MAKE\LPM" )
				outDir = ( dir + @"\" + LPM_deadlineInfo.dl_user + @"\" )
				makeDir outDir
				outFilePath 	= ( outDir + curFilename )

				-- Build the report information
				reportsString = ""
				i = 1

				for r in report do
				(
					reportsString += ("report_" + ( i as string ) + " = \"" + ( r as string ) + "\"\n" )
					i += 1
				)

				-- Create and write the file
				curFile = createFile outFilePath
				format "[User]\n" to: curFile
				format usernamePropString to: curFile
				format "[Files]\n" to: curFile
				format filenamePropString to: curFile
				format "[Errors]\n" to: curFile
				format reportsString to: curFile
				close curFile

				return outFilePath
			)

			-- run the idiot checks
			fn idiotCheck_run =
			(

				ts = timeStamp()

				log_append "Running idiot checks" 4

				checks = getpropnames SMTDIdiotCheck

				collectMissingPluginInstances()

				LPM_deadlineInfo.ic_failCount 		= 0
				LPM_deadlineInfo.ic_failCritical 	= false

				resultsArray = #()

				for check in checks do
				(
					curCheck = getProperty SMTDIdiotCheck check
					curCheckResult = curCheck()

					if curCheckResult[1] == "fail"
					then
					(
						for result in curCheckResult[3] do
						(
							LPM_deadlineInfo.ic_failCount += 1

							if curCheckResult[2] == 1
							then
							(
								LPM_deadlineInfo.submit_enable = false
								LPM_deadlineInfo.ic_failCritical = true
							)
							else ()

							append resultsArray result
						)
					)

					-- TODO: Find a better saftey net around failed checks
					try ( log_append curCheckResult[4] 3 )
					catch ( log_append "Error running idiot check" 4 )
				)

				-- Print results to the log
				log_append ( "All checks took " + ( ( (timeStamp() - ts ) / 1000.000 ) as string ) + " seconds" ) 4
				for result in resultsArray do ( log_append result 5	)

				-- Store for later and return the checks
				LPM_SMTDSettings.idiotCheckReports = resultsArray
				return resultsArray
			)

			-- Adds a time penalty to skipping the idiot checks
			fn idiotCheck_skip =
			(
				timePenalty = 5

				LPM_deadlineInfo.ic_failCount = 0

				for i in 1 to timePenalty do
				(
					curMessage = ( "Waiting... " + ( ( timePenalty - i + 1 ) as string ) )
					log_append curMessage 1
					sleep 1
				)

				log_append ( "All Check Skipped" ) 4

				
				resultsArray = #(#("pass", 0,"0", "Idiiot Check Skipped" ))

				LPM_deadlineInfo.submit_enable = true

				LPM_SMTDSettings.idiotCheckReports = resultsArray
				return resultsArray
			)

			-- Connects to the repository and loads various auxilary files and retrieves data from the deadline database
			fn deadline_connect =
			(
				if ( doesfileexist LPM_deadlineInfo.dl_NetworkRoot )
				then
		 		(
		 			log_append "Connected to Deadline repository" 2
		 			log_append LPM_deadlineInfo.dl_NetworkRoot 4

		 			-- Importing Functions
		 			log_append "Importing functions..." 4
		 			try ( filein LPM_deadlineInfo.dl_fnScript )
		 			catch
					(
 						-- log_append (" Error: " + LPM_deadlineInfo.fcScript + " Not Found") 1
						log_append (" Error: " + "SubmitMaxToDeadline_Functions.ms" + " Not Found") 1
						return false
					)

					-- Importing Idiot Checks
					log_append "Importing Idiot Checks..." 4
					try( filein LPM_deadlineInfo.dl_icScript )
					catch
					(
						-- log_append (" Error: " + LPM_deadlineInfo.dl_icScript + " Not Found") 1
						log_append (" Error: " + "SubmitMaxToDeadline_IdiotCheck.ms"  + " Not Found") 1
						return false
					)

					-- Import Groups
					log_append "Collecting Groups..." 4
					try
					(
						LPM_deadlineInfo.dl_groups  = for i in SMTDSettings.Groups collect i
						log_append ( ( LPM_deadlineInfo.dl_groups.count as string ) + " Groups found" ) 4
					)
					catch ( log_append (" No Groups found") 1 )


					-- Import Limits
					log_append "Collecting Limits..." 4
					try
					(
						SMTDFunctions.CollectLimitGroups()
						LPM_deadlineInfo.dl_limits = SMTDSettings.LimitGroups

						log_append ( ( LPM_deadlineInfo.dl_limits.count as string ) + " Limits found" ) 4
					)
					catch ( log_append (" No Limits found") 1 )


					-- Import Autodraft Presets
					try
					(
						LPM_deadlineInfo.draft_templates = getFiles ( LPM_deadlineInfo.draft_templatesDir+"*.py" )
						LPM_deadlineInfo.draft_templateNames = for template in LPM_deadlineInfo.draft_templates collect (getfilenamefile (template))
						log_append ( ( LPM_deadlineInfo.draft_templateNames.count as string ) + " AUTODRAFT presets found" ) 4
					)
					catch ( log_append (" No AUTODRAFT presets found ") 1 )

					-- Load user
					try
					(
						LPM_deadlineInfo.dl_user = ""
						LPM_deadlineInfo.dl_user = SMTDFunctions.GetDeadlineUser()
						log_append ("Submitting as ' " + LPM_deadlineInfo.dl_user + " ' ") 4
					)
					catch
					(
 						LPM_deadlineInfo.dl_user = "make"
 						log_append (" Unable to find user, using ' " + LPM_deadlineInfo.dl_user + " ' instead") 1
					)

		 			return true
		 		)
		 		else
		 		(
		 			log_append "Unable to connect to Deadline repository:" 1
		 			return false
		 		)
			)

			-- updates UI batch field with name field
			fn ui_update_nameToBatch =
			(
				LPM_deadlineInfo.dl_batchName  = LPM_deadlineInfo.dl_jobName
				lab_CustomBatchField.text = LPM_deadlineInfo.dl_batchName
			)

			-- updates UI job name with max filename
			fn ui_update_jobName =
			(
				curName = maxfilename
				newName  = ( substring curName 1 ( curname.count - 4 ) )

				LPM_deadlineInfo.dl_jobName = newName
				lab_CustomNameField.text = LPM_deadlineInfo.dl_jobName
			)

			-- updates UI job name with max filename
			fn ui_update_jobComment =
			(
				try( -- TODO: Fixup to have propper renderer specific handling
					commentStr = ""
	
					re = renderers.current
					if re.imageSampler_type == 1
					then
						(
							commentStr += "BUCKET"
							commentStr += ( " - SR: " + ( re.imageSampler_shadingRate as string ) )
							commentStr += ( " | MAX: " + ( re.twoLevel_fineSubdivs as string ) )
							commentStr += ( " | THR: " + ( re.twoLevel_threshold as string ) )
						)
					if re.imageSampler_type == 3
					then
						(
							commentStr += "PROG"
							commentStr += ( " - TIME: " + ( re.progressive_max_render_time as string ) )
							commentStr += ( " | SAMPLES: " + ( re.progressive_maxSamples as string ) )
							commentStr += ( " | THR: " + ( re.progressive_noise_threshold as string ) )
						)
	
					LPM_deadlineInfo.dl_jobComment  = commentStr
					lab_CustomCommentField.text = LPM_deadlineInfo.dl_jobComment
				)catch()
			)

			-- updates UI Batch name with the max filename
			fn ui_update_jobBatchName =
			(
				curName = maxfilename
				newName  = ( substring curName 1 ( curname.count - 4 ) )

				LPM_deadlineInfo.dl_batchName  = newName
				lab_CustomBatchField.text = LPM_deadlineInfo.dl_batchName
			)

			-- updates UI user field
			fn ui_update_user =
			(

				lab_DeadlineUserField.text = ( " " + LPM_deadlineInfo.dl_user )
				SMTDSettings.UserName = LPM_deadlineInfo.dl_user
			)

			-- Updates the priority UI items to match the value passed
			fn ui_update_priorityGang val =
			(
				if val <= 100 do
				(
					theRed = (255.0 - 255.0*val/100.0)*2.0
					if theRed > 255 do theRed = 255
					theGreen = 512.0*val/100.0
					if theGreen > 255 do theGreen = 255
					sld_priority.color = [theRed, theGreen, 0]
					sld_priority.value = spn_priority.value = val
					SMTDSettings.Priority = val
				)
				val
			)

			-- Updates the priority UI items
			fn ui_update_priority =
			(

				ui_update_priorityGang SMTDSettings.Priority
			)

			-- updates UI groups dropdown
			fn ui_update_groups =
			(
				LPM_deadlineInfo.dl_groups

				groupsPlusNone = LPM_deadlineInfo.dl_groups
				ddl_group.items = groupsPlusNone
				ddl_group.selection = 1

				LPM_deadlineInfo.dl_groupChosen = ""
			)

			-- re - collects the renderable passes from LPM, and passes them to the submitter
 			fn ui_update_submit =
			(
				log_append ( "Evaluating submission..." ) 4

 				if LPM_deadlineInfo.submit_enable
 				then
 				(
 					btn_submit.enabled = true

 					if LPM_deadlineInfo.ic_failCount == 0
 					then
 					(
						img_idiotcheck_L.bitmap = bm_idiotCheckGreen
						img_idiotcheck_R.bitmap = bm_idiotCheckGreen
 					)
 					else
 					(
						img_idiotcheck_L.bitmap = bm_idiotCheckOrange
						img_idiotcheck_R.bitmap = bm_idiotCheckOrange
						log_append ( "[ " + ( LPM_deadlineInfo.ic_failCount as string ) + " ] check(s) failed!" ) 1
 					)

 					LPM_Fun.setWhoToRenderByRenderType()
					renderCollect = LPM_Fun.getWhoToRender()
					newMessage = ( "Ready to submit [ " + (renderCollect.count as string) + " ] passe(s).")
					btn_submit.text = newMessage

					log_append newMessage 2
 				)
 				else
 				(
 					btn_submit.enabled = false
 					img_idiotcheck_L.bitmap = bm_idiotCheckRed
					img_idiotcheck_R.bitmap = bm_idiotCheckRed

 					LPM_Fun.setWhoToRenderByRenderType()
					renderCollect = LPM_Fun.getWhoToRender()
					newMessage = ( "Unable to submit [ " + (renderCollect.count as string) + " ] passe(s).")
					btn_submit.text = newMessage

					log_append newMessage 1
					log_append "View log for details" 1
 				)
 			)

			-- Updates various UI items
 			fn ui_update =
 			(
 				ui_update_jobName()
 				ui_update_jobComment()
				ui_update_jobBatchName()
 				ui_update_user()
				ui_update_priority()
				ui_update_groups()
			)

 			-- Creates a rollout that sets the active limits
 			fn setLimitsRO =
			(
				rollout LPM_DeadlineSubmit_setLimitsRO "Set Limits" width:225 height:300
				(
					label lab_1 "Select Limits" align:#left
					multilistbox mlt_theLimitGroups "" items:#("-- Loading --") height:10
					button btn_chooseLimits "Choose Selected Limits" width:205 align:#left

					fn resize_setLimitsRO curHeight =
					(
						mlt_theLimitGroups.height = curHeight-50
						btn_chooseLimits.pos = [10,(curHeight-25)]
					)

					fn saveLimitGroups =
					(
						result = #()
						for selected in mlt_theLimitGroups.selection do
						(
							append result mlt_theLimitGroups.items[selected]
						)

						LPM_deadlineInfo.dl_limitsChosen = result
						SMTDSettings.LimitGroupsToUse = result
					)

					on LPM_DeadlineSubmit_setLimitsRO resized theSize do
					(
						resize_setLimitsRO theSize[2]
					)

					on LPM_DeadlineSubmit_setLimitsRO open do
					(
						resize_setLimitsRO 300
						mlt_theLimitGroups.items = LPM_deadlineInfo.dl_limits
					)

					on btn_chooseLimits pressed do
					(
						saveLimitGroups()
			 			destroyDialog LPM_DeadlineSubmit_setLimitsRO
					)

					on LPM_DeadlineSubmit_setLimitsRO close do
					(
						saveLimitGroups()
					)
				)

				createDialog LPM_DeadlineSubmit_setLimitsRO lockHeight:false lockWidth:true style:#(#style_titlebar,#style_border, #style_sysmenu,#style_resizing,#style_minimizebox) modal:true
			)

			-- function called when the rollout opens, it connects to deadline, runs the checks and populates the UI
 			fn init =
 			(
 				LPM_DeadlineSubmitRo.height = 210
 				-- Initalize the Log UI
 				log_init()

 				-- Connect with Repository and all functions to retireve data
  				if deadline_connect()
 				then
 				(
	 				-- Update UI Items
	 				ui_loadStickySettings()
	 				ui_update()

	 				-- Perform Idiot checks, or skip if enabled
	 				if LPM_IdiotChecksEnabled == False
	 				then ( idiotCheck_skip() )
 					else ( idiotCheck_run() )
 					
-- TODO: Relink Idiot checks 					
--	 				if LPM_treeview_rollout.skipIdiotChecks.checked
--	 				then ( idiotCheck_skip() )
-- 					else ( idiotCheck_run() )
 	
	 				-- Move Log to bottom of Dialog
	 				submitLog.pos=[ 3 , 630 ]
	 				submitLog.height=190
	 				btn_connectCancel.visible = false

	 				-- Enable UI item visibility
	 				ui_visibilityToggle true

	 				-- Update submitter status
					ui_update_submit()

					-- Resize Interface
					LPM_DeadlineSubmitRo.height = 825
 				)
 				else
 				(
 					log_append "Unable to connect to repository" 1
 					log_append LPM_deadlineInfo.dl_NetworkRoot 1
 				)
 			)

 			-- applies any changes to the SMTDSettings
 			fn submit_commitChanges =
 			(
				SMTDSettings.JobName 						= LPM_deadlineInfo.dl_jobName
				SMTDSettings.UserName 						= LPM_deadlineInfo.dl_user
				SMTDSettings.Comment  						= LPM_deadlineInfo.dl_jobComment
				SMTDSettings.group 							= LPM_deadlineInfo.dl_groupChosen
				SMTDSettings.LimitGroupsToUse 				= LPM_deadlineInfo.dl_limitsChosen
				SMTDSettings.SubmitAsSuspended 				= LPM_deadlineInfo.sticky_submitAsSuspended
				SMTDSettings.JobIsInterruptible 			= LPM_deadlineInfo.dl_interruptible
				SMTDSettings.TaskTimeoutEnabled 			= LPM_deadlineInfo.dl_taskTimeoutEnabled
				LPM_deadlineInfo.submit_recoveryHold		= LPM_deadlineInfo.sticky_holdOnSubmit

				-- Set override range hold
				if LPM_deadlineInfo.framerange_overrideEnabled
				then
				(
					animStart  	= (animationRange.start as integer)/TicksPerFrame
					animEnd 	= (animationRange.end as integer)/TicksPerFrame
					LPM_deadlineInfo.framerange_overrideRange_HOLD	= #( animStart, animEnd)
				)
 			)

 			-- Function to try and recover the scene if LPM crashed on submission, and if not, it reports it to the user
			fn submit_fail =
			(

				if LPM_deadlineInfo.sticky_holdOnSubmit == true
				then
				(
					rollout automaticRecoveryMessage "Auto-Recovery" width:300 height:50
					(
						label lab1 "Submission crashed, performing restore." align:#center offset:[0,8]
	  					label lab2 "Please wait..." offset:[0,-5]
					)

					rollout automaticRecoveryMessage2 "Auto-Recovery" width:300 height:70
					(
						label lab1 "LPM successfully recovered scene!" offset:[0,8]
	  					button btn1 "Great!" offset:[0,5] width:80 height:25

						on btn1 pressed do destroydialog automaticRecoveryMessage2
					)

					createdialog automaticRecoveryMessage

 					fetchmaxfile quiet:true

					destroydialog automaticRecoveryMessage
					createdialog automaticRecoveryMessage2

				)
				else
				(
					rollout automaticRecoveryFailMessage "Auto-Recovery" width:300 height:80
					(
						label lab1 "Submission has Failed!" align:#center offset:[0,8]
						label lab0 "" offset:[0,-5]
	  					label lab2 "Your scene may be corrupted," offset:[0,-5]
						label lab3 "It is strongly reccomended you re-open last save." offset:[0,-5]
					)

					createdialog automaticRecoveryFailMessage
				)

				enablesceneredraw()
				redrawviews()
			)

 			fn submit_preOptimize =
 			(
 				-- print "Submit Pre Optimze"
 			)

			fn submit_preAction =
			(
				-- print "Submit Pre Action"

				-- Set Timestamp and Alert to starting submission
				LPM_deadlineInfo.submit_timeStamp  = timeStamp()
				SMTDLPMInterface.log_append "Beginning Submission." 2

				-- Disable as much of the viewport as we can
				disablesceneredraw()
				Undo off ()
				suspendEditing()

				-- Comitt settings
				renderSceneDialog.close()
				SMTDLPMInterface.submit_commitChanges()
				SMTDLPMInterface.ui_saveStickySettings()

				-- Log the failed idiot checks to the repository location
				-- There is sometimes an error when launching LPM and skipping the IC before ever doing a deadline render, that can cause a crash - hence the try catch
				try( idiotCheck_logReports LPM_SMTDSettings.idiotCheckReports ) catch()

				-- Perform a hold if desired
				if LPM_deadlineInfo.submit_recoveryHold then
				(
					SMTDLPMInterface.log_append "Performing 3dsMax Hold" 2
					holdMaxFile()
				)
				else()

				SMTDLPMInterface.prg_submitProgress.value = 0
				--rendUseActiveView = true
			)


			fn submit_action =
			(
				-- print "Submit Action"

				renderCollect = LPM_Fun.getWhoToRender()
				flag=true

				-- Loop through the passes, and prepare them
				for i=1 to renderCollect.count where flag do
				(
					SMTDLPMInterface.prg_submitProgress2.value=5

					ts2 = timestamp()
					prg_submitProgress.value = (100*(i-1))/renderCollect.count
					submission_report = ("Submitting Pass - " + (LPM_Fun.getName renderCollect[i][1].name) +"  ( " + (i as string) + " of "+ (renderCollect.count as string) + " )" )
					log_append submission_report 4
					
					--Pre render action
					SMTDLPMInterface.prg_submitProgress2.value=10

					LPM_Render.fnPreRenderAction renderCollect[i][1] renderCollect[i][2]
					thePass=renderCollect[i][1]
					theShot=renderCollect[i][2]
					stickySMTDSettings = copy SMTDSettings
					SMTDLPMInterface.prg_submitProgress2.value=20

					try
					(
						TmpPass = renderCollect[i][1]
						TmpPassName = (LPM_Fun.getName TmpPass.name)

						if (theShot==undefined) then
						(
							SMTDSettings.JobName = ( (getfilenamefile (maxfilename)) + " | P: "+TmpPassName)
						)
						else
						(
							SMTDSettings.JobName = ( (getfilenamefile (maxfilename)) + " | Sh: "+(LPM_Fun.getName renderCollect[i][2].name)+" | P: "+TmpPassName)
						)

						-- Deadline LPM OVERRIDE settings
						if LPM_SMTDSettings.active then
						(
							-- Priority Override
							if LPM_SMTDSettings.priorityOn then
							(
								-- Priority Offset
								if LPM_SMTDSettings.priorityOffsetOn then
								(
									newPriority = ( SMTDSettings.Priority + LPM_SMTDSettings.priorityOffset )
									if newPriority > 99 then newPriority = 99
									if newPriority < 1 then newPriority = 1

									SMTDSettings.Priority = newPriority
								)

								-- Priority Absolute
								if LPM_SMTDSettings.priorityAbsoluteOn then
								(
									newPriority = ( LPM_SMTDSettings.priorityAbsolute )
									if newPriority > 99 then newPriority = 99
									if newPriority < 1 then newPriority = 1

									SMTDSettings.Priority = newPriority
								)
							)

							if LPM_SMTDSettings.taskSizeOn then
							(
								SMTDSettings.ChunkSize = LPM_SMTDSettings.taskSize
							)

							if LPM_SMTDSettings.submitGroupOn then
							(
								SMTDSettings.group = LPM_SMTDSettings.submitGroup
							)

							if LPM_SMTDSettings.submitLimitsOn then
							(
								SMTDSettings.LimitGroupsToUse = LPM_SMTDSettings.submitLimits
							)
							
							if LPM_SMTDSettings.renderTicks then --Tyson
							(
								rendNthFrame = LPM_SMTDSettings.renderTicksMult; --this is how we pass our ticks mult to each farm machine 
								SMTDSettings.SubmitAsMXSJob = true;
								SMTDSettings.MAXScriptFile = LPM_Dir + "renderTicks.ms"
								SMTDSettings.UseCustomFrameList = true
								SMTDSettings.LocalRendering = false
								
								SMTDSettings.CustomFrameList = #()
								for j in rendStart to rendEnd by 1 / (LPM_SMTDSettings.renderTicksMult as float) do
								(
									adjustedTime = (((j as integer) / (ticksPerFrame as float)) * LPM_SMTDSettings.renderTicksMult) as integer
									
									append SMTDSettings.CustomFrameList adjustedTime
								)
								
							)
						)
					)
					catch
					(
						submit_fail()
					)

					SMTDLPMInterface.prg_submitProgress2.value=30

					-- Submit Deadline Job
					-- Inject BatchName into the job info file via ExtraJobInfoKeys (Deadline 10+ API)
					if LPM_deadlineInfo.dl_batchName != "" then
					(
						SMTDSettings.ExtraJobInfoKeys = #(#("BatchName", LPM_deadlineInfo.dl_batchName))
					)
					local result = SMTDFunctions.SubmitJob()

					if result != #success do
					(
						flag = false
						messagebox ("Error while submitting to Deadline (error code: "+result+")")
					)

					SMTDLPMInterface.prg_submitProgress2.value=80

					SMTDSettings = stickySMTDSettings 					-- Put SMTDsettings back to normal
					-- reMgr.SetElementsActive stickyElementsActive 		-- Put render elements settings back to normal

					log_append "Restoring Scene to pre submission state..." 4

					LPM_Render.fnPostRenderAction renderCollect[i][1] renderCollect[i][2]
					
					if(keyboard.escPressed) then flag=false

					SMTDLPMInterface.prg_submitProgress2.value=100
					log_append  ("time (s) " +((timeStamp() - ts2)/1000.000) as string ) 4
				)

				try
				(
					SMTDLPMInterface.grp_submit.text = "Submit"

					case flag of
					(
						true: ( log_append "Submission complete!" 2 )
						false: ( log_append "Submission Stopped!" 3 )
					)

					SMTDLPMInterface.prg_submitProgress.value = 95

				)
				catch()
			)

 			fn submit_postOptimize =
 			(
 				-- print "Submit Post Optimze"
 			)

 			-- Restore the scene to pre Submission state
			fn submit_postAction =
			(
				-- print "Submit Post Action"

				log_append "Perfoming Scene post submit actions" 4

				-- Re-enable the scene
				undo on ()
				resumeEditing()
				enablesceneredraw()

				SMTDLPMInterface.prg_submitProgress.value = 100

				try
				(
					sleep 1.25

					if SMTDLPMInterface.chk_closeOnComplete.checked == true
					then ( destroydialog SMTDLPMInterface )
					else ( SMTDLPMInterface.prg_submitProgress.visible = false )
				)
				catch()

			)



			-- Handles the submission of a job
			fn submit =
			(
				-- Disable viewport and UI as much as possible, save settings, and handle other initializing
  				SMTDLPMInterface.submit_preAction()

 				-- If set to, optimize the scene for submission
				if LPM_deadlineInfo.optimize_enabled then ( SMTDLPMInterface.submit_preOptimize() ) else()

				-- try and submit the jobs
				SMTDLPMInterface.submit_action()

				-- if set to, restore any optimizations that took place before submission
				if LPM_deadlineInfo.optimize_enabled then ( SMTDLPMInterface.submit_postOptimize() ) else()

				-- Re-Enable viepowrts and editing
				SMTDLPMInterface.submit_postAction()
			)

			-- Event handler for removing missing plugins
			on btn_removeMissingPlugins pressed do
			(

				collectMissingPluginInstances()
				replaceMissingPluginsPrompt()
			)

			-- Event handler for removing missing maps

			on btn_removeMissingMaps pressed do
			(
				RemoveMissingMaps()
			)

			-- Event handler for running the idiot checks
			on btn_idiotCheck pressed do
			(
				reports = idiotCheck_run()
				ui_update_submit()
			)

			-- Event handler for re-evaluating the tasks from LPM
			on btn_submitReEval pressed do
			(
				ui_update_submit()
			)

			-- Event handler for setting if max restarts between tasks
			on chk_RestartMax changed state do
			(
				SMTDSettings.RestartMax = state
			)

			-- Event handler for setting task size ( in frames )
			on spn_chunkSize changed state do
			(
				SMTDSettings.ChunkSize = state
			)

			-- Event handler for setting out of order method
			on ddl_outOfOrderMethod selected itm do
			(
				theMethod= case itm of
				(
						1: #normal
						2: #nth
						3: #NthBlock
						4: #NthRasterRefine
						5: #reverse
						6: #fromBothEnds
						7: #fromCenter
						8: #fromBothEndsAndCenter
						9: #random
				)

				spn_outOfOrderStep.enabled = itm >= 2 AND itm <= 4

				SMTDSettings.OutOfOrderMethod 	= theMethod
				SMTDSettings.OutOfOrderStep 	= spn_outOfOrderStep.value
			)

			-- Event handler for enabling or disabling task timeout
 			on chk_autoStartupTimeout changed state do
 			(
				LPM_deadlineInfo.dl_taskTimeoutEnabled = state
				spn_autoStartupTimeout.enabled = state
 			)

 			-- Event handler for setting the task startup timeout duration
	 		on spn_autoStartupTimeout changed state do
	 		(
	 			LPM_deadlineInfo.dl_taskTimeoutSeconds = ( state as string )
	 		)

			-- Event handler for setting if the job is interuptable or not
			on chk_interruptable changed state do
			(
				LPM_deadlineInfo.dl_interruptible = state
				spn_interruptablePercent.enabled = state
			)

			-- Event handler for setting the interruptable percentage
			on spn_interruptablePercent changed state do
			(
				LPM_deadlineInfo.dl_interruptiblePercentage = state
			)

			-- Event handler for selecting the group you want to submit to
			on ddl_group selected arg do
			(
				LPM_deadlineInfo.dl_groupChosen = LPM_deadlineInfo.dl_groups[arg]
			)

			-- event handler for comment field update
			on lab_CustomCommentField changed state do
			(
				LPM_deadlineInfo.dl_jobComment = lab_CustomCommentField.text
			)

			-- event handler for setting limits
			on btn_setLimits pressed do
			(
				setLimitsRO()
				btn_setLimits.text = ( ( SMTDSettings.LimitGroupsToUse.count as string ) + " Limits set")
				for limit in SMTDSettings.LimitGroupsToUse do
				(
					log_append ( " \"" + limit + " \"" + " limit was added" ) 4
				)
			)

			-- event handler for clearing limits
			on btn_setLimitsClear pressed do
			(
				btn_setLimits.text = "Set limits"
				SMTDSettings.LimitGroupsToUse = #()
				log_append ( " Limits were cleared from submission" ) 4
			)

 			-- Event for custom name field changing
 			on lab_CustomNameField changed state do
 			(
 				LPM_deadlineInfo.dl_jobName = state
 				LPM_deadlineInfo.dl_batchName = state
 				lab_CustomBatchField.text = state
 			)

 			on lab_CustomBatchField changed state do
 			(
 				LPM_deadlineInfo.dl_batchName = state
 			)

 			-- Button: close on failed launch
 			on btn_connectCancel pressed do
 			(
 				destroyDialog LPM_DeadlineSubmitRo
 			)

 			-- Event handler for changing the priority via the priority slider
			on sld_priority clicked value do
			(
				SMTDSettings.Priority= (ui_update_priorityGang value)
			)

			-- Event handler for changing the priority via the priority spinner
			on spn_priority changed value do
			(
				SMTDSettings.Priority= (ui_update_priorityGang value)
			)

			-- Event handler for submission hold
			on btn_holdOnSub changed state do
			(
				LPM_deadlineInfo.sticky_holdOnSubmit = state
				LPM_deadlineInfo.submit_recoveryHold = state
			)

			-- Event handler for chosing your frame buffer mode
			on ddl_frameBufferMode selected state do
			(
				LPM_deadlineInfo.sticky_frameBufferMode	= state
			)

			-- event handler for submit as suspended
			on chk_renderElementsExr changed state do
			(
			--	LPM_deadlineInfo.sticky_renderElementsExr  = state
			)

			-- Event handler for ignoring missing Maps
			on chk_IgnoreFiles changed state do
			(

				SMTDSettings.IgnoreMissingExternalFiles = state
			)

			-- Event handler for ignoring missing .DLL files
			on chk_IgnoreDLL changed state do
			(

				SMTDSettings.IgnoreMissingDLLs = state
			)

			-- event handler for submit as suspended
			on btn_submitSuspended changed state do
			(

				LPM_deadlineInfo.sticky_submitAsSuspended 	= state
				SMTDSettings.SubmitAsSuspended 				= state
			)

			-- Event handler for chosing the method of file submission
			on ddl_SubmitExternalFilesMode selected itm do
			(

				SMTDSettings.SubmitExternalFilesMode = ddl_SubmitExternalFilesMode.selection
			)

			on btn_optimizeScene pressed do
			(
				-- print("Not Connected")
			)

			-- Event handler for controling if submission is optimized or not
			on btn_optimizeSubmit changed state do
			(
				LPM_deadlineInfo.optimize_enabled = state
			)

			-- event handler for submitting your job
 			on btn_submit pressed do
 			(
 				submit()
 			)

 			-- Event for the rollout opening
 			on LPM_DeadlineSubmitRo open do
			(
				init()
 			)

			-- Event for rollout closing
 			on LPM_DeadlineSubmitRo close do
 			(
 				ui_saveStickySettings()
 			)
 		)

		-- Try to destroy and preious versions of the dialog
		try( destroyDialog SMTDLPMInterface )catch()

		-- Create the new interface and assign it to its global holder
		createDialog LPM_DeadlineSubmitRo lockHeight:true lockWidth:true style:#(#style_titlebar,#style_border, #style_sysmenu,#style_resizing, #style_minimizebox) pos:(LPM_Fun.getRoPos LPM_DeadlineSubmitRo.width)
		SMTDLPMInterface = LPM_DeadlineSubmitRo
		return #SUCCESS
	)
)

-- LPM_DeadlineAPI = LPM_DeadlineAPI()
LPM_DeadlineAPI.submit()