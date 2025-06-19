rollout settingsRO "LPM Settings" width:399 height:359
(
	GroupBox grp1 "UI" pos:[6,5] width:218 height:131
		dropdownList dialogsAlignLeft "Dialogs Pop Up" pos:[13,22] width:136 height:40 items:#("Left", "Right")
		checkbox chk_ShowLPMPassSelectWindow "Show LPM pass select window on start" pos:[13,70] width:208 height:19
		button btnShowPassSelectWindow "Show window" pos:[142,90] width:75 height:23 toolTip:"Show LPM pass select window"
		checkbox chk_ShowSkipButton " Show FW and Skip Button" pos:[13,114] width:145 height:16 toolTip:"Show Hide Rendered Frame Window\n and Skip Existing Images Buttons"
	GroupBox grp2 "Render Settings" pos:[229,5] width:165 height:131
		dropdownList defaultFormat "Default File Format" pos:[238,21] width:150 height:40 items:#("exr", "avi", "bmp", "cin", "eps", "hdr", "jpg", "exr", "png", "rgb", "rla", "rpf", "tga", "tif", "dds")
		dropdownList networkType "Network Type" pos:[238,66] width:97 height:40
		button networkRendSettings "options" pos:[338,84] width:50 height:21
		checkbox VFBoffSetting "VFB off" pos:[238,113] width:59 height:15 toolTip:"Turns off V-Ray frame buffer when production render."
	GroupBox grp3 "Defaults" pos:[6,137] width:188 height:155
		dropdownList objectSetDefault "ObjectSet/LightSet Default:" pos:[14,156] width:172 height:40 items:#("--", "On", "Off")
		dropdownList objectSetDefaultHideMode "Pass Default Hide Mode:" pos:[14,201] width:172 height:40 items:#("Do Nothing", "Hide All Objects/Lights", "Unhide All Objects/Lights")
		dropdownList shotViewport "Shot Preview Viewport:" pos:[14,246] width:172 height:40 items:#("Active Viewport", "Viewport 1", "Viewport 2", "Viewport 3", "Viewport 4")
	GroupBox grp4 "Viewport previews" pos:[201,137] width:193 height:155
		label ObjMiddleSetting "-   Objects visibility override" pos:[215,157] width:140 height:13
		label LightsMiddleSetting "-    Lights visibility override" pos:[215,173] width:140 height:13
		checkbox TimeMiddleSetting "Apply Common override" pos:[211,190] width:135 height:15 toolTip:"Apply Time range, camera override on middle click"
		checkbox RendMiddleSetting "Apply Renderer override" pos:[211,208] width:138 height:15 toolTip:"Apply Renderer override on middle click"
		checkbox ModifMiddleSetting "Apply Modifier override" pos:[211,227] width:131 height:15 toolTip:"Apply Modifier override on middle click"
		spinner spn_ShotsPlaybackLimit "" pos:[312,269] width:50 height:16 range:[1,100,5] type:#integer scale:1
		label lblShotsPlaybackLimit "Shots playback limit:" pos:[213,270] width:97 height:16
		checkbox chkOnePreviewFolder "One preview folder" pos:[211,245] width:131 height:15 toolTip:"Save all hardware previews in one root folder."
	GroupBox grp5 "Vrimg2exr autoconvert" pos:[6,293] width:388 height:60
		label lblVrimg2exr "Vrimg2exr.exe file location:" pos:[22,312] width:150 height:13
		edittext edtVrimg2exr "" pos:[8,330] width:360 height:17 editable:false
		button btnVrimg2exr " ..." pos:[371,331] width:18 height:16
	
	on btnShowPassSelectWindow pressed do 
	(
		filein (LPM_Dir+"LPM_Pass_select.ms")
	)
	
	on btnVrimg2exr pressed do
	(
		Vrimg2exrFile = getOpenFileName caption:"select Vrimg2exr.exe" filename:"C:\\Program Files\\Chaos Group\\V-Ray\\3dsmax 2014 for x64\\tools\\vrimg2exr.exe" types:"vrimg2exr.exe|*vrimg2exr.exe"
		if Vrimg2exrFile != undefined then (edtVrimg2exr.text = Vrimg2exrFile)
	)
	
		--load settings
	on settingsRo open do
	(
		edtVrimg2exr.text = LPM_Fun.getIni "Settings" "PostConvertVrimg2exr" string "C:\\Program Files\\Chaos Group\\V-Ray\\3dsmax 2014 for x64\\tools\\vrimg2exr.exe"
		networkType.items=for n in LPM_NetworkPlugins collect n.type
		--general
		dialogsAlign=LPM_Fun.getIni "Settings" "dialogAlignLeft" booleanClass true
		if(dialogsAlign==false) then
			dialogsAlignLeft.selection=2

		--Render settings
		theNetworkType=LPM_Fun.getIni "Settings" "Network Type" string "Backburner"
		for i=1 to networkType.items.count where networkType.items[i] ==theNetworkType do networkType.selection=i
		defaultFormat.items[1]=LPM_Fun.getIni "Settings" "Default Format" string "exr"
		defaultFormat.items=defaultFormat.items
		try(VFBoffSetting.state = LPM_Fun.getIni "Settings" "VFBoffSetting" booleanClass true)catch()
		try(TimeMiddleSetting.state = LPM_Fun.getIni "Settings" "TimeMiddleSetting" booleanClass true)catch()
		try(RendMiddleSetting.state = LPM_Fun.getIni "Settings" "RendMiddleSetting" booleanClass false)catch()
		try(ModifMiddleSetting.state = LPM_Fun.getIni "Settings" "ModifMiddleSetting" booleanClass false)catch()
		try(chkOnePreviewFolder.state = LPM_Fun.getIni "Settings" "OnePreviewFolder" booleanClass false)catch()
		
		--Passes and shots
		objectSetDefault.selection=LPM_Fun.getIni "Settings" "objectSetDefaultValue" integer 1
		objectSetDefaultHideMode.selection=LPM_Fun.getIni "Settings" "objectSetDefaultHideMode" integer 1
		
		theViewport=LPM_Fun.getIni "Settings" "shotViewport" string "Active Viewport"
		for i=1 to shotViewport.items.count where shotViewport.items[i]==theViewport do shotViewport.selection=i
		
		chk_ShowSkipButton.state = LPM_Fun.getIni "Settings" "ShowSkipButton" booleanClass false
		spn_ShotsPlaybackLimit.value = LPM_Fun.getIni "Settings" "ShotsPlaybackLimit" integer 5
	)
	--save settings
	on settingsRo close do
	(
		--general
		if(dialogsAlignLeft.selection==1) then
			LPM_Fun.setIni "Settings" "dialogAlignLeft" true
		else
			LPM_Fun.setIni "Settings" "dialogAlignLeft" false

		--render settings
		LPM_Fun.setIni "Settings" "Default Format" defaultFormat.selected
		LPM_Fun.setIni "Settings" "Network Type" networkType.selected
		LPM_Fun.setIni "Settings" "VFBoffSetting" VFBoffSetting.state
		
		--Passes and shots
		LPM_Fun.setIni "Settings" "objectSetDefaultValue" objectSetDefault.selection
		LPM_Fun.setIni "Settings" "objectSetDefaultHideMode" objectSetDefaultHideMode.selection
		LPM_Fun.setIni "Settings" "shotViewport" shotViewport.selected
		LPM_Fun.setIni "Settings" "TimeMiddleSetting" TimeMiddleSetting.state
		LPM_Fun.setIni "Settings" "RendMiddleSetting" RendMiddleSetting.state
		LPM_Fun.setIni "Settings" "ModifMiddleSetting" ModifMiddleSetting.state
		LPM_Fun.setIni "Settings" "PostConvertVrimg2exr" (edtVrimg2exr.text)
		LPM_Fun.setIni "Settings" "ShowSkipButton" chk_ShowSkipButton.state
		LPM_Fun.setIni "Settings" "ShotsPlaybackLimit" spn_ShotsPlaybackLimit.value
		LPM_Fun.setIni "Settings" "OnePreviewFolder" chkOnePreviewFolder.state
	)
	
	on networkRendSettings pressed do
	(
		if networkType.selected == "Deadline" then
		(
			rollout Deadline_options_roll "Deadline options" width:500 --height:55
			(
				label deadlinefuncfile "Deadline Submission Functions script path "
				editText edt1 "" width:400 height:17 --pos:[15,15] --readOnly:true
				button btn1 "Select script"  width:70 height:22 pos:[420,22]
				label example001 "Example: Z:\\DeadlineRepository\\submission\\3dsmax\\Main\\SubmitMaxToDeadline_Functions.ms"
				
				on Deadline_options_roll open do
				(
					
					LpmSettingsFile = ( getdir #plugcfg + "\\LPM.ini" )
				
					if doesFileExist LpmSettingsFile then
					(
						try
						(
							edt1.text = getINISetting LpmSettingsFile "Deadline_Options" "Deadline_Server"
						)
						catch()
					)
					
				)
				
				on Deadline_options_roll close do
				(
					LpmSettingsFile = ( getdir #plugcfg + "\\LPM.ini" )
					if (edt1.text != "")and(doesfileexist edt1.text)and(doesFileExist LpmSettingsFile) then
					(
						setINISetting LpmSettingsFile "Deadline_Options" "Deadline_Server" edt1.text
					)
					
				)
				
				on btn1 pressed do
				(
					tmp_path_f = ""
					tmp_path_f = getOpenFileName "Choose Deadline job submission script" filename:"SubmitMaxToDeadline_Functions.ms" types:"MAX Script (*.ms)|*.ms|All files|*.*|" historyCategory:"MAXHistoryList" 
					
					if tmp_path_f != undefined then
					(
						edt1.text = tmp_path_f
					)
					
				)
				
				on btn2 pressed do
				(
					edt1.text = getdir #maxroot + "scripts\\scripts_collect\\"
				)
			)
			createdialog Deadline_options_roll
		)
	)
)
createDialog settingsRO pos:(LPM_Fun.getRoPos  settingsRO.width)