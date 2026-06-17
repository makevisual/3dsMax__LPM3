
callbacks.removeScripts id:#closeLPM

LPM_Callback="LPM_Fun.destroyAllDialogs()"

callbacks.addScript #filePostOpen LPM_Callback id:#closeLPM
callbacks.addScript #systemPostNew LPM_Callback id:#closeLPM
callbacks.addScript #systemPostReset LPM_Callback id:#closeLPM
try(destroyDialog LPM_treeview_rollout)catch()

try
(
	if LPM_Root.LastActivePass != "" then
	(
		passArray=for it in (LPM_Fun.getallchildren LPM_Root) where it.type=="pass" collect it

		for i = 1 to passArray.count do
		(
			if (LPM_Fun.generatePassName passArray[i]) == LPM_Root.LastActivePass then
			(
				LPM_activePass = passArray[i]
			)
		)
	)
)catch()

LPM_ShowSkipButton = false
LPM_RendButttonSize = 30

if (LPM_Fun.getIni "Settings" "ShowSkipButton" booleanClass false) then
(
	LPM_ShowSkipButton = true
	LPM_RendButttonSize = 20
)

LPM_disabledIconFolder = LPM_Fun.getIni "Settings" "disabledIconColor" string "blacks"
if (getINISetting (getdir #plugcfg + "\\LPM.ini") "Settings" "disabledIconColor") == "" then
	LPM_Fun.setIni "Settings" "disabledIconColor" "blacks"

ilTv = dotNetObject "System.Windows.Forms.ImageList"
ilTv.imageSize = dotNetObject "System.Drawing.Size" 16 15

LPM_BackColor = undefined
LPM_FontColor = undefined

fn CheckUIColor =
(
	CurUIColor = "Light"
	CurUIColorCol = colorMan.getColor #timeSliderBg
	if CurUIColorCol[1] < 0.6 then ( CurUIColor = "Dark" )
	CurUIColor
)

fn getIconFromBitmap iconFileName =
(
	theFileName = LPM_iconPath + iconFileName +".bmp"
	img = dotNetClass "System.Drawing.Image" --create an image
	ilTv.images.add (img.fromFile theFileName) --add to the list
)

fn getIconFromFolder subfolder iconFileName =
(
	theFileName = LPM_iconPath + subfolder + "/" + iconFileName + ".bmp"
	img = dotNetClass "System.Drawing.Image"
	ilTv.images.add (img.fromFile theFileName)
)

fn dotNetColor clr =
(
	(dotNetClass "System.Drawing.Color").fromARGB clr.r clr.g clr.b
)

fn InitColorUI =
(
	LPM_BackColor = dotNetColor (color 85 85 85)
	LPM_FontColor = dotNetColor (color 200 200 200)
)

InitColorUI()

try
(
	if rendOutputFilename == "" then
	(
		rendOutputFilename = (dotNetClass "System.Environment").GetEnvironmentVariable "LOCALAPPDATA" + @"\LPM\render_tmp.exr"
	)
)
catch()

rollout LPM_treeview_rollout ( "LPM v" + LPM_VersionNumber )
(
	local copyNode
	local colorBackup
	local displayColorWire
	local displayColorShaded
	local tvRoot
	local shotRoot
	local shotRootTV
	local prevSelection
	local stopper
	local LPM_doubleClick=false
	local DragNode, DropNode
	local m=dotNetClass "System.Windows.Forms.DragDropEffects" -- Drag and drop effects
	local sTime=timeStamp()
	local oldHitNode=undefined
	local lastMouseDown = timeStamp()
	local preventExpand = false
	local TmpSelNode = undefined
	local nameFieldUpdating = false

	struct leafType (type, leaf, index, active)

	local processorList = #(
	"Render - Local",
	"Render - Submit to Deadline 10",
	"Render - Submit to Deadline 10 - Skip Checks",
	"Export - Bake 3dsMax Files",
	"Preview - TyPreview"
	)

 	dropDownList 		ddl_camera 				"" 			pos:[0,32] width:100 items:#("-----------------------")
		dropDownList 	ddl_previewType 					pos:[120,32] width:60 items:#("View", "Selected", "Region", "Crop", "BlowUp")
 		dropDownList 	ddl_previewSize 		"" 			pos:[160,32] items:#("10","25","50","75","100","150","200") width:45
		button  	 	btn_quickScripts 		"" 			pos:[160,70] height:20 width:20 images:#(LPM_iconPath+"bolt.bmp",undefined,1,1,1,1,1,true)

	dotNetControl 		dnc_nodeName 			"TextBox" 	pos:[0,22] align:#left
		button 			btn_versionUp 			"+" 		pos:[180,22] height:20 width:20 tooltip:"Increment version (e.g. v001 -> v002)"
		button 			btn_versionDown 		"-" 		pos:[200,22] height:20 width:20 tooltip:"Decrement version (e.g. v002 -> v001)"

	dotNetControl 		tv 						"TreeView"  pos:[0,(54-33+22)] align:#left
	dotNetControl 		dnc_textBoxOutputPath 	"TextBox" 	pos:[0,60] align:#left
		button 			btn_setRenderDir 		"Set" 		pos:[185,200] height:21 width:20 tooltip:"Sets the render directory"
		button 			btn_openRenderDir 		"..." 		pos:[202,200] height:21 width:17 tooltip:"Opens the render directory"
	dropDownList    	ddl_selectProcessor 	"" 			pos:[40,200] items:processorList width:200
		button 			btn_execute 			" Execute " pos:[40,200] width:120

	fn updateNodeNameField =
	(
		nameFieldUpdating = true
		local selNode = tv.selectedNode
		if selNode != undefined and selNode.level > 0 then
		(
			local nodeType = selNode.tag.value.type
			local displayName = undefined

			case nodeType of
			(
				"wildcard": ( displayName = selNode.text )
				"shot":     ( displayName = LPM_Fun.getName selNode.tag.value.name )
				"pass":     ( displayName = LPM_Fun.getName selNode.tag.value.name )
				default:    ( try( displayName = LPM_Fun.getName selNode.tag.value.name )catch() )
			)

			if displayName != undefined then
			(
				dnc_nodeName.Enabled = true
				dnc_nodeName.text = displayName
			)
			else
			(
				dnc_nodeName.Enabled = false
				dnc_nodeName.text = ""
			)

			-- Enable +/- only for shots (which have version strings)
			btn_versionUp.enabled = (nodeType == "shot")
			btn_versionDown.enabled = (nodeType == "shot")
		)
		else
		(
			dnc_nodeName.Enabled = false
			dnc_nodeName.text = ""
			btn_versionUp.enabled = false
			btn_versionDown.enabled = false
		)
		nameFieldUpdating = false
	)

	fn FreezeWindow =
	(
		tv.enabled 							= false
		dnc_nodeName.enabled 				= false
		btn_versionUp.enabled 				= false
		btn_versionDown.enabled 			= false
		btn_openRenderDir.enabled 			= false
		ddl_selectProcessor.enabled 		= false
		btn_execute.enabled 				= false
	)

	fn UnFreezeWindow =
	(
		tv.enabled 							= true
		btn_openRenderDir.enabled 			= true
		ddl_selectProcessor.enabled 		= true
		btn_execute.enabled 				= true
		updateNodeNameField()
	)

	fn initTreeView tv=
	(
		-- In the tv init function
		tmpcol = ((colorMan.getColor #timeSliderBg)*255) as color
		dnc_textBoxOutputPath.BackColor = dotNetColor tmpcol
		dnc_textBoxOutputPath.ForeColor = LPM_FontColor
		dnc_textBoxOutputPath.ReadOnly = true
		dnc_nodeName.BackColor = dotNetColor tmpcol
		dnc_nodeName.ForeColor = LPM_FontColor
		dnc_nodeName.Enabled = false
		dnc_nodeName.text = ""
		tv.BackColor = LPM_BackColor
		tv.AllowDrop = true -- allow DragandDrop for the Treeview

		-- Icons are referenced by positional index: append new ones at the END only.
		-- Inserting shifts every later index. See docs/ADDING_AN_OPERATOR.md
		getIconFromBitmap "Root"
		getIconFromBitmap "Pass"
		getIconFromBitmap "objectSet"
		getIconFromBitmap "lightSet"
		getIconFromBitmap "Layers"
		getIconFromBitmap "NamedSet"
		getIconFromBitmap "Wildcard"
		getIconFromBitmap "Node"
		getIconFromBitmap "Render"
		getIconFromBitmap "Enviroment"
		getIconFromBitmap "Common"
		getIconFromFolder LPM_disabledIconFolder "Disabled"
		getIconFromFolder "grays" "objectSetOff"
		getIconFromFolder LPM_disabledIconFolder "objectSetOff"
		getIconFromFolder "grays" "lightSetOff"
		getIconFromFolder LPM_disabledIconFolder "lightSetOff"
		getIconFromBitmap "Shot"
		getIconFromFolder LPM_disabledIconFolder "ShotOff"
		getIconFromBitmap "ShotRoot"
		getIconFromBitmap "xrefOn" --"xrefProps"
		getIconFromBitmap "xrefOn"
		getIconFromFolder LPM_disabledIconFolder "xrefOff"
		getIconFromFolder LPM_disabledIconFolder "CommonOff"
		getIconFromFolder LPM_disabledIconFolder "EnviromentOff"
		getIconFromFolder LPM_disabledIconFolder "RenderOff"
		getIconFromBitmap "missing"
		getIconFromBitmap "missing"
		getIconFromBitmap "passGroupOn"
		getIconFromFolder LPM_disabledIconFolder "passGroupOff"
		getIconFromBitmap "scriptOn"
		getIconFromFolder LPM_disabledIconFolder "scriptOff"
		getIconFromFolder LPM_disabledIconFolder "RootOff"
		getIconFromBitmap "missing" --"ModifyObject"
		getIconFromBitmap "missing" --"ModifyObjectOff"
		getIconFromBitmap "missing" --"Node_group"
		getIconFromBitmap "missing"
		getIconFromBitmap "missing"
		getIconFromBitmap "xrefOn" 	--"xrefObjProps"
		getIconFromFolder LPM_disabledIconFolder "xrefOff" --"xrefObjPropsOff"
		getIconFromFolder LPM_disabledIconFolder "xrefOff" --"xrefPropsOff"
		getIconFromBitmap "missing"
		getIconFromBitmap "missing"
		getIconFromBitmap "missing"
		getIconFromBitmap "missing"
		getIconFromBitmap "missing" --"vray"
		getIconFromBitmap "missing" --"vrayOff"
		getIconFromBitmap "Deadline"
		getIconFromFolder LPM_disabledIconFolder "DeadlineOff"

		-- NOTE -- All additional icons should be added to the end of the list, because icons are called by index
		-- Addition of new items will offset following icons
		-- If you want to remove an icon, replace it with "missing" because icons are integer
		-- based and if the index changes, the icons will be incorrect

		getIconFromBitmap "missing"
		getIconFromBitmap "missing"
		getIconFromBitmap "missing"
		getIconFromBitmap "missing"

		getIconFromBitmap "CameraOverscan"
		getIconFromFolder LPM_disabledIconFolder "CameraOverscanOff"
		getIconFromBitmap "NukeExportOperator"
		getIconFromFolder LPM_disabledIconFolder "NukeExportOperatorOff"
		getIconFromBitmap "AfterEffectsExportOperator"
		getIconFromFolder LPM_disabledIconFolder "AfterEffectsExportOperatorOff"

		getIconFromBitmap "missing"
		getIconFromBitmap "missing"
		getIconFromBitmap "missing"
		getIconFromBitmap "missing"

		getIconFromBitmap "vrayRenderElements"
		getIconFromFolder LPM_disabledIconFolder "vrayRenderElementsOff"

		getIconFromBitmap "renderImage"
		getIconFromFolder LPM_disabledIconFolder "renderImageOff"

		-- indices 66 / 67 (placeholder art — copy of Render icons; replace when art exists)
		getIconFromBitmap "TyPreview"
		getIconFromFolder LPM_disabledIconFolder "TyPreviewOff"

		tv.imageList = ilTv
		tv.LabelEdit = true
	)

	fn deleteSelectedPass tv =
	(
		theNode=tv.selectedNode
		for jt in (LPM_Fun.getAllChildren theNode.tag.value) do delete jt
		theNode.Remove()
	)

	fn offsetSelectedShot tv arg_mode =
	(
		-- Get the node
		theNode=tv.selectedNode

		-- offset the version string - Passing the #increment or #decrement modes
		newString = LPM_Fun.offsetVersionString theNode.tag.value.name arg_mode

		-- Have to put this prefix on, LPM is expecting it and will trim the name.
		newString = ("LPM_"+newString) 

		-- Assign the new name and update the node text directly (preserves selection)
		theNode.tag.value.name = newString
		local nodeType = theNode.tag.value.type
		if nodeType == "shot" then
			theNode.text = LPM_Fun.getShotName theNode.tag.value
		else
			theNode.text = LPM_Fun.generatePassName theNode.tag.value
	)

	fn duplicateSelectedShot tv =
	(
		theNode=tv.selectedNode

		-- add each of the nodes to a list to clone
		curNodes = #()
		for jt in (LPM_Fun.getAllChildren theNode.tag.value) do (append curNodes jt)
		-- Clone the nodes
		maxOps.cloneNodes curNodes cloneType:#copy newNodes:&nnl #nodialog
	)

	fn makeItalic theNode=
	(
		try(
			obj=theNode.tag.value
			if(isValidNode obj) then
		(
			if(InstanceMgr.GetInstances obj #() >1) then
			(
				theNode.nodefont = dotnetobject "system.drawing.font" (dotnetobject "system.drawing.fontfamily" "tahoma") 8.5  (dotNetClass "system.drawing.fontStyle").italic
			)
		)
		
		)catch() 
	)

	fn createTVnode nodeRoot theNode nodeType:"LPM_node" =
	(
		nodeName = ""
		-- Per-node-type display label. New operators add a case here; see docs/ADDING_AN_OPERATOR.md
		case nodeType of
		(
			"leaf": 				nodeName = theNode.leaf
			"leafObject": 			nodeName = theNode.leaf.name
			"leafXref": 			nodeName = ((getFilenameFile theNode.leaf[1])+(getFilenameType theNode.leaf[1]))
			"commonProps": 			nodeName = (LPM_Fun.generateCommonPropName theNode)
			"vrayProps": 			nodeName = (LPM_Fun.generateVrayPropName theNode)
			"passRoot": 			nodeName = ( "Passes" )
			"shotRoot": 			nodeName = ( "Shots" )
			"Deadline": 			nodeName = (LPM_Fun.generateDeadlineName theNode)
					"vrayRenderElements": 	nodeName = (LPM_Fun.generateVrayRenderElementsName theNode)
			"cameraOverscan": 		nodeName = (LPM_Fun.generateCameraOverscanName theNode)
			"tyPreview": 			nodeName = (LPM_Fun.generateTyPreviewName theNode)
			"renderImage": 			nodeName = (LPM_Fun.generateRenderImageName theNode)
			"nukeExport": 			nodeName = (LPM_Fun.generateNukeExportName theNode)
			"aeExport": 			nodeName = (LPM_Fun.generateAeExportName theNode)

			default: nodeName = (LPM_Fun.getName theNode.name)
		)

		newNode = nodeRoot.Nodes.Add nodeName
		newNode.tag=dotNetMXSValue theNode
 		newNode.BackColor = LPM_BackColor
 		newNode.ForeColor = LPM_FontColor

		LPM_Fun.setIcon newNode
		newNode
	)

	fn createPassTv objPass nodeParent =
	(
		newPass = createTVnode nodeParent objPass

		newPass.ForeColor = LPM_FontColor
		newPass.BackColor = LPM_BackColor
		newPass.nodefont = dotnetobject "system.drawing.font" (dotnetobject "system.drawing.fontfamily" "tahoma") 8.5  (dotNetClass "system.drawing.fontStyle").bold
		thePass = newPass.tag.value
		newPass.text =  LPM_Fun.generatePassName thePass

		newPass
	)

	fn createPassGroupTv pg=
	(
		tmp_PassGroupTv = createTVnode tvRoot pg

		tmp_PassGroupTv.ForeColor = LPM_FontColor
		tmp_PassGroupTv.BackColor = LPM_BackColor
		tmp_PassGroupTv
	)

	fn addPassTv newPass=
	(
		newPass.nodes.clear()
		pmPass=newPass.tag.value

		allObjSet=for obj in pmPass.children where obj.type=="objectSet" collect obj

		for i=1 to allObjSet.count do
		(
			obj=allObjSet[1+allObjSet.count-i]
			newObj = createTVnode newPass obj
			makeItalic newObj
			newObj.ForeColor = LPM_FontColor
			newObj.BackColor = LPM_BackColor
			for i=1 to obj.wildCard.count do
			(
				newNode = createTVnode newObj (leafType "wildCard" obj.wildCard[i] i) nodeType:"leaf"

				newNode.ForeColor = LPM_FontColor
				newNode.BackColor = LPM_BackColor
			)
			for i=1 to obj.namedSet.count do
			(
				newNode = createTVnode newObj (leafType "namedSet" obj.namedSet[i] i) nodeType:"leaf"

				newNode.ForeColor = LPM_FontColor
				newNode.BackColor = LPM_BackColor
			)
			for i in obj.layers do
			(
				newNode = createTVnode newObj (leafType "layer" i) nodeType:"leaf"

				newNode.ForeColor = LPM_FontColor
				newNode.BackColor = LPM_BackColor
			)
			for i in obj.mats do
			(
				newNode = createTVnode newObj (leafType "mat" i) nodeType:"leaf"

				newNode.ForeColor = LPM_FontColor
				newNode.BackColor = LPM_BackColor
			)

			for i in obj.nodes do
			(
				if(isvalidnode i) then
				(
					newNode = createTVnode newObj (leafType "object" i) nodeType:"leafObject"

					newNode.ForeColor = LPM_FontColor
					newNode.BackColor = LPM_BackColor
				)
			)
			if(obj.expanded) then
				newObj.expand()
		)

		allLightSets=for obj in pmPass.children where obj.type=="lightSet" collect obj

		for i=1 to allLightSets.count do
		(
			obj=allLightSets[1+allLightSets.count-i]
			newObj = createTVnode newPass obj

			newObj.ForeColor = LPM_FontColor
			newObj.BackColor = LPM_BackColor

			makeItalic newObj

			for i=1 to obj.wildCard.count do
			(
				newNode = createTVnode newObj (leafType "wildCard" obj.wildCard[i] i) nodeType:"leaf"

				newNode.ForeColor = LPM_FontColor
				newNode.BackColor = LPM_BackColor
			)
			for i=1 to obj.namedSet.count do
			(
				newNode = createTVnode newObj (leafType "namedSet" obj.namedSet[i] i) nodeType:"leaf"

				newNode.ForeColor = LPM_FontColor
				newNode.BackColor = LPM_BackColor
			)
			for i in obj.layers do
			(
				newNode = createTVnode newObj (leafType "layer" i) nodeType:"leaf"

				newNode.ForeColor = LPM_FontColor
				newNode.BackColor = LPM_BackColor
			)
			for i in obj.nodes do
			(
				if(isvalidnode i) then
				(
					newNode = createTVnode newObj (leafType "object" i) nodeType:"leafObject"

					newNode.ForeColor = LPM_FontColor
					newNode.BackColor = LPM_BackColor
				)
			)
			if(obj.expanded) then
				newObj.expand()
		)

		commonProps=LPM_Fun.firstChildByType pmPass "commonProps"
		if(commonProps!=undefined) then
		(
			newCP = createTVnode newPass commonProps nodeType:"commonProps"

			newCP.ForeColor = LPM_FontColor
			newCP.BackColor = LPM_BackColor
			makeItalic newCP
		)

		allRenderProps=for obj in pmPass.children where obj.type=="renderProps" collect obj
		for renderProps in allRenderProps do
		(
			newRP = createTVnode newPass renderProps

			newRP.ForeColor = LPM_FontColor
			newRP.BackColor = LPM_BackColor
			makeItalic newRP
		)

		allVrayProps=for obj in pmPass.children where obj.type=="vrayProps" collect obj
		for vrayProps in allVrayProps do
		(
			newVP = createTVnode newPass vrayProps nodeType:"vrayProps"

			newVP.ForeColor = LPM_FontColor
			newVP.BackColor = LPM_BackColor

			makeItalic newVP
		)

		envProps=LPM_Fun.firstChildByType pmPass "envProps"
		if(envProps!=undefined) then
		(
			newEnv = createTVnode newPass envProps

			newEnv.ForeColor = LPM_FontColor
			newEnv.BackColor = LPM_BackColor
			makeItalic newEnv
		)

		xrefObjProps=LPM_Fun.firstChildByType pmPass "xrefObj"
		if(xrefObjProps!=undefined) then
		(
			newXR = createTVnode newPass xrefObjProps

			newXR.ForeColor = LPM_FontColor
			newXR.BackColor = LPM_BackColor
			makeItalic newXR
		)

		xrefSceneProps=LPM_Fun.firstChildByType pmPass "xrefScene"
		if(xrefSceneProps!=undefined) then
		(
			newXR = createTVnode newPass xrefSceneProps

			newXR.ForeColor = LPM_FontColor
			newXR.BackColor = LPM_BackColor

			makeItalic newXR
		)

		for script in pmPass.children where script.type=="script" do
		(
			nScript = createTVnode newPass script

			nScript.ForeColor = LPM_FontColor
			nScript.BackColor = LPM_BackColor
			makeItalic nScript
		)

		for op in pmPass.children where op.type=="generic" do
		(
			opTVNode=createTVnode newPass op

			opTVNode.ForeColor = LPM_FontColor
			opTVNode.BackColor = LPM_BackColor
		)

		for Modif in pmPass.children where Modif.type=="ModifierOver" do
		(
			newModifierOver=createTVnode newPass Modif

			newModifierOver.ForeColor = LPM_FontColor
			newModifierOver.BackColor = LPM_BackColor
			makeItalic newModifierOver
		)


		for Deadline in pmPass.children where Deadline.type=="Deadline" do
		(
			newDeadline=createTVnode newPass Deadline nodeType:"Deadline"

			newDeadline.ForeColor = LPM_FontColor
			newDeadline.BackColor = LPM_BackColor
			makeItalic newDeadline
		)



		for vrayRenderElements in pmPass.children where vrayRenderElements.type=="vrayRenderElements" do
		(
			newVrayRenderElements=createTVnode newPass vrayRenderElements nodeType:"vrayRenderElements"

			newVrayRenderElements.ForeColor = LPM_FontColor
			newVrayRenderElements.BackColor = LPM_BackColor
			makeItalic newVrayRenderElements
		)

		if(pmPass.expanded) then ( newPass.Expand() )
	)

	fn createShotTv shotNode=
	(
		newShot = createTVnode shotRootTV shotNode

		newShot.ForeColor = LPM_FontColor
		newShot.BackColor = LPM_BackColor
		newShot.nodefont = dotnetobject "system.drawing.font" (dotnetobject "system.drawing.fontfamily" "tahoma") 8.5  (dotNetClass "system.drawing.fontStyle").bold
		newShot
	)

	fn addShotTv newShot=
	(
		newShot.nodes.clear()
		pmShot=newShot.tag.value

		commonProps=LPM_Fun.firstChildByType pmShot "commonProps"
		if(commonProps!=undefined) then
		(
			newCP = createTVnode newShot commonProps nodeType:"commonProps"

			newCP.ForeColor = LPM_FontColor
			newCP.BackColor = LPM_BackColor
			makeItalic newCP
		)


		cameraOverscan=LPM_Fun.firstChildByType pmShot "cameraOverscan"
		if(cameraOverscan!=undefined) then
		(
			newCP = createTVnode newShot cameraOverscan nodeType:"cameraOverscan"

			newCP.ForeColor = LPM_FontColor
			newCP.BackColor = LPM_BackColor
			makeItalic newCP
		)


		tyPreview=LPM_Fun.firstChildByType pmShot "tyPreview"
		if(tyPreview!=undefined) then
		(
			newCP = createTVnode newShot tyPreview nodeType:"tyPreview"

			newCP.ForeColor = LPM_FontColor
			newCP.BackColor = LPM_BackColor
			makeItalic newCP
		)


		renderImage=LPM_Fun.firstChildByType pmShot "renderImage"
		if(renderImage!=undefined) then
		(
			newCP = createTVnode newShot renderImage nodeType:"renderImage"

			newCP.ForeColor = LPM_FontColor
			newCP.BackColor = LPM_BackColor
			makeItalic newCP
		)


		nukeExport=LPM_Fun.firstChildByType pmShot "nukeExport"
		if(nukeExport!=undefined) then
		(
			newCP = createTVnode newShot nukeExport nodeType:"nukeExport"

			newCP.ForeColor = LPM_FontColor
			newCP.BackColor = LPM_BackColor
			makeItalic newCP
		)


		aeExport=LPM_Fun.firstChildByType pmShot "aeExport"
		if(aeExport!=undefined) then
		(
			newCP = createTVnode newShot aeExport nodeType:"aeExport"

			newCP.ForeColor = LPM_FontColor
			newCP.BackColor = LPM_BackColor
			makeItalic newCP
		)

		if(pmShot.allPasses==false) then
		(
			--get rid of invalid passes
			np=#()
			ni=#()
			for i=1 to pmShot.passes.count where isvalidNode pmShot.passes[i] do
			(
				append np pmShot.passes[i]
				if(pmShot.passesOn[i]==true) then
					append ni true
				else
					append ni false
				newNode = createTVnode newShot (leafType "ShotPass" (pmShot.passes[i]) i ni[i]) nodeType:"leafObject"

				newNode.text = LPM_Fun.generatePassName pmShot.passes[i]
				newNode.ForeColor = LPM_FontColor
				newNode.BackColor = LPM_BackColor
			)
			-- CA writes dirty the scene and redraw the viewport on every tree
			-- rebuild, so only write back when invalid passes were pruned
			if(np.count != pmShot.passes.count) or (ni.count != pmShot.passesOn.count) then
			(
				pmShot.passes=np
				pmShot.passesOn=ni
			)
		)
		else
		(
			pmAllpasses = createTVnode newShot (leafType "ShotPassAll" "All Active Passes") nodeType:"leaf"

			pmAllpasses.ForeColor = LPM_FontColor
			pmAllpasses.BackColor = LPM_BackColor
		)

		if(pmShot.expanded) then
		(	newShot.Expand()
		)
	)

	fn fillInTreeView tv =
	(
		--Add the Root
		tv.beginUpdate()

		tvRoot = createTVnode tv LPM_Root nodeType:"passRoot"
		tvRoot.ForeColor = LPM_FontColor
		tvRoot.BackColor = LPM_BackColor

		--add the passes
		count=0
		for pg in LPM_Root.children where pg.type=="passGroup" do
		(
			newPG = createPassGroupTv pg

			for pmPass in pg.children where pmPass.type=="pass" do
			(
				newPass=createPassTv pmPass newPG
				addPassTv newPass
			)
			if(pg.expanded) then
				newPG.expand()
		)

		for pmPass in LPM_Root.children where pmPass.type=="pass" do
		(
			newPass = createPassTv pmPass tvRoot
			newPass.ForeColor = LPM_FontColor
			newPass.BackColor = LPM_BackColor
			addPassTv newPass
		)

		shotRoot=(LPM_Fun.firstChildByType LPM_Root "shotRoot")
		shotRootTV = createTVnode tv (LPM_Fun.firstChildByType LPM_Root "shotRoot") nodeType:"shotRoot"
		shotRootTV.ForeColor = LPM_FontColor
		shotRootTV.BackColor = LPM_BackColor

		--add the shots
		count=0
		for pmShot in shotRoot.children where pmShot.type=="shot" do
		(
			newShot=createShotTv pmShot
			addShotTv newShot
		)

		tvRoot.Expand()
		if(shotRoot.expanded) then ( shotRootTv.expand() )
		tv.endUpdate()
	)

	fn reloadIcons =
	(
		tv.imageList = undefined
		ilTv.images.clear()
		initTreeView tv
		tv.nodes.clear()
		fillInTreeView tv
	)

	fn hideByPass thePass=
	(
		with redraw off
		(

			if(isvalidnode thePass) then
			(
				lMan=layerManager
				if (thePass.hideMode >1) then
				(

					for i=0 to (lMan.count-1) do
					(
						theLayer=lMan.getLayer i
						if(theLayer.name!="zz-LPM")then
						(
							theLayer.isHidden=false
						)
					)

					val=true
					if(thePass.hideMode==3) then val=false

					for it in objects where ((superclassof it)!=light)and(classof it != Targetobject ) and (superclassof it !=camera) do
					(
						it.ishidden = val
					)
					for it in lights where ((superclassof it)==light) do
					(
						it.ishidden = val

						try(it.enabled=(not val))catch()
						try(it.on=(not val))catch()
					)
				)

				--collect object nodes array
				objNodes=#()
				objSetArray=#()
				LPM_Fun.getObjectSetArrays thePass "objectSet" &objNodes &objSetArray

				for k=1 to objNodes.count do
				(
					for theNode in objNodes[k] where  (classof theNode != Targetobject ) and (superclassof thenode !=camera) do
					(

						if(objSetArray[k].visible==2) then
						(
							unHide theNode
						)
						else if (objSetArray[k].visible==3) then
						(
							hide theNode
						)
						else if(objSetArray[k].intp[1]==3) then
						(
							hide theNode
						)
						else if(objSetArray[k].intp[1]==2) then
						(
							unHide theNode
						)

						if(objSetArray[k].selectable==2) then
							unfreeze theNode
						else if(objSetArray[k].selectable==3) then
							freeze theNode
					)
				)

				lightNodes=#()
				lightSetArray=#()
				LPM_Fun.getObjectSetArrays thePass "lightSet" &lightNodes &lightSetArray

				for k=1 to lightNodes.count do
				(
					for theNode in lightNodes[k] do
					(
						if(lightSetArray[k].pEnable==3)  then
						(
							hide theNode
							try
							(
								theNode.on = false
							)
							catch()
							try
							(
								theNode.enabled = false
							)
							catch()
						)
						if(lightSetArray[k].pEnable==2)  then
						(
							unhide theNode
							try
							(
								theNode.on = true
							)
							catch()
							try
							(
								theNode.enabled = true
							)
							catch()
						)
					)
				)

				xrefSceneProps=LPM_Fun.firstChildByType thePass "xrefScene"
				if(isvalidnode xrefSceneProps)and(xrefSceneProps.active) then
				(
					--set the scenes, only touching xrefs whose state actually changes
					for i=1 to xrefs.getXRefFileCount() do
					(
						theXref=(xrefs.getXRefFile i)
						newDisabled=((findItem xrefSceneProps.fileNames theXref.fileName)==0)
						if(theXref.disabled!=newDisabled) then
						(
							if(not newDisabled) and (not (doesFileExist theXref.fileName)) then
								format "LPM warning: xref scene file missing, leaving unloaded: %\n" theXref.fileName
							else
								try(theXref.disabled=newDisabled)
								catch(format "LPM warning: failed to set xref scene state: %\n" theXref.fileName)
						)
					)
				)

				xrefObjProps=LPM_Fun.firstChildByType thePass "xrefObj"
				if(isvalidnode xrefObjProps)and(xrefObjProps.active) then
				(
					--set the objects, only touching records whose state actually changes
					for i=1 to objXRefMgr.recordCount do
					(
						theXref=(objXRefMgr.GetRecord i)
						newEnabled=((findItem xrefObjProps.fileNames theXref.srcFileName)!=0)
						if(theXref.enabled!=newEnabled) then
						(
							if(newEnabled) and (not (doesFileExist theXref.srcFileName)) then
								format "LPM warning: xref object source file missing, leaving disabled: %\n" theXref.srcFileName
							else
								try(theXref.enabled=newEnabled)
								catch(format "LPM warning: failed to set xref object state: %\n" theXref.srcFileName)
						)
					)
				)

				ModifMiddleSetting = LPM_Fun.getIni "Settings" "ModifMiddleSetting" booleanClass false

				if ModifMiddleSetting then
				(
					ModifierOverNodes=for child in thePass.children where child.type=="ModifierOver" and(child.active) do
					(
						myObject = child.activeNode

						if(isvalidnode myObject) then
						(
							for modi in myObject.modifiers do
							(
								if (findItem child.activeModifiers modi.name !=0) then
									modi.enabled=true
								else
									modi.enabled=false
							)
						)
					)
				)

				RendMiddleSetting = LPM_Fun.getIni "Settings" "RendMiddleSetting" booleanClass false

				if RendMiddleSetting then
				(
					theRenderProps=for it in thePass.children where ((it.type=="renderProps") and (it.initialized) and (it.active)) collect it
					if( theRenderProps[1]!=undefined) then
					(
						if (queryBox "Apply renderer settings override?" title:"Warning!") then
						(
							try
							(
								LPM_Fun.loadRenderPresetNew theRenderProps[1].propsAlternate
							)
							catch
							(
								LPM_Fun.loadRenderPreset theRenderProps[1].props
							)
						)
					)
				)

				commonPropsMiddle = LPM_Fun.getIni "Settings" "TimeMiddleSetting" booleanClass true

				if commonPropsMiddle then
				(
					cp=LPM_Fun.firstChildByType thePass "commonProps"
					if(cp!=undefined)and(cp.active) then
					(
						if(cp.cameraTgl==true) then
						(
							try(
									hide cameras

									theViewport=viewport.activeViewport
									case LPM_Fun.getIni "Settings" "shotViewport" string "Active Viewport" of
									(
										"Viewport 1": theViewport=1
										"Viewport 2":if(viewport.numviews >= 2) then theViewport=2
										"Viewport 3":if(viewport.numviews >= 3) then theViewport=3
										"Viewport 4":if(viewport.numviews >= 4) then theViewport=4
									)
									viewport.activeViewport=theViewport
									viewport.setCamera cp._Camera
									--select cp._Camera
									unhide cp._Camera

									if(isvalidnode cp._Camera.target) then
										unhide cp._Camera.target

								)catch()
						)

						if(cp.timeOutputTgl==true) then
						(
							try
							(
								case cp._rendTimeType of
								(
									3:
									(
										sliderTime = cp._rendStart
									)
									4:
									(
										tmparr = filterString cp._rendPickupFrames ", -"

										if tmparr.count != 0 then
										(
											sliderTime = tmparr[1] as time
										)
									)
									default:()
								)
							)
							catch()

						)

						if(cp.outputSizeTgl==true) then
						(
							renderWidth = cp._renderWidth
							renderHeight = cp._renderHeight
						)
					)
				)
			)
		)
	)

	fn hideByActivePass =
	(
		if(isvalidnode LPM_activePass) then(hideByPass  LPM_activePass)
	)

	fn updateddl_camera =
	(
		--camera
		cameraList=#(("Active Viewport:"+(substring (viewport.getType() as string) 6 -1)))
		curCameras = cameras as array
		for i in curCameras where (classof i!=Targetobject) do append cameraList i.name
		ddl_camera.items=cameraList

		if(isvalidNode LPM_Root.renderCamera) then
		(
			x=(findItem  ddl_camera.items LPM_Root.renderCamera.name)
			if (x!=0) then
			ddl_camera.selection=x
		)
	)

	fn LPM_Resize theSize=
	(
		-- Control for minimum size
		ySize 		= ((theSize.y - (104 - 34) - 22) as integer)
		if(ySize<0) then(ysize=0)

		-- make some useful numbers
		xSize 		= ((theSize.x))
		yPos 		= ((theSize.y - 48) as integer)

		-- Row 1: Camera + preview dropdowns
		ddl_camera.pos 					= [0,0]
		ddl_camera.width 				= amax #(20, (xSize-123))
		ddl_previewType.pos 			= [ xSize-124, 	ddl_camera.pos[2] ]
		ddl_previewSize.pos 			= [ xSize-65, 	ddl_camera.pos[2] ]
		btn_quickScripts.pos 			= [ xSize-20, 	ddl_camera.pos[2] ]

		-- Row 2: Node name field + version buttons
		dnc_nodeName.pos 				= [0, 22]
		dnc_nodeName.width 				= xSize - 42
		btn_versionUp.pos 				= [xSize-40, 22]
		btn_versionDown.pos 			= [xSize-20, 22]

		-- TreeView (shifted down by 22 for name field row)
		-- Size via the MaxScript wrapper pos/width/height, which Max scales for
		-- High-DPI monitors. Raw System.Drawing Size/Point bypass that scaling
		-- and leave the control undersized at e.g. 150% Windows UI scale.
		tv.pos 							= [0, 43]
		tv.width 						= xSize
		tv.height 						= ySize

		dnc_textBoxOutputPath.pos 		= [0,yPos+2]
		dnc_textBoxOutputPath.width 	= xSize-42
		btn_setRenderDir.pos 			= [xSize-40,yPos+2]
		btn_openRenderDir.pos 			= [xSize-20,yPos+2]

		ddl_selectProcessor.pos 		= [0,yPos+25]
		ddl_selectProcessor.width 		= (xSize-123)
		btn_execute.pos 				= [(xSize-123),(yPos+25)]
	)

	fn collapseAlltree = ( tv.CollapseAll() )

	fn updateTV=
	(
		-- rebuilding the tree can touch scene CAs; keep the viewport quiet
		with redraw off
		(
			tv.nodes.clear()
			fillInTreeView tv
		)
	)

	fn AddScriptOverride =
	(
		tmpScrPos = LPM_Fun.getRoPos 610

		ScriptFloater = newRolloutFloater "Script" 600 530 tmpScrPos.x tmpScrPos.y

		addRollout LPM_scriptRO1 ScriptFloater
		addRollout LPM_scriptRO2 ScriptFloater
		addRollout LPM_scriptRO3 ScriptFloater rolledUp:true
		addRollout LPM_scriptRO4 ScriptFloater rolledUp:true
	)

	fn AddModifierOverride =
	(
		createdialog ModifierOverRollout pos:(LPM_Fun.getRoPos  ModifierOverRollout.width)
	)


	fn EditDeadline =
	(
		createDialog LPMDeadline pos:(LPM_Fun.getRoPos  250) style:#(#style_titlebar,#style_border, #style_sysmenu,#style_resizing)
	)


	fn EditVrayRenderElements =
	(
		createDialog vrayRenderElementsPropsRoll pos:(LPM_Fun.getRoPos  250) style:#(#style_titlebar,#style_border, #style_sysmenu,#style_resizing)
	)


	fn EditCameraOverscan =
	(
		createDialog cameraOverscanPropsRoll pos:(LPM_Fun.getRoPos  250) style:#(#style_titlebar,#style_border, #style_sysmenu,#style_resizing)
	)


	fn EditTyPreview =
	(
		createDialog tyPreviewPropsRoll pos:(LPM_Fun.getRoPos  250) style:#(#style_titlebar,#style_border, #style_sysmenu,#style_resizing)
	)


	fn EditRenderImage =
	(
		createDialog renderImagePropsRoll pos:(LPM_Fun.getRoPos  250) style:#(#style_titlebar,#style_border, #style_sysmenu,#style_resizing)
	)


	fn EditNukeExport =
	(
		messagebox "Nuke Export is not yet implemented in LPM."
	)


	fn EditAeExport =
	(
		messagebox "After Effects Export is not yet implemented in LPM."
	)

	fn AddXrefSceneOverride =
	(
		createdialog XrefSceneRollout pos:(LPM_Fun.getRoPos  XrefSceneRollout.width) style:#(#style_titlebar,#style_border, #style_sysmenu,#style_resizing,#style_minimizebox)
	)

	fn AddXrefObjOverride =
	(
		createdialog XrefObjRollout pos:(LPM_Fun.getRoPos  XrefObjRollout.width) style:#(#style_titlebar,#style_border, #style_sysmenu,#style_resizing,#style_minimizebox)
	)

	fn addSelectedObjects=
	(
		theObjectSet=tv.selectedNode.tag.value

		for i=1 to selection.count do
		(
			if not isGroupHead(selection[i]) then
				theObjectSet.Nodes[theObjectSet.Nodes.count+1]=selection[i]
		)
		thePassNode=tv.selectedNode.parent
		addPassTv thePassNode

		LPM_treeview_rollout.updateTV()
	)

	fn addSelectedGroups=
	(
		theObjectSet=tv.selectedNode.tag.value
		for i=1 to selection.count do
		(
			if isGroupHead(selection[i]) then
				theObjectSet.Nodes[theObjectSet.Nodes.count+1]=selection[i]
		)
		thePassNode=tv.selectedNode.parent
		addPassTv thePassNode

		LPM_treeview_rollout.updateTV()
	)

	fn addWildcard=
	(
		theObjectSet=tv.selectedNode.tag.value
		theObjectSet.wildCard[theObjectSet.wildCard.count+1]="*"
		thePassNode=tv.selectedNode.parent
		addPassTv thePassNode

		LPM_treeview_rollout.updateTV()
	)

	fn addVisibleLayers=
	(
		createDialog layerPicker lockHeight:false lockWidth:false style:#(#style_titlebar,#style_border, #style_sysmenu,#style_resizing,#style_minimizebox) pos:(LPM_Fun.getRoPos  (LPM_Fun.getIni "Layer Picker" "X_Size" integer 185))
	)

	fn addNamedSet=
	(
		createDialog setPicker pos:(LPM_Fun.getRoPos setPicker.width)
	)

	fn addMats=
	(
		createDialog matPicker pos:(LPM_Fun.getRoPos matPicker.width)
	)

	fn renameNode iNode=
	(
		iNode.BeginEdit()
	)

	fn hideBySet theSet=
	(
		with redraw off
		(
			--collect object nodes array
			objNodes=#()
			objSetArray=#()

			LPM_Fun.getObjectSetArrays LPM_activePass theSet.type &objNodes &objSetArray

			if(not keyboard.controlpressed) then
				for theNode in objects where  (classof theNode != Targetobject ) and (superclassof thenode !=camera)  do
					hide theNode

			for k=1 to objNodes.count do
			(
				if(objSetArray[k]==theSet) then
				for theNode in objNodes[k] do
				(
					unhide theNode
				)
			)
		)
	)

 	-- reparents the nodes of the selected type
	 fn tvReparent tvParent nodeType=
	(
		 nodes=tvParent.nodes
		 for i=0 to (nodes.count-1) where nodes.item[i].tag.value.type==nodeType do nodes.item[i].tag.value.parent=undefined

		 if(nodeType=="objectSet") or (nodeType =="lightSet") then--backward for objectSets and lightSets
			for i=0 to (nodes.count-1) where nodes.item[(nodes.count-1)-i].tag.value.type==nodeType do nodes.item[(nodes.count-1)-i].tag.value.parent=tvParent.tag.value
		 else
			for i=0 to (nodes.count-1) where nodes.item[i].tag.value.type==nodeType do nodes.item[i].tag.value.parent=tvParent.tag.value
	)

	fn CopySetProps =
	(
		if(LPM_treeview_rollout.tv.selectedNode.tag.value.type=="objectSet") then
		(
			LPM_ObjSetPropsBuff = LPM_ObjSetProps()

			theObjectSet=LPM_treeview_rollout.tv.selectedNode.tag.value

			LPM_ObjSetPropsBuff.intP = #()
			for i = 1 to theObjectSet.intP.count do
			(
				LPM_ObjSetPropsBuff.intP[i] = theObjectSet.intP[i]
			)

			LPM_ObjSetPropsBuff.pMatEnable = theObjectSet.pMatEnable
			LPM_ObjSetPropsBuff.pMaterial = theObjectSet.pMaterial
			LPM_ObjSetPropsBuff.expanded = theObjectSet.expanded
			LPM_ObjSetPropsBuff.pColor = theObjectSet.pColor
			LPM_ObjSetPropsBuff.visible = theObjectSet.visible
			LPM_ObjSetPropsBuff.selectable = theObjectSet.selectable
			LPM_ObjSetPropsBuff.userProp = theObjectSet.userProp
		)
		else
		(
			LPM_LightSetDataBuff = LPM_LightSetData()

			theLightSet=LPM_treeview_rollout.tv.selectedNode.tag.value

			LPM_LightSetDataBuff.pEnable = theLightSet.pEnable
			LPM_LightSetDataBuff.pMultiplierEnable = theLightSet.pMultiplierEnable
			LPM_LightSetDataBuff.pMultiplier = theLightSet.pMultiplier
			LPM_LightSetDataBuff.pColorEnable = theLightSet.pColorEnable
			LPM_LightSetDataBuff.pColor = theLightSet.pColor
			LPM_LightSetDataBuff.pCastShadows = theLightSet.pCastShadows
			LPM_LightSetDataBuff.pAffectDiffuse = theLightSet.pAffectDiffuse
			LPM_LightSetDataBuff.pAffectSpecular = theLightSet.pAffectSpecular
			LPM_LightSetDataBuff.pAffectReflections = theLightSet.pAffectReflections
			LPM_LightSetDataBuff.pTextureEnable = theLightSet.pTextureEnable
			LPM_LightSetDataBuff.pTexture = theLightSet.pTexture
			LPM_LightSetDataBuff.expanded = theLightSet.expanded
		)

		LPM_treeview_rollout.updateTV()
	)

	fn PasteSetProps =
	(
		if(LPM_treeview_rollout.tv.selectedNode.tag.value.type=="objectSet")and(LPM_ObjSetPropsBuff.intp!=undefined) then
		(
			theObjectSet=LPM_treeview_rollout.tv.selectedNode.tag.value
			theObjectSet.intP = LPM_ObjSetPropsBuff.intP
			theObjectSet.pMatEnable = LPM_ObjSetPropsBuff.pMatEnable
			theObjectSet.pMaterial = LPM_ObjSetPropsBuff.pMaterial
			theObjectSet.expanded = LPM_ObjSetPropsBuff.expanded
			theObjectSet.pColor = LPM_ObjSetPropsBuff.pColor
			theObjectSet.visible = LPM_ObjSetPropsBuff.visible
			theObjectSet.selectable = LPM_ObjSetPropsBuff.selectable
			theObjectSet.userProp = LPM_ObjSetPropsBuff.userProp
		)

		if(LPM_treeview_rollout.tv.selectedNode.tag.value.type=="lightSet")and(LPM_LightSetDataBuff.pEnable!=undefined) then
		(
			theLightSet=LPM_treeview_rollout.tv.selectedNode.tag.value
			theLightSet.pEnable = LPM_LightSetDataBuff.pEnable
			theLightSet.pMultiplierEnable = LPM_LightSetDataBuff.pMultiplierEnable
			theLightSet.pMultiplier = LPM_LightSetDataBuff.pMultiplier
			theLightSet.pColorEnable = LPM_LightSetDataBuff.pColorEnable
			theLightSet.pColor = LPM_LightSetDataBuff.pColor
			theLightSet.pCastShadows = LPM_LightSetDataBuff.pCastShadows
			theLightSet.pAffectDiffuse = LPM_LightSetDataBuff.pAffectDiffuse
			theLightSet.pAffectSpecular = LPM_LightSetDataBuff.pAffectSpecular
			theLightSet.pAffectReflections = LPM_LightSetDataBuff.pAffectReflections
			theLightSet.pTextureEnable = LPM_LightSetDataBuff.pTextureEnable
			theLightSet.pTexture = LPM_LightSetDataBuff.pTexture
			theLightSet.expanded = LPM_LightSetDataBuff.expanded
		)

		LPM_treeview_rollout.updateTV()
	)

	on btn_quickScripts pressed do
	(
		LPM_Fun.quickScripts()
	)

	on btn_setRenderDir pressed do
	(
		result = LPM_fun.pickOutputRoot()
		if result != undefined
		then (dnc_textBoxOutputPath.text = result)
		else()
	)

	on btn_openRenderDir pressed do ( shellLaunch LPM_Root.rootDir "" )

	on ddl_selectProcessor selected state do
	(
		LPM_Root.processorActive = state
	)

	on btn_execute pressed do
	(
		curMode = ddl_selectProcessor.selected

		if curMode == "Render - Local"
		then
		(
			LPM_Fun.setWhoToRenderByRenderType()
			LPM_Fun.localRenderSubmit()
		)

		if curMode == "Render - Submit to Deadline 10"
		then
		(
			LPM_IdiotChecksEnabled = True
			LPM_Fun.setWhoToRenderByRenderType()
			filein (LPM_Dir+@"plugins\Deadline10.0.ms")
		)

		if curMode == "Render - Submit to Deadline 10 - Skip Checks"
		then
		(
			LPM_IdiotChecksEnabled = False
			LPM_Fun.setWhoToRenderByRenderType()
			filein (LPM_Dir+@"plugins\Deadline10.0.ms")
		)

		if curMode == "Export - Bake 3dsMax Files"
		then
		(
			LPM_Fun.setWhoToRenderByRenderType()
			filein (LPM_Dir+@"plugins\maxFileSubmit.ms")
		)

		if curMode == "Preview - TyPreview"
		then
		(
			if not LPM_TyFlowInstalled then
			(
				messagebox "tyFlow / tyPreview is not installed on this machine." title:"LPM"
			)
			else
			(
				LPM_Fun.setWhoToRenderByRenderType()
				LPM_Fun.tyPreviewSubmit()
			)
		)

	)

	on ddl_previewType selected item do
	(
		setRenderType (ddl_previewType.selected as name)
		type=ddl_previewType.selected
		if( type== "Region")or(type=="Crop") or(type=="BlowUp") then ( try(EditRenderRegion.EditRegion())catch() )
	)

	on ddl_previewSize selected item do
	(
		LPM_Root.previewSize=ddl_previewSize.selected as integer
	)

	on tv drawNode arg do
	(
		img = dotNetClass "System.Drawing.Image"--create an image
		img2=img.fromFile (LPM_iconPath + "Root.Bmp")

		theColor=(dotNetClass "System.Drawing.Brushes").Blue
		theFont=dotnetobject "system.drawing.font" (dotnetobject "system.drawing.fontfamily" "tahoma") 8.5  (dotNetClass "system.drawing.fontStyle").bold
		arg.Graphics.DrawString Arg.Node.text theFont theColor Arg.bounds.Left Arg.bounds.top
		arg.Graphics.drawImage img2 Arg.bounds.Left Arg.bounds.top
	)

	on tv textChanged arg do()

	on tv BeforeLabelEdit e do
	(
		if e.Node.level == 0 then
			e.CancelEdit = true
	)

	on tv AfterLabelEdit e do
	(
		if e.CancelEdit then return()
		if e.Label == undefined then return()

		theNode = e.Node
		type = theNode.tag.value.type
		word = e.Label
		if(type=="shot" or type=="pass") then word = LPM_Fun.removeBadChars word

		-- reject blank names; updateTV restores the original label
		if((trimLeft (trimRight word)) == "") then
		(
			LPM_treeview_rollout.updateTV()
			return()
		)

		theNode.text = word
		case type of
		(
			"wildcard": ( theNode.Parent.tag.value.wildCard[theNode.tag.value.index]=word )
			"shot":
			(
				pos=findstring word "[["
				if(pos!=undefined) then
					theNode.tag.value.name="LPM_"+(substring word 1 pos)
				else
					theNode.tag.value.name="LPM_"+word
				theNode.text=LPM_Fun.getShotName theNode.tag.value
			)
			"pass":
			(
				theNode.tag.value.name="LPM_"+word
				theNode.text = LPM_Fun.generatePassName theNode.tag.value
			)
			default: ( try(theNode.tag.value.name="LPM_"+word)catch() )
		)
		LPM_treeview_rollout.updateTV()
	)

	-- PreviewKeyDown handles Enter/Escape for label edit commit/cancel.
	-- In 3dsMax 2026's .NET Core 8, these keys are consumed as dialog keys
	-- before reaching the native edit control, so we must call EndEdit explicitly.
	on tv PreviewKeyDown e do
	(
		local key = e.keycode.tostring()
		if key == "Return" then
		(
			e.IsInputKey = true
			if tv.selectedNode != undefined and tv.selectedNode.IsEditing then
				tv.selectedNode.EndEdit false
		)
		else if key == "Escape" then
		(
			e.IsInputKey = true
			if tv.selectedNode != undefined and tv.selectedNode.IsEditing then
				tv.selectedNode.EndEdit true
		)
	)

	on tv keyDown e do
	(
		if (keyboard.controlpressed)and ((e.keycode.tostring())=="Z") then
		(
			max undo
			LPM_treeview_rollout.updateTV()
		)
	)

	on tv keyUp e do
	(
		theNode=tv.selectedNode

		TheNodeType = undefined
		try(TheNodeType = LPM_activeElement.tag.value.type)catch()

		case e.keycode.tostring() of
		(
			"F5":
			(
				LPM_ProSequencerUpdate()
				LPM_treeview_rollout.updateTV()
			)
			"Delete":
			(
				undo "LPM delete" on
				(
					case TheNodeType of
					(
						"passGroup":
						(
							if(querybox "Are you sure you want to delete the group and all its passes?") then
							(
								grp=LPM_treeview_rollout.tv.selectedNode.tag.value
								chld=LPM_Fun.getAllChildren grp
								delete chld
							)
						)
						"pass":
						(
							deleteSelectedPass tv
							LPM_activePass = undefined
						)
						"objectSet":
						(
							theObjectSetNode=LPM_treeview_rollout.tv.selectedNode
							theObjectSet=theObjectSetNode.tag.value
							delete theObjectSet
							theObjectSetNode.remove()
						)
						"lightSet":
						(
							theObjectSetNode=LPM_treeview_rollout.tv.selectedNode
							theObjectSet=theObjectSetNode.tag.value
							delete theObjectSet
							theObjectSetNode.remove()
						)

						"vrayProps":
						(
							theNode=LPM_treeview_rollout.tv.selectedNode.tag.value
							delete theNode
							LPM_treeview_rollout.tv.selectedNode.remove()
						)

						"renderProps":
						(
							theNode=LPM_treeview_rollout.tv.selectedNode.tag.value
							delete theNode
							LPM_treeview_rollout.tv.selectedNode.remove()
						)
						"envProps":
						(
							theNode=LPM_treeview_rollout.tv.selectedNode.tag.value
							delete theNode
							LPM_treeview_rollout.tv.selectedNode.remove()
						)
						"commonProps":
						(
							theNode=LPM_treeview_rollout.tv.selectedNode.tag.value
							delete theNode
							LPM_treeview_rollout.tv.selectedNode.remove()
						)
						"script":
						(
							theNode=LPM_treeview_rollout.tv.selectedNode.tag.value
							delete theNode
							LPM_treeview_rollout.tv.selectedNode.remove()
						)
						"generic":
						(

						)
						"xrefObj":
						(
							theNode=LPM_treeview_rollout.tv.selectedNode.tag.value
							delete theNode
							LPM_treeview_rollout.tv.selectedNode.remove()
						)
						"xrefScene":
						(
							theNode=LPM_treeview_rollout.tv.selectedNode.tag.value
							delete theNode
							LPM_treeview_rollout.tv.selectedNode.remove()
						)
						"ModifierOver":
						(
							theNode=LPM_treeview_rollout.tv.selectedNode.tag.value
							delete theNode
							LPM_treeview_rollout.tv.selectedNode.remove()
						)

						"Deadline":
						(
							theNode=LPM_treeview_rollout.tv.selectedNode.tag.value
							delete theNode
							LPM_treeview_rollout.tv.selectedNode.remove()
						)
						"vrayRenderElements":
						(
							theNode=LPM_treeview_rollout.tv.selectedNode.tag.value
							delete theNode
							LPM_treeview_rollout.tv.selectedNode.remove()
						)
						"cameraOverscan":
						(
							theNode=LPM_treeview_rollout.tv.selectedNode.tag.value
							delete theNode
							LPM_treeview_rollout.tv.selectedNode.remove()
						)

						"tyPreview":
						(
							theNode=LPM_treeview_rollout.tv.selectedNode.tag.value
							delete theNode
							LPM_treeview_rollout.tv.selectedNode.remove()
						)

						"renderImage":
						(
							theNode=LPM_treeview_rollout.tv.selectedNode.tag.value
							delete theNode
							LPM_treeview_rollout.tv.selectedNode.remove()
						)

						"nukeExport":
						(
							theNode=LPM_treeview_rollout.tv.selectedNode.tag.value
							delete theNode
							LPM_treeview_rollout.tv.selectedNode.remove()
						)

						"aeExport":
						(
							theNode=LPM_treeview_rollout.tv.selectedNode.tag.value
							delete theNode
							LPM_treeview_rollout.tv.selectedNode.remove()
						)

						"shot":
						(
							deleteSelectedPass tv
							LPM_activePass = undefined
						)
						"ShotPass":
						(
							theShot=LPM_treeview_rollout.tv.selectedNode.parent.tag.value
							index=LPM_treeview_rollout.tv.selectedNode.tag.value.index
							deleteItem theShot.passes index
							deleteItem theSHot.passesOn index
							LPM_treeview_rollout.tv.selectedNode.remove()
						)
						"object":
						(
							theObj=LPM_treeview_rollout.tv.selectedNode.tag.value
							theParent=LPM_treeview_rollout.tv.selectedNode.parent.tag.value
							LPM_Fun.pruneArray theParent.nodes theObj.leaf
							LPM_treeview_rollout.tv.selectedNode.remove()
						)
						"light":
						(
							theObj=LPM_treeview_rollout.tv.selectedNode.tag.value
							theParent=LPM_treeview_rollout.tv.selectedNode.parent.tag.value
							LPM_Fun.pruneArray theParent.nodes theObj.leaf
							LPM_treeview_rollout.tv.selectedNode.remove()
						)
						"layer":
						(
							theObj=LPM_treeview_rollout.tv.selectedNode.tag.value
							theParent=LPM_treeview_rollout.tv.selectedNode.parent.tag.value
							LPM_Fun.pruneArray theParent.layers theObj.leaf
							LPM_treeview_rollout.tv.selectedNode.remove()
						)
						"wildCard":
						(
							theObj=LPM_treeview_rollout.tv.selectedNode.tag.value
							theParent=LPM_treeview_rollout.tv.selectedNode.parent.tag.value
							theParent.wildcard=(for i=1 to theParent.wildCard.count where i!=theObj.index collect theParent.wildCard[i])
							LPM_treeview_rollout.tv.selectedNode.remove()
						)
						"namedSet":
						(
							theObj=LPM_treeview_rollout.tv.selectedNode.tag.value
							theParent=LPM_treeview_rollout.tv.selectedNode.parent.tag.value
							theParent.namedSet=(for i=1 to theParent.namedSet.count where i!=theObj.index collect theParent.namedSet[i])
							LPM_treeview_rollout.tv.selectedNode.remove()
						)
						"mat":
						(
							theObj=LPM_treeview_rollout.tv.selectedNode.tag.value
							theParent=LPM_treeview_rollout.tv.selectedNode.parent.tag.value
							LPM_Fun.pruneArray theParent.mats theObj.leaf
							LPM_treeview_rollout.tv.selectedNode.remove()
						)
					)
					LPM_treeview_rollout.updateTV()
					LPM_activeElement = LPM_treeview_rollout.tv.selectedNode
				)
			)
		)
		updateNodeNameField()
	)

	on tv BeforeExpand Arg do
	(
		if preventExpand then
		(
			arg.Cancel = true
			preventExpand = false
		)
		else( arg.node.tag.value.expanded=true )
	)

	on tv BeforeCollapse Arg do
	(
		if preventExpand then
		(
			arg.Cancel = true
			preventExpand = false
		)
		else ( arg.node.tag.value.expanded=false )
	)

	on tv MouseDown arg do
	(
		tmpDelta 		= (timestamp()) - lastMouseDown
		lastMouseDown 	= timestamp()

		if (tmpDelta<500)and(TmpSelNode == tv.GetNodeAt arg.location) then
		(
			hitNode = tv.GetNodeAt arg.location
			if hitNode != undefined then
			(
				local level = hitNode.level
				if ((15+level*20) < (arg.x)) then ( preventExpand = true )
			)
			else ( preventExpand = false )
		)
		else ( preventExpand = false )

		TmpSelNode = tv.GetNodeAt arg.location
	)

	on tv MouseUp arg do
	(
		nTime=timestamp()
		delta=nTime - sTime
		sTime=0 --Assume its an invalid click, if its valid we will the timestamp later
		local button = arg.button.ToString()

		hitNode = tv.GetNodeAt arg.location
		LPM_activeElement = hitNode
		newActive=LPM_Fun.passByNode hitNode
		if(isvalidnode newActive) then
		(
			LPM_activePass=newActive
		)

		if hitNode==undefined then
		(
			if(button=="Middle") then
			(
				max unhide all
			)
		)

		if hitNode != undefined then
		(
			if(button=="Left" or button=="Middle") then
			(
				local level = hitNode.level
				if(arg.x>(38+level*20) and (button=="Left") and (preventExpand==false)) then
				(
					sTime=nTime
				)

				if((15+level*20) < (arg.x)) and ((arg.x) < (37+level*20)) then

				case hitNode.tag.value.type of
				(
					"pass":
					(
						hitNode.tag.value.active= not hitNode.tag.value.active
						LPM_Fun.setIcon hitNode
					)
					"objectSet":
					(
						hitNode.tag.value.intp[1]= (mod (hitNode.tag.value.intp[1])  3) + 1
						LPM_Fun.setIcon hitNode
					)
					"lightSet":
					(
						hitNode.tag.value.pEnable= (mod (hitNode.tag.value.pEnable)  3) + 1
						LPM_Fun.setIcon hitNode
					)
					"shot":
					(
						hitNode.tag.value.active= not hitNode.tag.value.active
						LPM_Fun.setIcon hitNode
					)

					"vrayProps":
					(
						hitNode.tag.value.active= not hitNode.tag.value.active
						LPM_Fun.setIcon hitNode
					)

					"renderProps":
					(
						hitNode.tag.value.active= not hitNode.tag.value.active
						LPM_Fun.setIcon hitNode
					)
					"envProps":
					(
						hitNode.tag.value.active= not hitNode.tag.value.active
						LPM_Fun.setIcon hitNode
					)
					"commonProps":
					(
						hitNode.tag.value.active= not hitNode.tag.value.active
						LPM_Fun.setIcon hitNode
					)


					"cameraOverscan":
					(
						hitNode.tag.value.active= not hitNode.tag.value.active
						LPM_Fun.setIcon hitNode
					)

					"tyPreview":
					(
						hitNode.tag.value.active= not hitNode.tag.value.active
						LPM_Fun.setIcon hitNode
					)

					"renderImage":
					(
						hitNode.tag.value.active= not hitNode.tag.value.active
						LPM_Fun.setIcon hitNode
					)

					"nukeExport":
					(
						hitNode.tag.value.active= not hitNode.tag.value.active
						LPM_Fun.setIcon hitNode
					)


					"aeExport":
					(
						hitNode.tag.value.active= not hitNode.tag.value.active
						LPM_Fun.setIcon hitNode
					)
					"script":
					(
						hitNode.tag.value.active= not hitNode.tag.value.active
						LPM_Fun.setIcon hitNode
					)
					"generic":
					(
						hitNode.tag.value.Active= not hitNode.tag.value.Active
						LPM_Fun.setIcon hitNode
					)
					"passGroup":
					(
						hitNode.tag.value.active= not hitNode.tag.value.active
						LPM_Fun.setIcon hitNode
					)
					"ShotPass":
					(
						hitNode.parent.tag.value.passesOn[hitNode.tag.value.index]=hitNode.tag.value.active= not hitNode.tag.value.active
						LPM_Fun.setIcon hitNode
					)

					"xrefLeaf":
					(
						theFile= hitNode.tag.value.leaf[1]
						it=not hitNode.tag.value.leaf[2]
						hitNode.tag.value.leaf[2]= it
						LPM_Fun.setIcon hitNode
						xrefSceneProps=hitNode.parent.tag.value
						if(it==false) then
							LPM_Fun.pruneArray xrefSceneProps.fileNames theFile
						else
							append xrefSceneProps.fileNames theFile
					)
					"ModifierOver":
					(
						hitNode.tag.value.active= not hitNode.tag.value.active
						LPM_Fun.setIcon hitNode
					)

					"Deadline":
					(
						hitNode.tag.value.active= not hitNode.tag.value.active
						LPM_Fun.setIcon hitNode
				)


					"vrayRenderElements":
					(
						hitNode.tag.value.active= not hitNode.tag.value.active
						LPM_Fun.setIcon hitNode
					)

					"xrefScene":
					(
						hitNode.tag.value.active= not hitNode.tag.value.active
						LPM_Fun.setIcon hitNode
					)
					"xrefObj":
					(
						hitNode.tag.value.active= not hitNode.tag.value.active
						LPM_Fun.setIcon hitNode
					)
				)

				if(button=="Middle") then
				(
					undo "LPM middle click" on
					(
						theMode=getCommandPanelTaskMode()

						if(theMode==#display) then
							setCommandPanelTaskMode #create

						case hitNode.tag.value.type of
						(
							"pass":
							(
								hideByActivePass()
								for child in hitNode.tag.value.children where child.type=="generic" do
								(
									op=LPM_Operators.fngetByNode child
									if(op!=0) then
										op.fnPerformAction #middleClick
								)
							)
							"shot":
							(
								if(isvalidnode hitNode.tag.value.displayPass) then
								(
									LPM_ActivePass=hitNode.tag.value.displayPass
									hideByActivePass()
								)
								cp=LPM_Fun.firstChildByType (hitNode.tag.value) "commonProps"
								if(cp!=undefined) then
								(
									if(cp.cameraTgl==true) then
									(
										try(
												hide cameras

												theViewport=viewport.activeViewport
												case LPM_Fun.getIni "Settings" "shotViewport" string "Active Viewport" of
												(
													"Viewport 1": theViewport=1
													"Viewport 2":if(viewport.numviews >= 2) then theViewport=2
													"Viewport 3":if(viewport.numviews >= 3) then theViewport=3
													"Viewport 4":if(viewport.numviews >= 4) then theViewport=4
												)

												viewport.activeViewport=theViewport
												viewport.setCamera cp._Camera
												select cp._Camera
												unhide cp._Camera

												case cp._rendTimeType of
												(
													3:
													(
														sliderTime = cp._rendStart
													)
													4:
													(
														tmparr = filterString cp._rendPickupFrames ", -"

														if tmparr.count != 0 then
														(
															sliderTime = tmparr[1] as time
														)
													)
													default:()
												)

												if(isvalidnode cp._Camera.target) then
													unhide cp._Camera.target

											)catch()
									)

									format "before node:% start:% end:%\n" cp.name cp._rendStart cp._rendEnd
									if(cp.timeOutputTgl) then
									(
										case cp._rendTimeType of
										(
											3:(
												if(cp._rendStart < cp._rendEnd ) then
												(
													animationRange = interval cp._rendStart cp._rendEnd
												)
											)
										)
									)

									format "after node:% start:% end:%\n" cp.name cp._rendStart cp._rendEnd
								)
							)

							"layer":
							(
								theLayerName=hitNode.tag.value.leaf
								ctrl= not (keyboard.controlpressed)
								if(ctrl) then
									hide objects

								theLayer=layermanager.getlayerfromname theLayerName
								if(theLayer!=undefined) then
								(
									theArray=#()
									theLayer.nodes &theArray
									theLayer.ishidden=false
									unhide theArray
								)

							)
							"objectSet":
							(
								hideBySet hitNode.tag.value
							)
							"lightSet":
							(
								hideBySet hitNode.tag.value
							)
							"object":
							(
								ctrl= not (keyboard.controlpressed)
								(
									if(ctrl) then
										hide objects
									theNode=hitNode.tag.value.leaf

									if(isGroupHead theNode) then
										(for it in (LPM_Fun.getAllChildren theNode) where isgroupmember it do unhide it)
									unhide hitNode.tag.value.leaf
								)
							)
							"light":
							(
								ctrl= not (keyboard.controlpressed)
								(
									if(ctrl) then
										hide lights
									theNode=hitNode.tag.value.leaf

									if(isGroupHead theNode) then
										(for it in (LPM_Fun.getAllChildren theNode) where isgroupmember it do unhide it)
									unhide hitNode.tag.value.leaf
								)
							)
							"wildCard":
							(

								ctrl= not (keyboard.controlpressed)
								if(ctrl) then
									hide objects
								try(
									unhide (execute ("$"+hitNode.tag.value.leaf))
								)
								catch (messageBox ("wildCard Error"+getcurrentException()))

							)
							"namedSet":
							(
								ctrl= not (keyboard.controlpressed)
								if(ctrl) then
									hide objects

								(for item in selectionSets[hitnode.tag.value.leaf] do unhide item)

							)
							"mat":
							(
								ctrl= not (keyboard.controlpressed)
								if(ctrl) then
									hide objects
								local foundMat
								for mat in scenematerials do if(mat.name==hitNode.tag.value.leaf) then foundMat=mat
								if(foundMat!=undefined) then
									for it in objects where it.material==foundMat do unhide it
							)
							"generic":
							(
								op=LPM_Operators.fngetByNode hitNode.tag.value
								if(op!=0) then
									op.fnPerformAction #middleClick
							)
						)
						if(theMode==#display) then
							setCommandPanelTaskMode theMode
					)
				)
			)

			if(button=="Right") then
			(
				preventExpand = false

				case hitNode.tag.value.type of
				(
					"root":popUpMenu rc_RootMenu
					"pass":popUpMenu rc_PassMenu
					"renderProps":popUpMenu  rc_RenderPropsMenu
					"vrayProps":popUpMenu  rc_vrayPropsMenu
					"objectSet":popUpMenu rc_objectSetMenu
					"lightSet":popUpMenu rc_objectSetMenu
					"object":popUpMenu rc_objectMenu
					"light":popUpMenu rc_objectMenu
					"layer":popUpMenu rc_layerMenu
					"envProps":popUpMenu rc_atmPropsMenu
					"commonProps":popUpMenu rc_CommonPropsMenu
					"wildCard":popUpMenu rc_wildCardMenu
					"namedSet":popUpMenu rc_namedSetMenu
					"shotRoot":popUpMenu rc_shotRootMenu
					"shot":popUpMenu rc_shotMenu
					"xrefObj":popUpMenu rc_xrefObj
					"xrefScene":popUpMenu rc_xrefScene
					"ShotPass":popUpMenu rc_shotPassMenu
					"script":popUpMenu rc_scriptMenu
					"passGroup":popUpMenu rc_PassGroup
					"mat":popUpMenu rc_matMenu
					"generic":
					(
						op=LPM_Operators.fngetByNode hitNode.tag.value
						if(op!=0) then
							op.fnPerformAction #rightClick
					)
					"ModifierOver":popUpMenu rc_ModifierOverMenu
					"Deadline":popUpMenu rc_deadlinePropsMenu
					"vrayRenderElements":popUpMenu rc_vrayRenderElementsPropsMenu
					"cameraOverscan":popUpMenu rc_cameraOverscanPropsMenu
					"tyPreview":popUpMenu rc_tyPreviewPropsMenu
					"renderImage":popUpMenu rc_renderImagePropsMenu
					"nukeExport":popUpMenu rc_nukeExportPropsMenu
					"aeExport":popUpMenu rc_aeExportPropsMenu
				)
			)
			tv.selectedNode=hitNode
		)
		else if (button=="Right")  then
			popUpMenu rc_RootMenu

		oldHitNode = hitNode
		updateNodeNameField()
	)

	on tv NodeMouseDoubleClick arg do
	(
		LPM_doubleClick = true
	)

	on tv MouseDoubleClick arg do
	(
		LPM_doubleClick = true
		hitNode = tv.GetNodeAt arg.Location
		if (hitNode != undefined) then
		(
			if((37 + hitNode.level*20) < arg.x) then
			(
				case hitNode.tag.value.type of
				(
					"root":popUpMenu rc_RootMenu
					"pass":
					(
						LPM_doubleClick = true

						filein (LPM_Dir + "passSettingsRO.ms")
					)
					"renderProps":--popUpMenu  rc_RenderPropsMenu
					(
						filein (LPM_Dir + "renderPropsEdit.ms")
					)

					"vrayProps":popUpMenu  rc_vrayPropsMenu
					"objectSet": (createDialog LPM_objectSetProps 194 403 pos:(LPM_Fun.getRoPos 194))
					"lightSet": (createDialog LPM_lightSetProps pos:(LPM_Fun.getRoPos 194))
					"object":popUpMenu rc_objectMenu
					"light":popUpMenu rc_objectMenu
					"layer":popUpMenu rc_layerMenu
					"envProps": createdialog LPM_atmRollout pos:(LPM_Fun.getRoPos  LPM_atmRollout.width)
					"commonProps": createDialog LPM_commonRollout pos:(LPM_Fun.getRoPos  LPM_commonRollout.width)
					"wildCard":(createDialog wildCardRO pos:(LPM_Fun.getRoPos  wildCardRO.width))
					"namedSet":popUpMenu rc_namedSetMenu
					"shotRoot":popUpMenu rc_shotRootMenu
					"shot":(filein (LPM_Dir + "IncludePassesRO.ms"))
					"xrefObj":(AddXrefObjOverride())
					"xrefScene":(AddXrefSceneOverride())
					"ShotPass":popUpMenu rc_shotPassMenu
					"script":(LPM_treeview_rollout.AddScriptOverride())
					"passGroup":popUpMenu rc_PassGroup
					"mat":popUpMenu rc_matMenu
					"generic":
					(
						op=LPM_Operators.fngetByNode hitNode.tag.value
						if(op!=0) then
							op.fnPerformAction #edit
					)
					"ModifierOver":(AddModifierOverride())
					"Deadline":(EditDeadline())
					"vrayRenderElements":(EditVrayRenderElements())
					"cameraOverscan":(EditCameraOverscan())
					"tyPreview":(EditTyPreview())
					"renderImage":(EditRenderImage())
					"nukeExport":(EditNukeExport())
					"aeExport":(EditAeExport())
				)
			)
		)

		LPM_doubleClick = true
	)

	-- DRAG AND DROP
	 on tv ItemDrag arg do
	 (
		 dragnode=arg.item


		it=arg.item.tag.value.type
		if(it=="pass") or (it=="shot") or (it=="objectSet") or (it=="lightSet") or (it=="renderProps") or (it=="vrayProps")or (it=="envProps") or (it=="commonProps") or (it=="xrefObj") or (it=="xrefScene") or (it=="passGroup") or (it=="ModifierOver") or (it=="script") or (it=="Deadline") or (it=="vrayRenderElements") or (it=="cameraOverscan") or (it=="tyPreview") or (it=="nukeExport") or (it=="aeExport") or (it=="renderImage") then
		tv.doDragDrop arg.item m.Move -- this actually starts the drag and drop process
	 )

	 -- INSIDE Drag and Drop
	 on tv DragOver arg do
	 (
		 pos=tv.PointToClient tv.MousePosition -- this gave me a hard time to find out !
		 TestNode= tv.GetNodeAt pos

		 okToDrop=false

		if (testNode != undefined) and (dragNode!=undefined) then -- OK to Drop
		(
			testType=testNode.tag.value.type
			dragType=dragNode.tag.value.type
			if(testType==dragType) and \
			((testType=="objectSet") or (testType=="lightSet") or (testType=="pass") or (testType=="shot") or (testType=="renderProps")or (testType=="passGroup"))	then
				okToDrop=true
			else if(testType=="pass") and (dragType!="shot") and (dragType!="passGroup") then
				okToDrop=true
			else if((testType=="passGroup") or (testType=="root"))and (dragType=="pass") then
				okToDrop=true
			else if(testType=="shot") and (dragType =="commonProps") then
				okToDrop=true
			else if(testType=="shot") and (dragType =="pass") then
				okToDrop=true
		)

		 if(okToDrop) then
			 arg.Effect=arg.AllowedEffect
		 else
			 arg.Effect=m.none
	 )
	 -- END Drag and Drop (drop the item)

	 on tv DragDrop arg do
	(
		 pos=tv.PointToClient tv.MousePosition
		 DropNode=tv.GetNodeAt pos
		 if(dragNode!= dropNode) then
		 (
			if(dragNode.tag.value.type==dropNode.tag.value.type) then--drag pass to pass or set to set\ --drag pass to pass or set to set or shot to a shot
			(
				if dragNode.tag.value.type != "pass" then
				(
					dragTvParent=dragNode.Parent
					dropTvParent=dropNode.Parent
					if(dragNode.index>dropNode.index) then
					(
						dragNode.remove() -- need to remove the node from the tree
						dropNode.parent.Nodes.insert dropNode.index dragNode  -- add it to the dropNode children
					)
					 else
					(
						dragNode.remove() -- need to remove the node from the tree
						dropNode.parent.Nodes.insert (dropNode.index+1) dragNode  -- add it to the dropNode children
					)
					 dragNode.text=dragNode.text -- reassignment forces redraw, fixes text cutoff

					 --LPM Data
					tvReparent dragTvParent dragNode.tag.value.type
					if(dragTvParent!=dropTvParent) then
					(
						 tvReparent dropTvParent dragNode.tag.value.type
					)
				)
				else
				(
					if (keyboard.shiftpressed) then
					(
						thePass=dropNode.tag.value
						LPM_treeview_rollout.updateTV()
					)
					else
					(
						dragTvParent=dragNode.Parent
						dropTvParent=dropNode.Parent
						if(dragNode.index>dropNode.index) then
						(
							dragNode.remove() -- need to remove the node from the tree
							dropNode.parent.Nodes.insert dropNode.index dragNode  -- add it to the dropNode children
						)
						 else
						(
							dragNode.remove() -- need to remove the node from the tree
							dropNode.parent.Nodes.insert (dropNode.index+1) dragNode  -- add it to the dropNode children
						)
						 dragNode.text=dragNode.text -- reassignment forces redraw, fixes text cutoff

						 --LPM Data
						tvReparent dragTvParent dragNode.tag.value.type
						if(dragTvParent!=dropTvParent) then
						(
							 tvReparent dropTvParent dragNode.tag.value.type
						)
					)
				)
			)

			else if(dropNode.tag.value.type=="shot") and (dragNode.tag.value.type=="pass") then --dragging pass into a shot
			(
				theShot=dropNode.tag.value
				thePass=dragNode.tag.value
				theShot.allPasses=false
				if(findItem theShot.passes thePass ==0) then
				(
					append theShot.passes thePass
				)
				addShotTv dropNode
			)

			else if(dropNode.tag.value.type=="passGroup" or dropNode.tag.value.type=="root") then--drop a pass onto passGroup
			(
				dragNode.remove() -- need to remove the node from the tree
				dragNode.tag.value.parent=dropNode.tag.value
				dropNode.Nodes.insert (dropNode.index+1) dragNode  -- add it to the dropNode children
			)

			else if(dropNode.tag.value.type=="pass") or (dropNode.tag.value.type=="shot") then--drop onto a pass or shot
			(
				if(dragNode.tag.value.parent != dropNode.tag.value) then -- dont need to do anything if its just dropping onto itself
				(
					thePass=dropNode.tag.value
					theNode=dragNode.tag.value
					theType=dragNode.tag.value.type

					if (theType=="envProps") or (theType=="commonProps") or (theType=="xrefObj") or (theType=="xrefScene") or (theType=="Deadline") or (theType=="vrayRenderElements") or (theType=="cameraOverscan") or (theType=="tyPreview") or (theType=="nukeExport") or (theType=="aeExport") or (it=="renderImage") then
					(
						for it in thePass.children where it.type==theType do --delete the previous nodes of the above types
							delete it
					)
					if(keyboard.controlpressed) then --copying
					(
						newNode=copy theNode
						newNode.name = theNode.name
						LPM_Fun.addToLPMLayer newNode
						newNode.parent=thePass
					)
					else if (keyboard.shiftpressed) then--instancing
					(
						newNode=instance theNode
						newNode.name=theNode.name
						LPM_Fun.addToLPMLayer newNode
						newNode.parent=thePass
					)
					else --moving
					(
						theNode.parent=thePass
					)
					updateTv()
				)
			)
		)
	)

	on dnc_nodeName TextChanged e do
	(
		if nameFieldUpdating then return()
		local selNode = tv.selectedNode
		if selNode == undefined or selNode.level <= 0 then return()

		local word = dnc_nodeName.text
		local nodeType = selNode.tag.value.type

		if (nodeType == "shot" or nodeType == "pass") then
			word = LPM_Fun.removeBadChars word

		-- skip blank input so live typing can't commit an empty name
		if ((trimLeft (trimRight word)) == "") then return()

		case nodeType of
		(
			"wildcard":
			(
				selNode.Parent.tag.value.wildCard[selNode.tag.value.index] = word
				selNode.text = word
			)
			"shot":
			(
				local pos = findstring word "[["
				if pos != undefined then
					selNode.tag.value.name = "LPM_" + (substring word 1 pos)
				else
					selNode.tag.value.name = "LPM_" + word
				selNode.text = LPM_Fun.getShotName selNode.tag.value
			)
			"pass":
			(
				selNode.tag.value.name = "LPM_" + word
				selNode.text = LPM_Fun.generatePassName selNode.tag.value
			)
			-- groups, object/light sets, etc: refresh the visible label too,
			-- otherwise the rename lands on the object but the tree looks unchanged
			default: ( try( selNode.tag.value.name = "LPM_" + word ; selNode.text = word )catch() )
		)
	)

	on btn_versionUp pressed do
	(
		if tv.selectedNode != undefined and tv.selectedNode.level > 0 then
		(
			offsetSelectedShot tv #increment
			updateNodeNameField()
		)
	)

	on btn_versionDown pressed do
	(
		if tv.selectedNode != undefined and tv.selectedNode.level > 0 then
		(
			offsetSelectedShot tv #decrement
			updateNodeNameField()
		)
	)

	on ddl_camera selected it do
	(
		if(selected==1) then
			LPM_Root.renderCamera=undefined
		else
			LPM_Root.renderCamera=getNodeByName ddl_camera.items[it]
		updateddl_camera()
	)

	on LPM_treeview_rollout resized theSize do
	(
		if theSize[1] < 345 then ( LPM_treeview_rollout.width = 345 )
		if theSize[2] < 240 then ( LPM_treeview_rollout.height = 240 )
		LPM_Resize [LPM_treeview_rollout.width,LPM_treeview_rollout.height]
	)

	on LPM_treeview_rollout open do
	(
		dnc_textBoxOutputPath.text = LPM_Root.rootDir

		lpm_fun.preFileOpenCallback_Add()
		
		initTreeView tv
		fillInTreeView tv
		updateNodeNameField()

		for i=1 to ddl_previewSize.items.count do
			if((LPM_root.previewSize as string)==ddl_previewSize.items[i]) do
				ddl_previewSize.selection=i
		updateddl_camera()
		renderType=getRenderType()
		for i=1 to ddl_previewType.items.count do
		(
			if (renderType==(ddl_previewType.items[i] as name)) then(ddl_previewType.selection=i)
		)

		-- Select the last active processor was stored, set it to active in the UI
		-- selection is 1-based, so the valid range is 1..Items.Count (inclusive),
		-- otherwise the last processor (e.g. "Preview - TyPreview") never restores.
		if LPM_Root.processorActive >= 1 and LPM_Root.processorActive <= ddl_selectProcessor.Items.Count do
		(
    		ddl_selectProcessor.selection = LPM_Root.processorActive
		)


		LPM_Resize (getDialogSize LPM_Treeview_Rollout)
	)

	on LPM_treeview_rollout close do
	(
		lpm_fun.preFileOpenCallback_Remove()

		if(colorBackup!=undefined) then
		(
			for item in colorBackup do try(item[1].wirecolor=item[2])catch()
			displayColor.wireframe=displayColorWire
			displayColor.shaded=displayColorShaded
		)

		--Store the position/size
		LPM_Fun.setIni "LPM Window" "X_Position" ((GetDialogPos LPM_treeview_rollout)[1] as string)
		LPM_Fun.setIni  "LPM Window" "Y_Position" ((GetDialogPos LPM_treeview_rollout)[2] as string)
		LPM_Fun.setIni "LPM Window" "X_Size" (LPM_treeview_rollout.width as string)
		LPM_Fun.setIni "LPM Window" "Y_Size" (LPM_treeview_rollout.height as string)
		LPM_Fun.destroyAllDialogs()
	)
)

freshOpen = undefined

if(not (isvalidNode LPM_Root)) then
(
	( freshOpen = true )

	LPM_Root=LPM_Fun.createNode "Root" "root"
	if(maxfilePath!="") then ( LPM_Root.rootdir = LPM_Fun.autoSetRenderOutput() )
	else()
)

else ( freshOpen = false )

if(	(LPM_Fun.FirstChildByType LPM_Root "shotRoot")==undefined) then
(
	shotRoot=LPM_Fun.createNode "shotRoot" "shotRoot"
	shotRoot.parent=LPM_Root
)

--check/set the name format of all the nodes
if( not LPM_Root.namesUpdated) then
(
	theNodes=LPM_Fun.getAllChildren LPM_Root
	for it in theNodes do
	(
		if((substring it.name 1 4)!="LPM_") then
			it.name="LPM_"+it.name
	)
	LPM_Root.namesUpdated=true
)
--update user props from version 0099
if(LPM_Root.id <= 0099) then
(
	theNodes=LPM_Fun.getAllChildren LPM_Root
	for it in theNodes where it.type=="objectSet" do
	(
		if(it.userProp=="") then it.userProp=getUserPropBuffer it
	)
)

xPos=LPM_Fun.getIni "LPM Window" "X_Position" integer 0
yPos=LPM_Fun.getIni "LPM Window" "Y_Position" integer 0
sizeX=LPM_Fun.getIni "LPM Window" "X_Size"  integer 200
sizeY=LPM_Fun.getIni "LPM Window" "Y_Size"  integer 430

if(sizeX==0) then sizeX=200
if(sizeY==0) then sizeY=430


-- Only run if this is the first time LPM was launched in this scene
if freshOpen then
(
	-- Create Defualt Render elements
	filein (LPM_Dir+@"makeRenderElements.ms")

	-- Set studio defaults
	LPM_Root.deadlinePathOverridden = false 																								-- Sets Deadline pathing to Automatic
--	try( LPM_Root.deadlinePath 		= (dotNetClass "System.Environment").GetEnvironmentVariable "DEADLINE_REPOSITORY_PATH")catch() 	 		-- Gets the automatic Deadline Path
	LPM_Root.deadlinePath 			= LPM_FunDeadline.deadline_GetRepoPath()	 															-- Gets the automatic Deadline Path
	LPM_Root.pathString 			= "$Shot\\$Pass\\$Pass" 																				-- Set Fileoutput Path Token String to default
	LPM_Root.renderType 			= 3 																									-- Force to shots
	LPM_Root.rootdir 				= (getDir #renderoutput )+"\\"  																		-- Sets the root dir
	LPM_Root.fileType 				= LPM_Fun.getIni "Settings" "Default Format" string "exr" 												-- Set default filetype
)

createDialog LPM_treeview_rollout pos:[xPos,yPos] height:SizeY width:sizeX menu:rc_MainMenu    style:#(#style_toolwindow, #style_sysmenu,#style_resizing) lockHeight:false lockWidth:false -- 	  style:#(#style_titlebar,#style_border, #style_sysmenu,#style_resizing,#style_minimizebox)

-- Only run if this is the first time LPM was launched in this scene
if freshOpen then
(
	-- Create Default Pass
	filein (LPM_Dir+@"QuickScripts\01Beauty Pass.ms")

	-- Create Default Shot
	theShot=LPM_Fun.createShot LPM_Root
	theShot.name = "LPM_Shot_v001"
	shotNode=LPM_treeview_rollout.createShotTv theShot
	LPM_treeview_rollout.addShotTv shotNode
)