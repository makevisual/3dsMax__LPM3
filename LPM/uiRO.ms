rollout LPM_uiRO "UI Dialog" width:250 height:60
(
	GroupBox 		grp_output 				"Options" 		pos:[5,5] width:235 height:50

	label 			lab_filename 			"Color:" 	pos:[13  ,25] 
	dropdownList 	ddl_chooseColor 		"" 			pos:[60,25] width:120 height:21 items:#(@"Choose Color", @"Black", @"Gray", @"Red")


	fn rebuildTreeView = (
		print("rebuilding treeview")
		tv = LPM_treeview_rollout.tv
		tv.imageList.Images.Clear()
		LPM_treeview_rollout.initTreeView tv
		LPM_treeview_rollout.updateTV()
	)

	on ddl_chooseColor selected picked do (
		LPM_offColorPath = LPM_Dir + "icons/"
		selectedColor = ddl_chooseColor.items[picked]
		case selectedColor of (
			@"Choose Color" : LPM_offColorPath += "grays/"
			@"Black"		: LPM_offColorPath += "blacks/"
			@"Gray"			: LPM_offColorPath += "grays/"
			@"Red"			: LPM_offColorPath += "reds/"
		)

		rebuildTreeView()
	)


)

createDialog LPM_uiRO pos:(LPM_Fun.getRoPos LPM_uiRO.width)