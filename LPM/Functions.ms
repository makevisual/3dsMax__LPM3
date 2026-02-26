
Struct LPM_Fun_Struct
(
function preFileOpenCallback_Action =
(
	lpm_fun.destroyAllDialogs()
),

function preFileOpenCallback_Add =
(
	callbacks.addScript #filePreOpen "lpm_fun.preFileOpenCallback_Action()" id:#lpm_filePreOpen_Callback
),

function preFileOpenCallback_Remove =
(
	callbacks.removeScripts #filePreOpen id:#lpm_filePreOpen_Callback
),

fn destroyAllDialogs=
(

	if(LPM_LoadingPreset!=true) and (callbacks.notificationParam()!=2) then
	(
		--try destroying all dialogs

		try(destroyDialog LPM_renderRo)catch()
		try(destroyDialog LPM_netRenderRo) catch()
		try(destroyDialog LPM_progressRO)catch()
		try(destroyDialog wildCardRO) catch()
		try(destroyDialog LPM_atmRollout) catch()
		try(destroyDialog ModifierOverRollout)catch()
		try(destroyDialog LPM_commonRollout) catch()
		try(destroyDialog AboutRo) catch()
		try(destroyDialog savePresetRo) catch()
		try(destroyDialog pickPasses_RO) catch()
		try(destroyDialog LPM_objectSetProps)catch()
		try(destroyDialog lightSetProps) catch()
		try(destroyDialog deadlinePropsRoll)catch()				-- Dabelow
		try(destroyDialog SMTDLPMInterface)catch()				-- Dabelow
		try(destroyDialog vrayPropsRoll)catch()					-- Dabelow vrayRenderElements
		try(destroyDialog vrayRenderElementsPropsRoll)catch()	-- Dabelow vrayRenderElements
		try(destroyDialog cameraOverscanPropsRoll)catch()		-- Dabelow cameraOverscan
		try(destroyDialog renderImagePropsRoll)catch()			-- Dabelow renderImage
		try(destroyDialog nukeExportPropsRoll)catch()			-- Dabelow nukeExport
		try(destroyDialog aeExportPropsRoll)catch()				-- Dabelow aeExport
		try(destroyDialog LPM_treeview_rollout)catch()

		callbacks.removeScripts id:#closeLPM
	)
),
fn cleanSet theSet=
(
	theSet.nodes=for it in theSet.nodes where (isvalidnode it) collect it
),


-- TODO! -- This is that noisy section
fn firstChildByType theParent type=
(
	-- GPT suggested this
    if theParent == undefined do return undefined

	for kids in theParent.children where kids.type==type do
	(
		return kids
	)


	undefined
),

fn setImageIndex theNode nodeActive iconIndex disabledIndex =
(
	if(nodeActive) then
	(
		theNode.imageIndex=iconIndex
		theNode.selectedImageIndex=iconIndex
	)
	else
	(
		theNode.imageIndex=disabledIndex
		theNode.selectedImageIndex=disabledIndex
	)
),

fn setIcon theNode=
(
	try
	(
		case theNode.tag.value.type of
		(
			"pass":(LPM_Fun.setImageIndex theNode theNode.tag.value.active 1 11)
			"objectSet":(
				case (theNode.tag.value.intP[1]) of
				(
					1: LPM_Fun.setImageIndex theNode true 2 2
					2: LPM_Fun.setImageIndex theNode true 12 12
					3: LPM_Fun.setImageIndex theNode true 13 13
				)
			)
			"lightSet":(
				case theNode.tag.value.pEnable of
				(
					1: LPM_Fun.setImageIndex theNode true 3 3
					2: LPM_Fun.setImageIndex theNode true 14 14
					3: LPM_Fun.setImageIndex theNode true 15 15
				)
			)
			"wildCard": LPM_Fun.setImageIndex theNode true 6 6
			"namedSet": LPM_Fun.setImageIndex theNode true 5 5
			"layer": LPM_Fun.setImageIndex theNode true 4 4
			"object": LPM_Fun.setImageIndex theNode true 7 7
			"light": LPM_Fun.setImageIndex theNode true 7 7
			"commonProps": LPM_Fun.setImageIndex theNode theNode.tag.value.active 10 22
			"renderProps": LPM_Fun.setImageIndex theNode theNode.tag.value.active 8 24
			"vrayProps": LPM_Fun.setImageIndex theNode theNode.tag.value.active 44 45
			"envProps": LPM_Fun.setImageIndex theNode theNode.tag.value.active 9 23
			"root": LPM_Fun.setImageIndex theNode true 0 0
			"generic":LPM_Fun.setImageIndex theNode theNode.tag.value.active 0 0
			"shotRoot":LPM_Fun.setImageIndex theNode true 18 18
			"shot":LPM_Fun.setImageIndex theNode theNode.tag.value.active 16 17
			"ShotPass":LPM_Fun.setImageIndex theNode theNode.tag.value.active 1 11
			"xrefObj":LPM_Fun.setImageIndex theNode theNode.tag.value.active 37 38
			"xrefScene":LPM_Fun.setImageIndex theNode theNode.tag.value.active 19 39
			"xrefLeaf":(
				case theNode.tag.value.leaf[2] of
				(
					true: LPM_Fun.setImageIndex theNode true 20 20
					false: LPM_Fun.setImageIndex theNode true 21 21
				)
			)
			"script":LPM_Fun.setImageIndex theNode theNode.tag.value.active 29 30
			"passGroup":LPM_Fun.setImageIndex theNode theNode.tag.value.active 27 28
			"ModifierOver":LPM_Fun.setImageIndex theNode theNode.tag.value.active 32 33
			"Deadline":LPM_Fun.setImageIndex theNode theNode.tag.value.active 46 47 			-- Dabelow
			"cameraOverscan":LPM_Fun.setImageIndex theNode theNode.tag.value.active 52 53  		-- Dabelow cameraOverscan
			"nukeExport":LPM_Fun.setImageIndex theNode theNode.tag.value.active 54 55  			-- Dabelow nukeExport
			"aeExport":LPM_Fun.setImageIndex theNode theNode.tag.value.active 56 57  			-- Dabelow aeExport
			"vrayRenderElements":LPM_Fun.setImageIndex theNode theNode.tag.value.active 62 63 	-- Dabelow vrayRenderElements 
			"renderImage":LPM_Fun.setImageIndex theNode theNode.tag.value.active 64 65 			-- Dabelow renderImage 
		)

	)catch(messagebox "Error setting icon see listener (F11) for details\nThis is often due to a memory allocation in 3ds max")
),

--returns the pass by node
fn passByNode theNode =
(
	tmpValue = undefined

	if(theNode!=undefined) then
	(
		tmpValue = case theNode.tag.value.type of
		(
			"pass":theNode.tag.value
			"renderProps":theNode.tag.value.parent
			"vrayProps":theNode.tag.value.parent
			"objectSet":theNode.tag.value.parent
			"lightSet":theNode.tag.value.parent
			"envProps":theNode.tag.value.parent
			"commonProps":
			(
				tmpComVal = undefined
				if theNode.tag.value.parent.type != "shot" then
				(
					tmpComVal = theNode.tag.value.parent
				)
				tmpComVal
			)
			"object":theNode.parent.parent.tag.value
			"light":theNode.parent.parent.tag.value
			"layer":theNode.parent.parent.tag.value
			"wildCard":theNode.parent.parent.tag.value
			"namedSet":theNode.parent.parent.tag.value
			"xrefObj":theNode.parent.tag.value
			"xrefScene":theNode.parent.tag.value
			"xrefLeaf":theNode.parent.parent.tag.value
			"script":theNode.parent.tag.value
			"ModifierOver":theNode.parent.tag.value
			"Deadline":theNode.parent.tag.value 				-- Dabelow
			"renderImage":theNode.parent.tag.value 				-- Dabelow renderImage
			"cameraOverscan":theNode.parent.tag.value 			-- Dabelow cameraOverscan
			"nukeExport":theNode.parent.tag.value 				-- Dabelow nukeExport
			"aeExport":theNode.parent.tag.value 				-- Dabelow aeExport
			default:undefined
		)
	)
	tmpValue
),

--returns the root index of the pass
fn getIndexOfPass thePass =
(
	theRoot=thePass.parent
	j=undefined
	for i=1 to theRoot.children.count do
	(
		if theRoot.children[i]==thePass then
			j=i
	)
	j
),

fn getAllChildren node=
(
	out=#(node)
	for i=1 to node.children.count do
	(
		join out (LPM_Fun.getAllChildren node.children[i])
	)
	out
),

fn getObjectSetArrays thePass type &objNodes &objSetArray=
(
	i=0
	objNodes=#()
	objSetArray=#()

	for objSet in thePass.children where objSet.type==type do
	(
		i+=1
		tmpCollection=#()
		objSetArray[i]=objSet
	--named sets
		for it in objSet.namedSet do
		(
			join tmpCollection (for item in selectionSets[it] collect item)
		)
	--wildcard
		for j=1 to objSet.wildCard.count do
		(
		try(
			if(objSet.wildCard[j]!="") then
			join tmpCollection (execute ("$"+objSet.wildCard[j]))
		)
		catch (messageBox ("wildCard Error"+getcurrentException()))
		)

	-- Mats
		for matName in objSet.mats do
		(
			for sceneMat in scenematerials where (matName==sceneMat.name) do
				for it in objects where it.material==sceneMat do append tmpCollection it
		)

	--layers
		LMan=LayerManager
		for j=1 to objSet.layers.count do
		(
			theLayerNodes=#()
			theLayer=LMan.getLayerfromName objSet.layers[j]
			if(theLayer != undefined) then
				theLayer.nodes &theLayerNodes
			join tmpCollection theLayerNodes
		)
		--remove invalid nodes
		LPM_Fun.cleanSet objSet
		--object sets
		join tmpCollection objSet.nodes



		for theGroup in objSet.nodes where (isGroupHead theGroup) do
		(
			join tmpCollection (for it in (LPM_Fun.getAllChildren theGroup) where isgroupmember it collect it)

		)

		if(type=="objectSet") then
			objNodes[i]=for it in tmpCollection where ((((superClassof it) ==geometryClass) or ((superClassof it) ==shape) or ((classof it) ==Container) or ((superClassof it) == helper)) and (not (iskindof it particleGroup))) collect it
		else
			objNodes[i]=for it in tmpCollection where (((superClassof it) ==light) and(not(iskindof it target)))collect it
	)
),

fn pruneArray theArray theItem=
(
	index=1

	while index <= theArray.count do
	(
		if(theArray[index]==theItem) then
			deleteItem theArray index
		else
			index+=1
	)
	theArray
),

fn getShotName theShot=
(
	base=LPM_Fun.getName theShot.name
	if(isvalidnode theshot.displayPass) then
		base+="[["+(LPM_Fun.getName theshot.displayPass.name) +"]]"
	base
),

fn saveRenderPreset =
(
	LPM_LoadingPreset=true



	case (classof renderers.current) of
	(
		Default_Scanline_Renderer: renderpresets.Save 0 ((getdir #temp) +"\\temp.rps") #{32,33,34}
		mental_ray_renderer: renderpresets.Save 0 ((getdir #temp) +"\\temp.rps") #{32,33,34}
		Default: renderpresets.Save 0 ((getdir #temp) +"\\temp.rps") #{32}
	)

	aa=fopen ((getdir #temp) +"\\temp.rps") "r"
	theSize= getFileSize ((getdir #temp) +"\\temp.rps")
	theArray=#()
	for i=1 to theSize do
	(
		theArray[i]=(ReadByte aa #unsigned)
	)

	fclose aa
	LPM_LoadingPreset=false
	theArray

),

fn optimizedLoadRenderPreset file =
(
	--disabling mods before preset load in heavy scenes = speed boost
	--tyson note: disabling mods can cause issues when disablerefmsgs is called, so im disabling that

	disablerefmsgs()

	mods = #()
	for obj in objects do
	(
		for j in 1 to obj.modifiers.count do
		(
			theMod = obj.modifiers[j]
			append mods #(theMod, theMod.enabled, theMod.enabledInViews, theMod.enabledInRenders)
		)
	)
	for j in 1 to mods.count do
	(
		theMod = mods[j]
	)

	------------------
	renderpresets.LoadAll 0 file
	------------------

	for j in 1 to mods.count do
	(
		theMod = mods[j]
	)

	enablerefmsgs()

),

fn loadRenderPreset theArray =
(
	LPM_LoadingPreset=true
	bb=fopen ((getdir #temp)+"\\temp2.rps")  "wb"
	for i=1 to theArray.count do
	(
		WriteByte bb theArray[i] #unsigned

	)
	fflush bb
	fclose bb

	optimizedLoadRenderPreset ((getdir #temp)+"\\temp2.rps")

	LPM_LoadingPreset=false
),

fn saveRenderPresetNew =
(
	LPM_LoadingPreset=true



	case (classof renderers.current) of
	(
		Default_Scanline_Renderer: renderpresets.Save 0 ((getdir #temp) +"\\temp.rps") #{32,33,34}
		mental_ray_renderer: renderpresets.Save 0 ((getdir #temp) +"\\temp.rps") #{32,33,34}
		Default: renderpresets.Save 0 ((getdir #temp) +"\\temp.rps") #{32}
	)

	aa=fopen ((getdir #temp) +"\\temp.rps") "r"

	theSize= getFileSize ((getdir #temp) +"\\temp.rps")

	theArray=#()

	for i=1 to (theSize/8) do
	(
		append theArray (ReadLongLong aa #unsigned)
	)

	fclose aa

	theString = ""

	for i = 1 to theArray.count do
	(
		theString += (theArray[i] as string) +","
	)
	LPM_LoadingPreset=false

	theString
),


fn loadRenderPresetNew theArrayString =
(
	LPM_LoadingPreset=true

	theArray = filterString theArrayString ","
	for i=1 to theArray.count do
	(
		theArray[i] = theArray[i] as Integer64
	)

	bb=fopen ((getdir #temp)+"\\temp2.rps")  "wb"
	for i=1 to theArray.count do
	(
		WriteLongLong bb theArray[i] #unsigned

	)
	fflush bb
	fclose bb

	optimizedLoadRenderPreset ((getdir #temp)+"\\temp2.rps")


	LPM_LoadingPreset=false
),

fn addToLPMLayer theNode=
(
	theLayer=LayerManager.getLayerFromName "zz-LPM"
	if(theLayer==undefined) then
	(
		theLayer=LayerManager.newLayer()
		theLayer.setName "zz-LPM"
		theLayer.ishidden = true
		theLayer.isfrozen =true
	)
	theLayer.addNode theNode
),

fn createDefaultPass =
(
	pass=LPM_Fun.createPass LPM_Root

	objectSet=LPM_Fun.createObjectSet "All Objects"
	objectSet.wildCard[1]="*"
	objectSet.parent=pass
	objectSet.intp[1] = 3

	lightSet=LPM_Fun.createLightSet "All Lights"
	lightSet.wildCard[1]="*"
	lightSet.parent=pass
	lightset.pEnable = 3
	lightSet.parent=pass

	newPass=LPM_treeview_rollout.createPassTv pass LPM_treeview_rollout.tvRoot
	LPM_Treeview_Rollout.addPassTv newPass
	LPM_Treeview_Rollout.renameNode newPass
),

fn createNode pName type=
(
	theNode=dummy()
	theNode.pos=[0,0,-1000]
	LPM_Fun.addToLPMLayer theNode

	case type of
	(
		"root":custAttributes.add theNode rootCA
		"pass":custAttributes.add theNode passCA
		"renderProps":custAttributes.add theNode renderPropsCA
		"vrayProps":custAttributes.add theNode vrayPropsCA
		"envProps":custAttributes.add theNode envEffectCA
		"commonProps":custAttributes.add theNode commonPropsCA
		"objectSet":custAttributes.add theNode objectSetCA
		"lightSet":custAttributes.add theNode lightSetCA
		"shotRoot":custAttributes.add theNode LPM_shotRootCA
		"shot":custAttributes.add theNode LPM_shotCA
		"xrefObj":custAttributes.add theNode LPM_XrefObjCA
		"xrefScene":custAttributes.add theNode LPM_XrefSceneCA
		"script":custAttributes.add theNode LPM_ScriptCA
		"passGroup":custAttributes.add theNode LPM_passGroupCA
		"empty":custAttributes.add theNode LPM_emptyCA
		"ModifierOver":custAttributes.add theNode ModifierOverCA
		"Deadline":custAttributes.add theNode deadlinePropsCA 							-- Dabelow
		"vrayRenderElements":custAttributes.add theNode vrayRenderElementsPropsCA 		-- Dabelow vrayrenderelements
		"renderImage":custAttributes.add theNode renderImagePropsCA 					-- Dabelow renderImage
		"cameraOverscan":custAttributes.add theNode cameraOverscanPropsCA 				-- Dabelow cameraOverscan
		"nukeExport":custAttributes.add theNode nukeExportPropsCA 						-- Dabelow nukeExport
		"aeExport":custAttributes.add theNode aeExportPropsCA 							-- Dabelow aeExport
	)

	pName="LPM_"+pName

	theNode.type=type

	if(type=="pass") or (type=="shot") or (type=="passGroup") then
		(
		theNode.Name=uniqueName pName

		if (type=="shot") then
			(
				theNode.Name += "_v001"
			)
		)
	else
		theNode.name=pName

	theNode
),

fn createPass LPM_Root=
(
	pass=LPM_Fun.createNode "Pass" "pass"
	pass.active=true
	pass.parent=LPM_Root
	pass.rootdir=(getdir #renderoutput)+"\\"
	pass.hideMode=(LPM_Fun.getIni "Settings" "objectSetDefaultHideMode" integer 1)

	pass

),

fn createObjectSet theName=
(
		objectSet=LPM_Fun.createNode theName "objectSet"
		objectSet.pColor=Color (random 0 200) (random 0 200) (random 0 200)
		objectSet.intP=#((LPM_Fun.getIni "Settings" "objectSetDefaultValue" integer 2), 1, 1, 1, 1, 1, 1, 1, 1, 1, 1)
		objectSet
),

fn createLightSet theName=
(
		lightSet=LPM_Fun.createNode theName "lightSet"
		lightSet.pEnable=(LPM_Fun.getIni "Settings" "objectSetDefaultValue" integer 2)
		lightSet.pCastShadows=1
		lightSet.pColorEnable=false
		lightSet.pColor=white
		lightSet
),

-- creates shot edit shot defaults
fn createShot LPM_Root=
(
		shotRoot=LPM_Fun.firstChildByType LPM_Root "shotRoot"

		shot=LPM_Fun.createNode "Shot" "shot"
		shot.active=true
		shot.parent=shotRoot

		theProps=LPM_Fun.createCommonProps "common props"
		theProps.parent=shot
		theProps.autoUpdateName=true
		theProps.name=LPM_Fun.generateCommonPropName theProps

		shot

),

fn createScript theName=
(
	script=LPM_Fun.createNode theName "script"
	script.active=true
	script.script=""
	script

),

fn createPassGroup theName=
(
	passGroup=LPM_Fun.createNode theName "passGroup"
	passGroup.active=true
	passGroup
),

fn offsetVersionString str mode =
(
    -- Split the string at any instance of "_v"
    stringParts = (filterstring str "_v")

    -- Grab the last part of the string after the "_v" and convert it to an integer
    endPartStr = (stringParts[stringparts.count])
    endPartInt = ( endPartStr as integer )

    -- If the end part is not an integer, return the original string ( no modification )
    if endPartInt == undefined then ( return str )

    -- Increment or Decrement the number based on preferences
    if mode == #increment then (endPartInt += 1)
    if mode == #decrement then (endPartInt += -1)
    
    -- Handle preceeding 0 string padding
    endPartInt += 2000
    endPartstr = ( substring (endPartInt as string) 2 4 )

    -- Put the string back together, putting any "_v" portions removed
    fullString = ""
    for i in 1 to ( stringParts.count - 1 ) do 
    (
        fullString = stringParts[i]
        fullString += "_v"
    )

    -- Add the ending number string
    fullString += endPartstr

    -- Return the string
    return fullString
),

fn createCommonProps theName=
(
	cp=LPM_Fun.createNode theName "commonProps"
	cp._rendTimeType=rendTimeType
	cp._rendNThFrame=rendNThFrame
	cp._rendStart=rendStart
	cp._rendEnd=rendEnd
	cp._rendFileNumberBase=rendFileNumberBase
	cp._renderHeight=renderHeight
	cp._renderWidth=renderWidth
	cp._RendApertureWidth=getRendApertureWidth()
	cp._renderPixelAspect=renderPixelAspect
	cp._rendPickupFrames=rendPickupFrames
	cp._rendAtmosphere=rendAtmosphere
	cp._renderEffects=renderEffects
	cp._renderDisplacements=renderDisplacements
	cp._rendColorCheck=rendColorCheck
	cp._rendFieldRender=rendFieldRender
	cp._rendHidden=rendHidden
	cp._rendSimplifyAreaLights=rendSimplifyAreaLights
	cp._rendForce2Side=rendForce2Side
	cp._rendSuperBlack=rendSuperBlack
	cp._useAdvancedLighting=RadiosityPreferences.useAdvancedLighting
	cp._computeAdvancedLighting=RadiosityPreferences.computeAdvancedLighting
	cp.initialized=true
	cp._fileType=""
	cp.preScript=""
	cp.postScript=""
	cp
),

fn loadVraySettings cp isPreviewMode=
(
	-- Guard: do nothing if VRay is not installed. Without this, all the property
	-- assignments below would silently fail on any renderer that doesn't expose
	-- VRay properties, making the vrayProps operator a no-op with no feedback.
	if not LPM_VRayInstalled then
	(
		print "LPM loadVraySettings: V-Ray not installed -- skipping vray settings."
		return false
	)

	r = renderers.current

	if (isPreviewMode and cp.qualityType == 2) or (not isPreviewMode and cp.qualityType == 3) then
	(
		return false
	)


	if (cp.global_switches_check) then
	(
		r.options_displacement = cp.displacement
		r.options_reflectionRefraction = cp.reflrefr
	)

	if (cp.anti_aliasing_check) then
	(
		r.twolevel_basesubdivs = cp.AAmin
		r.twolevel_finesubdivs = cp.AAmax
	)

	if (cp.GI_illum_check) then
	(
		r.gi_on = cp.giOn
	)

	if (cp.GI_check) then
	(
		r.environment_gi_on = cp.giSkylightOn
		r.environment_gi_color = cp.giSkylightCol
		r.environment_gi_color_multiplier = cp.giSkylightMult
		r.environment_gi_map = cp.giSkylightMap
		r.environment_gi_map_on = cp.giSkylightMapCheck

		r.environment_rr_on = cp.giRefOn
		r.environment_rr_color = cp.giRefCol
		r.environment_rr_color_multiplier = cp.giRefMult
		r.environment_rr_map = cp.giRefMap
		r.environment_rr_map_on = cp.giRefMapCheck

	)

	if (cp.moblur_check) then
	(
		r.moblur_on = cp.moblurOn
		r.moblur_dmc_minSamples = cp.moblurSubdivs
	)

	if (cp.prog_check) then
	(
		r.imageSampler_type = 3
		r.progressive_maxSamples = cp.progMaxSubdiv
		r.progressive_max_render_time = cp.progTime
	)

	if (cp.dmc_check) then
	(
		r.dmc_earlyTermination_threshold = cp.dmcThresh
		r.dmc_subdivs_mult = cp.dmcMult
	)
),

fn loadDeadlineSettings cp isPreviewMode= -- dabelow
(
	if isPreviewMode then ( return false )

	LPM_SMTDSettings.active 	 		= cp.active
	LPM_SMTDSettings.priorityOn 		= cp.priorityOn
	LPM_SMTDSettings.priorityOffsetOn 	= cp.priorityOffsetOn
	LPM_SMTDSettings.priorityOffset 	= cp.priorityOffset
	LPM_SMTDSettings.priorityAbsoluteOn = cp.priorityAbsoluteOn
	LPM_SMTDSettings.priorityAbsolute 	= cp.priorityAbsolute
	LPM_SMTDSettings.taskSizeOn 		= cp.taskSizeOn
	LPM_SMTDSettings.taskSize 			= cp.taskSize
	LPM_SMTDSettings.submitGroupOn 		= cp.submitGroupOn
	LPM_SMTDSettings.submitGroup 		= cp.submitGroup
	LPM_SMTDSettings.submitLimitsOn 	= cp.submitLimitsOn
	LPM_SMTDSettings.submitLimits 		= cp.submitLimits
	LPM_SMTDSettings.renderTicks 		= cp.renderTicks --Tyson
	LPM_SMTDSettings.renderTicksMult	= cp.renderTicksMult --Tyson	
),

-- Dabelow
fn createDeadlineProps theName=
(
	cp=LPM_Fun.createNode theName "Deadline"

	cp.priorityOn = false
		cp.priorityOffsetOn = true
		cp.priorityOffset = 0
		cp.priorityAbsoluteOn = false
		cp.priorityAbsolute = 0

	cp.taskSizeOn = false
		cp.taskSize = 1

	cp.submitGroupOn = false
		cp.submitGroup = ""

	cp.submitLimitsOn = false
		cp.submitLimits = #()
		
	cp.renderTicks = false --Tyson
	cp.renderTicksMult = 1 --Tyson

	cp
),

-- renderImage
fn loadRenderImageSettings cp isPreviewMode=
(
	if isPreviewMode then ( return false )

	LPM_SMTDSettings.active 	 		= cp.active
--	LPM_SMTDSettings.elementOverride 	= cp.elementOverride
--	LPM_SMTDSettings.activeElement 		= cp.activeElement
),

-- renderImage
fn createRenderImageProps theName=
(
	cp=LPM_Fun.createNode theName "renderImage"

	cp.active = true
--	cp.elementOverride = true
--	cp.activeElement = #()

	cp
),

-- vrayRenderElements
fn loadVrayRenderElementsSettings cp isPreviewMode=
(
	if isPreviewMode then ( return false )

	LPM_SMTDSettings.active 	 		= cp.active
	LPM_SMTDSettings.elementOverride 	= cp.elementOverride
	LPM_SMTDSettings.activeElement 		= cp.activeElement
),

-- createVrayRenderElementsProps
fn createVrayRenderElementsProps theName=
(
	cp=LPM_Fun.createNode theName "vrayRenderElements"

	cp.active = true
	cp.elementOverride = true
	cp.activeElement = #()

	cp
),

fn createVrayProps theName=
(
	cp=LPM_Fun.createNode theName "vrayProps"

	cp.qualityType = 1

	cp.global_switches_check = false
		cp.displacement = true
		cp.reflrefr = true

	cp.anti_aliasing_check = false
		cp.AAmin = 1
		cp.AAmax = 4

	cp.GI_illum_check = false
		cp.giOn = false

	cp.GI_check = false
		cp.giSkylightOn = false
		cp.giSkylightMap = undefined
		cp.giSkylightCol = (color 205 230 255)
		cp.giSkylightMult = 1
		cp.giSkylightMapCheck = true

		cp.giRefOn = false
		cp.giRefMult = 1
		cp.giRefMap = undefined
		cp.giRefCol = (color 0 0 0)
		cp.giRefMapCheck = true

	cp.moblur_check = false
		cp.moblurOn = false
		cp.moblurSubdivs = 6

	cp.prog_check = false
		cp.progMaxSubdiv = 100
		cp.progTime = 1

	cp.dmc_check = false
		cp.dmcThresh = .01
		cp.dmcMult = 1

	cp.initialized=true
	cp
),

-- Dabelow cameraOverscan
fn loadCameraOverscanSettings cp isPreviewMode=
(
	-- if isPreviewMode then ( return false )
	--
	-- LPM_SMTDSettings.active 	 		= cp.active
	-- LPM_SMTDSettings.elementOverride 	= cp.elementOverride
	-- LPM_SMTDSettings.activeElement 		= cp.activeElement
),

-- Dabelow cameraOverscan
fn createCameraOverscanProps theName=
(
	cp=LPM_Fun.createNode theName "cameraOverscan"
	cp.active = true

	cp.fovOverride = 1.0
	cp.resOverride = false
    cp.resXOverride = 1920
    cp.resYOverride = 1080

	cp
),

-- Dabelow renderImage
fn createRenderImageProps theName=
(
	cp=LPM_Fun.createNode theName "renderImage"
	cp.active = true

	cp.renderEnabled = true

	cp
),

-- Dabelow nukeExport
fn createNukeExportProps theName=
(
	cp=LPM_Fun.createNode theName "nukeExport"
	cp.active = true

	cp.folderName = "nukeExport"
    cp.cameraEnable = true
	cp.objectsEnable = false
	cp.objectsList = #()
	cp.scriptEnable = false

	cp
),

-- Dabelow aeExport
fn createAeExportProps theName=
(
	cp=LPM_Fun.createNode theName "aeExport"
	cp.active = true

	cp.folderName = "aeExport"
    cp.cameraEnable = true
	cp.objectsEnable = false
	cp.objectsList = #()

	cp
),

fn autoSetRenderOutput =
(
	curPath = maxfilePath
	curPathSplit = filterstring curPath @"\"

	newPath = ""
	for i in 1 to ( curPathSplit.count - 1 ) do
	(
			newPath += curPathSplit[i] + @"\"
	)
	newPath += "Image_Sequences"  + @"\"

	if ( doesfileexist newPath )
	then ( return newPath )
	else ( return maxfilePath )
),

fn editLabelByNode target tvRoot=
(
	for i=0 to (tvRoot.nodes.count-1) do
	(
		newNode=tvRoot.nodes.item[i]
		if(newNode.tag.value==target) then
			LPM_Treeview_Rollout.renameNode newNode

		for j=0 to (newNode.nodes.count-1) do
		if(newNode.nodes.item[j].tag.value==target) then
			LPM_Treeview_Rollout.renameNode newNode.nodes.item[j]
	)
),

fn pickOutputRoot =
(
	thePath=getSavePath caption:"Pick the pass root" initialDir:LPM_Root.rootDir
	if(thePath!=undefined) then
	(
		LPM_Root.rootDir=thePath+"\\"
		return LPM_Root.rootDir
	)
	return undefined
),

--converts "1-4,5" to #(#(1,4), #(5)) undefined if invalid
fn stringToFrames theString=
(
	if not(iskindof theString string) then
		return undefined
	theArray=filterString theString ","
	flag=false
	for i in theArray collect
	(
		it=filterString i "-"
		newItem=for j in it collect
			j as integer
		for j in newItem where j==undefined do
			return undefined
		newItem
	)
),

--gets the active time type and converts it to a string
fn convertRendTimeTypeToString=
(
	theString="0"
	case rendTimeType of
	(
		1: theString=(currenttime as integer/ticksperframe) as string
		2: theString=((animationrange.start as integer/ticksperframe) as string) + "-" +((animationrange.end as integer/ticksperframe) as string)
		3: theString=((rendstart as integer /ticksperframe) as string) + "-" +((rendend as integer/ticksperframe) as string)
		4: theString=rendPickupFrames
	)
	theString
),

fn removeBadChars theString illegalChars:undefined=
(
	if(illegalChars==undefined) then
		illegalChars="\/:?*\"|<>"
	newString=""
	for i=1 to theString.count do
		if(findstring illegalChars theString[i])==undefined then newString+=theString[i]
	newString

),

fn getPassPath theRoot thePass theShot:undefined previewMode:false RendPreviewMode:true elementName:""=
(

	fn replaceByString original findStr replaceStr=
	(
		theString= copy original
		x=findString theString findStr
		safety=0
		while(x!=undefined) and (safety<1000)do
		(
			theString=replace theString x findStr.count replaceStr
			safety+=1
			x=findString theString findStr
		)
		theString
	)

	--Cameras----------------------------------------
	cameraString="Active_Cam"
	if(isValidNode LPM_Root.renderCamera) then
		cameraString=LPM_Root.renderCamera.name

	cp=LPM_Fun.firstChildByType thePass "commonProps"
	if(cp!=undefined) and (cp.cameraTgl) and (isValidNode cp._Camera) then
		cameraString=cp._Camera.name
	if(theShot!=undefined) then
	(
		cp=LPM_Fun.firstChildByType theShot "commonProps"
		if(cp!=undefined) and (cp.cameraTgl) and (isValidNode cp._Camera) then
			cameraString=cp._Camera.name
	)

	thePath=""
	pathString=""

	if(thePass.UseCustomPath) then
	(
		pathString=copy thePass.CustomPath
	)
	else
	(
		pathString=copy theRoot.pathString
	)

	pathString=replaceByString pathString "$Cam" cameraString


	CurDateArr = getLocalTime()
	for i = 1 to CurDateArr.count do
	(
		CurDateArr[i] = CurDateArr[i] as string
	)

	if CurDateArr[2].count == 1 then
	(
		CurDateArr[2] = "0" + CurDateArr[2]
	)

	if CurDateArr[4].count == 1 then
	(
		CurDateArr[4] = "0" + CurDateArr[4]
	)

	-- Date Token
	CurDate = CurDateArr[4] + "." + CurDateArr[2] + "." + CurDateArr[1]
	pathString = replaceByString pathString "$Date" CurDate

	CurRDate = CurDateArr[1] + "." + CurDateArr[2] + "." + CurDateArr[4]
	pathString = replaceByString pathString "$RDate" CurRDate

	if(maxFileName=="") then
	(
		pathString=replaceByString pathString "$Max" "Unsaved_Maxfile"
		pathString=replaceByString pathString "$Ver" ""
	)
	else
	(
		pathString=replaceByString pathString "$Max" (substring maxFileName 1 (maxFileName.count - 4))

		--   Version Token
		NumbersArr = #("0","1","2","3","4","5","6","7","8","9")

		CurrentfileName = maxFileName
		if CurrentfileName.count > 7 then
		(
			versionControl = substring CurrentfileName (CurrentfileName.count - 7) 4

			numberTestA = 0
			numberTestB = 0

			numberTestA = findItem NumbersArr versionControl[3]
			numberTestB = findItem NumbersArr versionControl[4]

			if (versionControl[1] == "_") and (versionControl[2] == "v") and (numberTestA != 0) and (numberTestB != 0)then
			(
				CurVersion = substring versionControl 2 3

				pathString=replaceByString pathString "$Ver" CurVersion
			)
			else
			(
				pathString=replaceByString pathString "$Ver" ""
			)
		)
	)
	if(theShot==undefined) then
		pathString=replaceByString pathString "$Shot" ""
	else
		pathString=replaceByString pathString "$Shot" (LPM_Fun.getName theShot.name)

	pathString=replaceByString pathString "$Pass" (LPM_Fun.getname thePass.name)
	if((matchpattern pathString pattern:"*$Element*") ==false) then
	(
		pathString+=ElementName
	)
	pathString = replaceByString pathString "$Element" elementName
	pathString=replaceByString pathString "$APass" ""

	if(previewMode) then
		pathString="(Root)\\"+pathString
	else
	(
		if(thePass.useRootDir) then
		(
			pathString=thePass.rootDir+pathString
		)
		else
		(
			pathString=theRoot.rootdir+pathString
		)

		if elementName != "" then
		(
			pathString += "_"
		)
	)

	--gets rid of extraneous blackslashes
	isUNC=false
	if(pathString[1]=="\\" and pathString[2]=="\\") then
		isUNC=true

	theArray=filterString pathString "\\"
	pathString=""
	for i=1 to (theArray.count - 1) do
		pathString+=theArray[i]+"\\"

	pathString+=theArray[theArray.count]
	if(isUNC) then pathString="\\\\"+pathString

	--filetype

-- TODO: Fix Filetype Override

	if(LPM_Root.fileType==undefined) then LPM_Root.fileType="exr"
	theFileType=LPM_Root.fileType

	--cp=LPM_Fun.firstChildByType thePass "commonProps"
	cp=LPM_Fun.firstChildByType theShot "commonProps"
		if(cp!=undefined) and (cp.fileTypeTgl) then
			theFileType=cp._fileType

	try( print ("------------------------------------------ Filetype Override Portion "))catch()
	try( print ("----------------------cp._fileType " + theFileType)						)catch()

	if(theShot!=undefined) then
	(
		cp=LPM_Fun.firstChildByType theShot "commonProps"
		if(cp!=undefined) and (cp.fileTypeTgl) then
			theFileType=cp._fileType
	)

	if(previewMode) then
		pathString+="####."+theFileType
	else
		pathString+="."+theFileType
	if not(RendPreviewMode) then
	(
		makeDir (getFilenamePath pathString) all:true
	)

	pathString
),

fn uppercase instring = -- beginning of function definition
(
	local upper, lower, outstring -- declare variables as local
	upper="ABCDEFGHIJKLMNOPQRSTUVWXYZ" -- set variables to literals
	lower="abcdefghijklmnopqrstuvwxyz"
	outstring=copy instring
	for i=1 to outstring.count do
	( j=findString lower outstring[i]
	if (j != undefined) do outstring[i]=upper[j]
	)
	outstring -- value will be returned as function result
),

fn convertTimeToString frame baseNumber =
(
	intFrame= (frame as integer)/ticksperframe
	intFrame+=baseNumber
	stringFrame=intFrame as string
	numZeros=(4- stringFrame.count)
	if(intFrame>=0) then
		case numZeros of
		(
			1: stringFrame="0"+stringFrame
			2: stringFrame="00"+stringFrame
			3: stringFrame="000"+stringFrame
		)

	else
	(
		case numZeros of
		(
			1:(
				stringFrame=subString stringFrame 2 -1
				stringFrame="-0"+stringFrame
				)
			2: (
				stringFrame=subString stringFrame 2 -1
				stringFrame="-00"+stringFrame
				)
		)
	)
	stringFrame
),

fn getIni category theKey defaultType defaultValue=
(
	val=getINISetting ( getdir #plugcfg + "\\LPM.ini" ) category theKey
	if(val=="" )then
		defaultValue
	else
		val as defaultType
),

fn setIni category theKey theValue=
(
	setINISetting ( getdir #plugcfg + "\\LPM.ini" ) category theKey (theValue as string)
),

fn getProp theNode theKey defaultType defaultValue=
(
	val = getUserProp theNode theKey
	if (val=="") or (val==undefined) then
		defaultValue
	else
		val as defaultType
),

fn setProp theNode theKey theValue=
(
	setUserProp theNode theKey (theValue as string)
),

fn getName theString=
(
	substring theString 5 -1
),

fn generatePassName thePass=
(
	tmpName = LPM_Fun.getName thePass.name

	tmpName
),

fn generateDeadlineName cp=
(
	theName = ( cp.type + " " )

	if (cp.priorityOn) then
	(
		theName += "[Priority] "
	)

	if (cp.taskSizeOn) then
	(
		theName += "[TaskSize] "
	)
	if (cp.submitGroupOn) then
	(
		theName += "[Group] "
	)
	if (cp.submitLimitsOn) then
	(
		theName += "[Limit] "
	)

	theName
),

-- Dabelow vrayRenderElements
fn generateVrayRenderElementsName cp=
(
	theName = ( "VRay Render Elements Override" )
	theName
),

-- Dabelow renderImage
fn generateRenderImageName cp=
(
	theName = ( "Render Image" )
	theName
),

-- Dabelow cameraOverscan
fn generateCameraOverscanName cp=
(
	theName = ( "Camera Overscan Override" )

	-- returning before fully calculating the name, because it was not working for some reason TODO:
	return theName

	theName += (" [" + ( cp.fovOverride as string ) + "]" )

	if ( cp.resOverride ) then
	(
		theName += (" [" + ( cp.resXOverride as string ) + ( cp.resYOverride as string ) +"]" )
	)

	theName
),

-- Dabelow nukeExport
fn generateRenderImageName cp=
(
	theName = ( "Render Image" )

	return theName
),

-- Dabelow nukeExport
fn generateNukeExportName cp=
(
	theName = ( "Nuke Export" )

	return theName
),

-- Dabelow aeExport
fn generateAeExportName cp=
(
	theName = ( "After Effects Export" )

	return theName
),

fn generateVrayPropName cp=
(
	theName = ""

	if (cp.qualityType == 1) then
	(
		theName = "[Final/Prev] "
	)else if (cp.qualityType == 2) then
	(
		theName = "[Final] "
	)else if (cp.qualityType == 3) then
	(
		theName = "[Prev] "
	)

	theName += "Vray Override "

	if (cp.global_switches_check) then
	(
		theName += "[Globals] "
	)
	if (cp.anti_aliasing_check) then
	(
		theName += "[AA] "
	)
	if (cp.GI_check) then
	(
		theName += "[GI] "
	)
	if (cp.moblur_check) then
	(
		theName += "[Moblur] "
	)
	if (cp.prog_check) then
	(
		theName += "[Prog] "
	)
	if (cp.dmc_check) then
	(
		theName += "[DMC] "
	)

	theName
),


fn generateCommonPropName cp=
(
	theName=""
	if(cp.autoUpdateName==false) then
		theName=(LPM_Fun.getName cp.name)
	else
	(
		if(cp.	cameraTgl) then
			if(isvalidNode cp._camera) then
				theName+=cp._camera.name+" "
			else
				theName+="Invalid Camera "
		if(cp.timeOutputTgl) then
			case cp._rendTimeType of
			(
				1: theName+="Single "
				2: theName+="Active Segment "
				3: theName+="["+(((cp._rendStart as integer)/ticksperframe) as string)+","+(((cp._rendEnd as integer)/ticksperframe) as string)+"] "
				4: theName+="{"+cp._rendPickupFrames+"} "
			)
		if(		cp.outputSizeTgl ) then
			theName+="("+(cp._renderWidth as string )+"x"+(cp._renderHeight as string)+")"
		if(cp.usePreScript) then
			theName+=" |Pre|"
		if(cp.usePostScript) then
			theName+=" |Post|"
	)
	if(theName=="") then
		theName="Common (Auto-Name)"
	theName
),

fn NumbersFromString TmpString =
(

	fn replaceByString original findStr replaceStr=
	(
		theString= copy original
		x=findString theString findStr
		safety=0
		while(x!=undefined) and (safety<1000)do
		(
			theString=replace theString x findStr.count replaceStr
			safety+=1
			x=findString theString findStr
		)
		theString
	)

	TmpNumbers = #()

	TmpString = replaceByString TmpString " " ""

	TmpStringsArr = FilterString TmpString ","

	for i = 1 to TmpStringsArr.count do
	(
		TmpNumer = TmpStringsArr[i] as integer

		if TmpNumer != undefined then
		(
			appendIfUnique TmpNumbers TmpNumer
		)
		else
		(
			TmpIntervalArr =  FilterString TmpStringsArr[i] "-"

			if TmpIntervalArr.count == 2 then
			(
				TmpStartNumber =  TmpIntervalArr[1] as integer
				TmpEndNumber =  TmpIntervalArr[2] as integer



				if (TmpStartNumber  != undefined) and (TmpEndNumber  != undefined) then
				(
					if TmpEndNumber>TmpStartNumber then
					(
						TmpIntervalNumbers =( for j = TmpStartNumber to TmpEndNumber collect j)

						for j= 1 to TmpIntervalNumbers.count do
						(
							appendIfUnique TmpNumbers TmpIntervalNumbers[j]
						)
					)
				)
			)
		)
	)

	TmpNumbers
),

fn CreateBWmask TmpObjArr TmpName =
(
	REManager = maxOps.GetCurRenderElementMgr()
	REcount = REManager.NumRenderElements()

	vr=renderers.current
	theRenderer=(classof vr) as string

	try
	(
		if (findString theRenderer "V_Ray" !=undefined) then
		(
			REManager.AddRenderElement (MultiMatteElement elementname:TmpName)

			theElement = REManager.GetRenderElement REcount

			theElement.enabled = true
			theElement.R_gbufIDOn = theElement.G_gbufIDOn = theElement.B_gbufIDOn = false
			theElement.redListType = theElement.greenListType = theElement.blueListType = 1

			theElement.redList = theElement.greenList = theElement.blueList = TmpObjArr
		)

		if (findString theRenderer "Corona" !=undefined) then
		(
			REManager.AddRenderElement (CMasking_Mask elementname:TmpName)

			theElement = REManager.GetRenderElement REcount

			theElement.enabled = true
			theElement.mode = 0
			theElement.nodesMonoOn = true
			theElement.nodesMonoIncludeMod = true
			theElement.nodesMono = TmpObjArr
		)
	)
	catch()
),

fn CreateRGBmask TmpObjArr1 TmpObjArr2 TmpObjArr3 TmpName =
(
	REManager = maxOps.GetCurRenderElementMgr()
	REcount = REManager.NumRenderElements()


	vr=renderers.current
	theRenderer=(classof vr) as string

	try
	(
		if (findString theRenderer "V_Ray" !=undefined) then
		(
			REManager.AddRenderElement (MultiMatteElement elementname:TmpName)

			theElement = REManager.GetRenderElement REcount

			theElement.enabled = true
			theElement.R_gbufIDOn = theElement.G_gbufIDOn = theElement.B_gbufIDOn = false
			theElement.redListType = theElement.greenListType = theElement.blueListType = 1

			theElement.redList = TmpObjArr1
			theElement.greenList = TmpObjArr2
			theElement.blueList = TmpObjArr3
		)

		if (findString theRenderer "Corona" !=undefined) then
		(
			REManager.AddRenderElement (CMasking_Mask elementname:TmpName)

			theElement = REManager.GetRenderElement REcount

			theElement.enabled = true
			theElement.mode = 1
			theElement.nodesROn = theElement.nodesGOn =theElement.nodesBOn = true
			theElement.nodesRIncludeMod = theElement.nodesGIncludeMod = theElement.nodesBIncludeMod = true
			theElement.nodesR = TmpObjArr1
			theElement.nodesG = TmpObjArr2
			theElement.nodesB = TmpObjArr3
		)
	)
	catch()
),

fn CreateIDBWmask TmpNumbersArr isMatID:false =
(
	REManager = maxOps.GetCurRenderElementMgr()
	REcount = REManager.NumRenderElements()


	vr=renderers.current
	theRenderer=(classof vr) as string

	try
	(
		if (findString theRenderer "V_Ray" !=undefined) then
		(
			for i = 1 to TmpNumbersArr.count do
			(
				if isMatID then
				(
					REManager.AddRenderElement (MultiMatteElement elementname:("am_mID_" + (i as String)))
				)
				else
				(
					REManager.AddRenderElement (MultiMatteElement elementname:("am_oID_" + (i as String)))
				)

				theElement = REManager.GetRenderElement (REcount+i-1)

				theElement.enabled = true
				theElement.R_gbufIDOn = theElement.G_gbufIDOn = theElement.B_gbufIDOn = true
				theElement.R_gbufID = theElement.G_gbufID = theElement.B_gbufID = TmpNumbersArr[i]
				theElement.MatID = isMatID
			)
		)

		if (findString theRenderer "Corona" !=undefined) then
		(
			for i = 1 to TmpNumbersArr.count do
			(
				if isMatID then
				(
					REManager.AddRenderElement (CMasking_Mask elementname:("am_mID_" + (i as String)))

					heElement = REManager.GetRenderElement (REcount+i-1)

					theElement.enabled = true

					theElement.mode = 0
					theElement.materialMonoOn = true
					theElement.materialMono = TmpNumbersArr[i]
				)
				else
				(
					REManager.AddRenderElement (CMasking_Mask elementname:("am_oID_" + (i as String)))

					theElement = REManager.GetRenderElement (REcount+i-1)

					theElement.enabled = true

					theElement.mode = 0
					theElement.objectMonoOn = true
					theElement.objectMono = TmpNumbersArr[i]
				)

			)
		)
	)
	catch()
),

fn CreateIDRGBmask TmpNumbersArr isMatID:false =
(
	REManager = maxOps.GetCurRenderElementMgr()
	REcount = REManager.NumRenderElements()

	TmpIDinElementCount = 0
	TmpElemNumb = -1



	vr=renderers.current
	theRenderer=(classof vr) as string

	try
	(
		if (findString theRenderer "V_Ray" !=undefined) then
		(
			for i = 1 to TmpNumbersArr.count do
			(
				TmpIDinElementCount += 1

				theElement = REManager.GetRenderElement (REcount+TmpElemNumb)

				if TmpIDinElementCount == 1 then
				(
					TmpElemNumb += 1

					if isMatID then
					(
						REManager.AddRenderElement (MultiMatteElement elementname:("am_mID_" + ((TmpElemNumb + 1) as String)))
					)
					else
					(
						REManager.AddRenderElement (MultiMatteElement elementname:("am_oID_" + ((TmpElemNumb + 1) as String)))
					)

					theElement = REManager.GetRenderElement (REcount+TmpElemNumb)

					theElement.R_gbufIDOn = theElement.G_gbufIDOn = theElement.B_gbufIDOn = false
					theElement.MatID = isMatID
					theElement.enabled = true
				)

				case TmpIDinElementCount of
				(
					1:
					(
						theElement.R_gbufIDOn = true
						theElement.R_gbufID = TmpNumbersArr[i] as integer
					)
					2:
					(
						theElement.G_gbufIDOn = true
						theElement.G_gbufID = TmpNumbersArr[i] as integer
					)
					3:
					(
						theElement.B_gbufIDOn = true
						theElement.B_gbufID = TmpNumbersArr[i] as integer
						TmpIDinElementCount = 0
					)
				)


			)
		)

		if (findString theRenderer "Corona" !=undefined) then
		(
			for i = 1 to TmpNumbersArr.count do
			(
				TmpIDinElementCount += 1

				theElement = REManager.GetRenderElement (REcount+TmpElemNumb)

				if TmpIDinElementCount == 1 then
				(
					TmpElemNumb += 1

					if isMatID then
					(
						REManager.AddRenderElement (CMasking_Mask elementname:("am_mID_" + ((TmpElemNumb + 1) as String)))
					)
					else
					(
						REManager.AddRenderElement (CMasking_Mask elementname:("am_oID_" + ((TmpElemNumb + 1) as String)))
					)

					theElement = REManager.GetRenderElement (REcount+TmpElemNumb)

					theElement.mode = 1
					theElement.enabled = true
				)

				if isMatID then
				(
					case TmpIDinElementCount of
					(
						1:
						(
							theElement.materialROn = true
							theElement.materialR = TmpNumbersArr[i] as integer
						)
						2:
						(
							theElement.materialGOn = true
							theElement.materialG = TmpNumbersArr[i] as integer
						)
						3:
						(
							theElement.materialBOn = true
							theElement.materialB = TmpNumbersArr[i] as integer
							TmpIDinElementCount = 0
						)
					)
				)
				else
				(
					case TmpIDinElementCount of
					(
						1:
						(
							theElement.objectROn = true
							theElement.objectR = TmpNumbersArr[i] as integer
						)
						2:
						(
							theElement.objectGOn = true
							theElement.objectG = TmpNumbersArr[i] as integer
						)
						3:
						(
							theElement.objectBOn = true
							theElement.objectB = TmpNumbersArr[i] as integer
							TmpIDinElementCount = 0
						)
					)
				)

			)
		)
	)
	catch()
),


renderBarProgress,

fn init_LPM_renderProgress_Ro thePass theShot =
(
	global  LPM_renderProgress_Ro
	rollout LPM_renderProgress_Ro  "LPM Render Progress" width:200 height:95
	(
		label shotLabel "Shot: --" align:#left
		label passLabel "Pass:" align:#left
		label escLabel "Hold Esc to cancel all Passes/Shots." align:#left
		progressBar theBar
		hyperlink warning "No Warnings/Errors" color:(color 6 135 6)
	)

	createDialog LPM_renderProgress_Ro pos:(LPM_FUN.getROPos LPM_renderProgress_Ro.width)

	if(isvalidnode theShot) then
		LPM_renderProgress_Ro.shotLabel.text="Shot:"+(LPM_Fun.getname theShot.name)

	LPM_renderProgress_Ro.passLabel.text="Pass:"+(LPM_Fun.generatePassName thePass)

	if(renderBarProgress!=undefined) then
		LPM_renderProgress_Ro.theBar.value=renderBarProgress
),

fn getROPos dialogWidth=
(

	left=LPM_Fun.getIni "Settings" "dialogAlignLeft" booleanClass true

	thePos=(point2 0 0)
	if(LPM_Treeview_rollout!=undefined) and (LPM_Treeview_rollout.open) then
	(
		thePos=(GetDialogPos LPM_Treeview_rollout)
	)

	if(thePos.x<dialogWidth) then
		left=false

	if(left) then
		thePos=thePos-[dialogWidth+20,0]
	else
		thePos=thePos+[LPM_Treeview_Rollout.width+20,0]
	thePos

),

fn launchNetworkRender=
(
	filein (LPM_Dir+@"plugins\Deadline10.0.ms")
	LPM_DeadlineAPI.submit()
),

/*
mode:#preview, #previewHalf, #local, #backburner, #maxfile, #hwPreview
renderCollect:(#(pass), #(pass,shot))
*/
whoToRender=#(),

fn renderSubmit mode netRenderSettings:undefined=
(
	renderCollect=whoToRender

	flag=true
	for i=1 to renderCollect.count where flag do
	(
		LPM_Fun.renderBarProgress=(100*(i-1))/renderCollect.count
		LPM_renderPass renderCollect[i][1] mode theShot:renderCollect[i][2] netRenderSettings:netRenderSettings
		if(keyboard.escPressed) then flag=false
	)
),

fn collectPasses activeOnly:true theShot:undefined=
(
	o=not activeOnly
	renderCollect=#()

	for pg in LPM_Root.children where (pg.type=="passGroup" and (pg.active or o)) do
		for thePass in pg.children where  (isvalidnode thePass) and (thePass.type=="pass") and (thePass.active or o)  do append renderCollect #(thePass, theShot)
	for thePass in LPM_Root.children where (thePass.type=="pass") and (thePass.active or o)  do append renderCollect #(thePass, theShot)
	renderCollect
),

fn setWhoToRenderByRenderType =
(
	renderCollect=#()
	shotRoot=(LPM_Fun.firstChildByType LPM_Root "shotRoot")
	if(LPM_Root.renderType <=2) then
	(
		renderCollect=collectPasses()
	)
	else
	(
		for theShot in shotRoot.children  where (theShot.type=="shot") and (theShot.active) do
			(
				if(theShot.allpasses) then
				(
					join renderCollect (collectPasses activeOnly:true theShot:theShot)
				)
				else
					for i=1 to theShot.passes.count  where  (isvalidnode theShot.passes[i])  and (theShot.passesOn[i]==true) and (theShot.passes[i].active) do append renderCollect #(theShot.passes[i], theShot)
			)
	)
	LPM_Fun.whoToRender=renderCollect
),

fn getWhoToRender =
(
	return LPM_Fun.whoToRender
),


fn localRenderSubmit=
(
	if(LPM_Root.renderType==2) or (LPM_Root.renderType==4)
	then (renderFlag=#hwPreview)
	else(renderFlag=#local)
	
	renderSubmit renderFlag
	LPM_Fun.renderBarProgress=undefined
),

fn getPreviewFile thePass=
(
	tmpName = ""
	
	try(tmpName = (getDir #preview)+"\\"+maxFileName+"_"+"\\"+(LPM_Fun.getname thePass.name)+"_."+(LPM_Fun.getIni "Settings" "Default Format" string "exr"))
	catch()

	tmpName
),


fn quickScripts=
(
	global LPM_QuickScripts
	pathString=(LPM_Dir+@"QuickScripts\");

	--right click menu for passes
	RC="rcMenu LPM_QuickScripts (\n"
	count=0;
	theDirs=getdirectories (pathString+"*")
	--load all the subfolders
	appendLater=""
	tmpSepNumb = 0
	for fit in theDirs do
	(
		subName=(substring fit (pathString.count+1) (fit.count-pathstring.count-1))
			subName = substring subName 3 subName.count
		RC+="subMenu \""+subName +"\"\n"
		RC+="(\n"
		theFiles=getFiles (fit+"*.ms")
		theFiles2=getFiles (fit+"*.mse")

		join theFiles theFiles2
		sort theFiles



		for it in theFiles do
		(
			tmpSepNumb += 1

			if ((findString (getFileNameFile it) "seperator" ) == undefined) then
			(
				RC+="menuItem "+("a"+count as string)  +" \"" +(substring (getFileNameFile it) 3 (getFileNameFile it).count) +"\";\n"
				appendLater+="on "+("a"+count as string)  + " picked do try(filein @\""+ it +"\")catch(Messagebox \"Error Loading Script\");\n"
				count+=1;
			)
			else
			(
				RC+="seperator "+ "seper_100" + (tmpSepNumb as string) + "\n"
			)
		)
		RC+=")\n"
	)

	RC+=appendLater
	theFiles=getFiles (pathString+"*.ms")
	theFiles2=getFiles (pathString+"*.mse")

	join theFiles theFiles2
	sort theFiles

	--tmpSepNumb = 0

	for it in theFiles do
	(
		tmpSepNumb += 1

		if ((findString (getFileNameFile it) "seperator" ) == undefined) then
		(
			RC+="menuItem "+("a"+count as string)  +" \"" +(substring (getFileNameFile it) 3 (getFileNameFile it).count) +"\";\n"
			RC+="on "+("a"+count as string)  + " picked do try(filein @\""+ it +"\")catch(Messagebox \"Error Loading Script\");\n"
			count+=1;
		)
		else
		(
			RC+="seperator "+ "seper_100" + (tmpSepNumb as string) + "\n"
		)

	)

	RC+="Seperator s1\n"
	RC+="menuItem AddNewScriptsHere \"Add New Scripts here...\";\n"
	RC+="on AddNewScriptsHere picked do shellLaunch @\"" + pathString + "\" \"\";\n"
	RC+=")\n"
	execute RC
	popUpMenu LPM_QuickScripts
),

fn InitListView theListView theColumnName theColumnWidth=
(
	theListView.Columns.Clear()
	theListView.Items.Clear()

	theListView.view = (dotNetClass "system.windows.forms.view").Details

	--showmethods theListView
	theListView.GridLines = false
	theListView.CheckBoxes = true
	theListView.FullRowSelect = true
	theListView.Sorting = (dotNetClass "System.Windows.Forms.SortOrder").None
	theListView.HideSelection = false
	theListView.AutoArrange = false
	theListView.HeaderStyle = (dotNetClass "System.Windows.Forms.ColumnHeaderStyle").none
	show theListView.TopItem-- = dotNetObject "System.Windows.Forms.ListViewItem" "gfgf"

	theListView.ForeColor = LPM_FontColor
	theListView.BackColor = LPM_BackColor

	theListView.columns.add theColumnName (theColumnWidth - 30)

	--theListView.AutoResizeColumn()
),

fn FillListView theListView TmpInputRaws TmpSelectedRaws=
(
	TmpRows = #()

	for i = 1 to TmpInputRaws.count do
	(
		theListViewItem = dotNetObject "System.Windows.Forms.ListViewItem" (TmpInputRaws[i])
		theListViewItem.Checked = false

		TmpFound = finditem TmpSelectedRaws TmpInputRaws[i]

		if(TmpFound !=0) then
		(
			theListViewItem.Checked = true
		)

		append TmpRows theListViewItem
	)

	theListView.items.addRange TmpRows
	theListView.Update()
),

fn SaveListView theListView =
(
	TmpSelectedArr = #()

	TmpCount = theListView.items.count as integer
	if TmpCount > 0 then
	(
	for i = 1 to TmpCount do
		(
			if theListView.items.item[i-1].checked then
			(
				append TmpSelectedArr theListView.items.item[i-1].text
			)
		)
	)
	TmpSelectedArr
),
fn SaveListViewNumbers theListView =
(
	TmpSelectedArr = #()

	TmpCount = theListView.items.count as integer
	if TmpCount > 0 then
	(
	for i = 1 to TmpCount do
		(
			if theListView.items.item[i-1].checked then
			(
				append TmpSelectedArr (i)
			)
		)
	)
	TmpSelectedArr
)

)

LPM_Fun=(LPM_Fun_Struct())





fn LPM_renderer_closed =
(
	callbacks.RemoveScripts #tabbedDialogDeleted id:#myscript_update

	thePass=LPM_activePass
	TheProps = LPM_Fun.firstChildByType thePass "renderProps"


	try
	(
		TheProps.propsAlternate=LPM_Fun.saveRenderPresetNew()
	)
	catch
	(
		TheProps.props=LPM_Fun.saveRenderPreset()
		Messagebox "Please recreate renderer override"
	)

	TheProps.initialized=true



	theRenderer=(classof renderers.current) as string
	theNode=LPM_treeview_rollout.tv.selectedNode

	if theNode.tag.value.type == "pass" then
	(
		TmpTmpNode = theNode
		for i = 0 to (theNode.nodes.count - 1) do
		(
			if theNode.nodes.item[i].tag.value.type == "renderProps" then
			(
				TmpTmpNode = theNode.nodes.item[i]
			)
		)

		theNode = TmpTmpNode
	)

	if(theNode.text=="Render Override") or (theNode.text=="Scanline") or (theNode.text=="Mental Ray") or (theNode.text=="VRay") or (theNode.text=="Corona") then
	(
		if(findstring theRenderer "Scanline"!=undefined) then
		(
			theNode.text="Scanline"
			theNode.tag.value.name="LPM_"+"Scanline"

		)
		else if (findstring theRenderer "Mental"!=undefined) then
		(
			theNode.text="Mental Ray"
			theNode.tag.value.name="LPM_"+"Mental Ray"
		)
		else if (findString theRenderer "V_Ray" !=undefined) then
		(
			theNode.text="VRay"
			theNode.tag.value.name="LPM_"+"Vray"
		)
		else if (findString theRenderer "Corona" !=undefined) then
		(
			theNode.text="Corona"
			theNode.tag.value.name="LPM_"+"Corona"
		)
	)

	try
	(
		LPM_Fun.loadRenderPresetNew LPM_oldRenderSettingsNew
	)
	catch
	(
		LPM_Fun.loadRenderPreset LPM_oldRenderSettings
	)
	LPM_treeview_rollout.UnFreezeWindow()
)



fn LPM_ProSequencerUpdate =
(

	try
	(
		shotRoot=LPM_Fun.firstChildByType LPM_Root "shotRoot"

		if shotRoot != undefined then
		(
			ProSequencerData=ProSequencer.getSequenceData()

			TmpShots = for CurShot in shotRoot.children where CurShot.type=="shot" collect CurShot

			for i=1 to TmpShots.count do
			(
				CurShot = TmpShots[i]

				theCp=LPM_Fun.firstChildByType CurShot "commonProps"

				if theCp != undefined then
				(
					for tmptrack in ProSequencerData do
					(
						if (isvalidnode tmptrack.cam) and (tmptrack.cam == theCp._Camera) then
						(
							CurShot.active = tmptrack.enabled
							theCp.timeOutputTgl = true
							theCp._rendTimeType = 3
							theCp._rendStart = tmptrack.clipStart
							theCp._rendEnd = tmptrack.clipEnd - (1 as time)
						)
					)
				)

			)
		)


		LPM_treeview_rollout.updateTV()
	)
	catch
	(

	)


)


fn CheckIsAllLayerObjects =
(

	IsAllLayerObjects = false
	TmpLayersArr = #()
	TmpLayersObjArr = #()

	OutLayersArr = #()

	if selection[1] != undefined then
	(




		tmpSelArr = selection as array


		for obj in tmpSelArr do
		(
			tmpLayer = obj.layer
			tmpLayerName = tmpLayer.name
			LayerNumb = findItem TmpLayersArr tmpLayerName

			if LayerNumb > 0 then
			(
				append TmpLayersObjArr[LayerNumb] obj
			)
			else
			(
				append TmpLayersArr tmpLayerName
				TmpLayersObjArr[TmpLayersObjArr.count+1] = #(obj)
			)

		)

		IsAllLayerObjectsFirstFlag = true

		for i=1 to TmpLayersArr.count do
		(

			tmpLayer = LayerManager.getLayerFromName TmpLayersArr[i]

			tmpLayer.nodes &TmpNodes
			TmpNodes = TmpNodes  as array
			TmpNodesCount = TmpNodes.count

			TmpLayersObjArrCount = TmpLayersObjArr[i].count

			if (TmpLayersObjArrCount == TmpNodesCount)and(IsAllLayerObjectsFirstFlag) then
			(
				if(TmpLayersArr[i]!="zz-LPM") then
				(
					IsAllLayerObjects = true

					append OutLayersArr TmpLayersArr[i]
				)
			)
			else
			(
				IsAllLayerObjects =IsAllLayerObjectsFirstFlag= false
			)
		)

	)
	#(IsAllLayerObjects,OutLayersArr)
)


Struct LPM_ObjSetProps (intP,pMatEnable,pMaterial,expanded,pColor,visible,selectable,userProp)

Struct LPM_LightSetProps (pEnable,pMultiplierEnable,pMultiplier,pColorEnable,pColor,pCastShadows,pAffectDiffuse,pAffectSpecular,pAffectReflections,pTextureEnable,pTexture,expanded)

LPM_ObjSetPropsBuff = LPM_ObjSetProps()
LPM_LightSetPropsBuff = LPM_LightSetProps()
