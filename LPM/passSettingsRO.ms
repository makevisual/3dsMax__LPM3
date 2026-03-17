rollout passSettingsRO "Pass Settings" width:264 height:380
(
	
	
	
	GroupBox grp1 "Pass Hide Mode:" pos:[4,7] width:254 height:74
	dropdownList ddlDefaultAction "" pos:[10,26] width:155 height:21 items:#("Do Nothing", "Hide All Objects/Lights", "Unhide All Objects/Lights")
	GroupBox grp2 "Pass Overrides" pos:[4,82] width:254 height:96
	checkbox chkUseRootDir "Alternate Root" pos:[10,101] width:90 height:15
	button btnPickRootDir " Pick" pos:[226,118] width:25 height:16
	edittext etRootDir "" pos:[6,118] width:217 height:17
	checkbox chkUseCustomPath "Alternate Path" pos:[10,138] width:95 height:15
	edittext edtCustomPath "" pos:[6,155] width:247 height:17 text:"$APass\\$APass$Pass\\$Element\\$Max_$APass$Pass_$Element" enabled:false
	GroupBox grp3vr "V-Ray raw image file" pos:[4,179] width:254 height:90
	checkbox chkVRayRaw "Render to V-Ray raw image file" pos:[10,199] width:236 height:18	
	dropdownList ddlVRayRawFileType "" pos:[89,221] width:162 height:21 items:#("V-Ray image files (*.vrimg)", "OpenEXR image files (*.exr)", "V-Ray deep image files (*.vrst)", "V-Ray shade map files (*.vrsm)")
	label lbl1 "Save as type:" pos:[13,223] width:71 height:20
	checkbox chkVRayRawFull "EXR/VRST/VRSM 32-bit output" pos:[10,247] width:165 height:18
	checkbox chkVRayRawDeep "Deep EXR" pos:[182,247] width:68 height:18
	GroupBox grpConverter "Vrimg2exr autoconvert" pos:[5,271] width:254 height:104
	checkbox chkPostConvert "Convert VRImg to EXR" pos:[10,288] width:236 height:18 enabled:false
	label lblCompression "Compression type:" pos:[10,315] width:94 height:20 enabled:false
	dropdownList ddlPostConvertCompression "" pos:[104,314] width:147 height:21 enabled:false items:#("NONE", "RLE - run length encoding", "ZIPS - one scanline at time", "ZIP - in blocks of 16 scanlines", "PIZ - piz-bazed wavelet", "PXR24 - lossy 24bit float") selection:3
	checkbox chkPostConvertHalfFoat "Half float (16 bit) (default 32 bit)" pos:[10,338] width:236 height:18 enabled:false
	checkbox chkPostConvertDatawindow "DataWindow (Autocrop by Alpha)" pos:[10,356] width:236 height:18 enabled:false

	local passArray
	local theNode
	local thePass
	
	fn setEnabled=
	(
		btnPickRootDir.enabled=etRootDir.enabled=chkUseRootDir.checked
	)
	
	on passSettingsRO open do
	(
		LPM_treeviewRollout.FreezeWindow()
		thePass=LPM_treeviewRollout.tv.selectedNode.tag.value
		theNode=LPM_treeviewRollout.tv.selectedNode
		ddlDefaultAction.selection=thePass.hideMode
		chkUseRootDir.checked=thePass.useRootDir
		etRootDir.text=thePass.rootDir
		edtCustomPath.enabled=chkUseCustomPath.checked=thePass.UseCustomPath
		edtCustomPath.text=thePass.CustomPath
		
		ddlDefaultAction.enabled =false

		passArray = for it in (LPM_FUn.getallchildren LPM_Root) where ((it.type=="pass")and(it != thePass)) collect it
		namesArray = for it in passArray collect (LPM_Fun.getName it.name)
		chkVRayRaw.state = thePass.VRayRaw
		ddlVRayRawFileType.selection = thePass.VRayRawFileType
		chkVRayRawFull.state = thePass.VRayRawFull
		chkVRayRawDeep.state = thePass.VRayRawDeep
		chkPostConvert.state = thePass.PostConvert
		ddlPostConvertCompression.selection = thePass.PostConvertCompression
		chkPostConvertHalfFoat.state = thePass.PostConvertHalfFoat
		chkPostConvertDatawindow.state = thePass.PostConvertDatawindow
		
		case thePass.VRayRaw of
		(
			true:
			(
				ddlVRayRawFileType.enabled = true
				chkVRayRawFull.enabled = true
				chkVRayRawDeep.enabled = true
				if ddlVRayRawFileType.selection == 1 then
				(
					chkPostConvert.enabled = true
					if chkPostConvert.state then
					(
						lblCompression.enabled = true
						ddlPostConvertCompression.enabled = true
						chkPostConvertHalfFoat.enabled = true
						chkPostConvertDatawindow.enabled = true
					)
				)
			)
			false:
			(
				ddlVRayRawFileType.enabled = false
				chkVRayRawFull.enabled = false
				chkVRayRawDeep.enabled = false
			)
		)
		
		setEnabled()
	)
	on passSettingsRO close do
	(
		thePass.hideMode=ddlDefaultAction.selection
		thePass.useRootDir=chkUseRootDir.checked
		thePass.rootDir=etRootDir.text
		thePass.UseCustomPath = chkUseCustomPath.checked
		thePass.CustomPath = edtCustomPath.text
		theNode.text=LPM_Fun.generatePassName thePass
		thePass.VRayRaw = chkVRayRaw.checked
		thePass.VRayRawFileType = ddlVRayRawFileType.selection
		thePass.VRayRawFull = chkVRayRawFull.checked
		thePass.VRayRawDeep = chkVRayRawDeep.checked
		thePass.PostConvert = chkPostConvert.state
		thePass.PostConvertCompression = ddlPostConvertCompression.selection
		thePass.PostConvertHalfFoat = chkPostConvertHalfFoat.state
		thePass.PostConvertDatawindow = chkPostConvertDatawindow.state
		LPM_treeviewRollout.updateTV()
		LPM_treeviewRollout.UnFreezeWindow()
	)
	
	on chkUseRootDir changed value do
	(
		setEnabled()
	)
	
	on btnPickRootDir pressed do
	(
		theDir=getsavepath()
		if(theDir!=undefined) then
		(
			etRootDir.text=theDir+"\\"
		)
	)
	
	on chkUseCustomPath changed value do
	(
		edtCustomPath.enabled=value
	)
	
	on chkVRayRaw changed TmpState do
	(
		
		case TmpState of
		(
			true:
			(
				ddlVRayRawFileType.enabled = true
				chkVRayRawFull.enabled = true
				chkVRayRawDeep.enabled = true
				if ddlVRayRawFileType.selection == 1 then
				(
					chkPostConvert.enabled = true
					if chkPostConvert.state then
					(
						lblCompression.enabled = true
						ddlPostConvertCompression.enabled = true
						
						chkPostConvertHalfFoat.enabled = true
						chkPostConvertDatawindow.enabled = true
					)
					
				)
			)
			false:
			(
				ddlVRayRawFileType.enabled = false
				chkVRayRawFull.enabled = false
				chkVRayRawDeep.enabled = false
				
				lblCompression.enabled = false
				ddlPostConvertCompression.enabled = false
				chkPostConvert.enabled = false
				chkPostConvertHalfFoat.enabled = false
				chkPostConvertDatawindow.enabled = false
			)
		)
	)
	on ddlVRayRawFileType selected TmpSel do
	(
		if TmpSel == 1 then
		(
			chkPostConvert.enabled = true
			if chkPostConvert.state then
			(
				lblCompression.enabled = true
				ddlPostConvertCompression.enabled = true
				
				chkPostConvertHalfFoat.enabled = true
				chkPostConvertDatawindow.enabled = true
			)
		)
		else
		(
			lblCompression.enabled = false
			ddlPostConvertCompression.enabled = false
			chkPostConvert.enabled = false
			chkPostConvertHalfFoat.enabled = false
			chkPostConvertDatawindow.enabled = false
		)
	)
	on chkPostConvert changed TmpState do
	(
		case TmpState of
		(
			true:
			(
				
				lblCompression.enabled = true
				ddlPostConvertCompression.enabled = true
				chkPostConvertHalfFoat.enabled = true
				chkPostConvertDatawindow.enabled = true
				
			)
			false:
			(
				lblCompression.enabled = false
				ddlPostConvertCompression.enabled = false
				chkPostConvertHalfFoat.enabled = false
				chkPostConvertDatawindow.enabled = false
			)
		)
	)
	on chk9 changed value do
	(
		setEnabled()
	)
)
createDialog passSettingsRO pos:(LPM_Fun.getRoPos  passSettingsRO.width) 