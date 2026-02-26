rootCA = attributes root
attribID:#(0x73921019, 0x018210301)
version:2
(
	parameters main
	(
		type type:#string
		rootDir type:#string
		fullOutputPath type:#string
		processorActive type:#integer
		deadlinePath type:#string
		deadlinePathManual type:#string
		deadlinePathManualEnabled type:#boolean
		deadlinePathOverridden type:#boolean
		fileType type:#string
		pathString type:#string
		quietMode type:#boolean default:true
		renderCamera type:#node
		compositorTexture type:#textureMap
		expanded type:#boolean
		renderType type:#integer default:3
		previewSize type:#integer default:50
		LastActivePass type:#string default:""
		PostConvertVrimg2exr type:#string default:"C:\\Program Files\\Chaos Group\\V-Ray\\3dsmax 2014 for x64\\tools\\vrimg2exr.exe"
		PostConvert type:#boolean default:false
		PostConvertCompression type:#integer default:3
		PostConvertHalfFoat type:#boolean default:false
		PostConvertDatawindow type:#boolean default:false
		PostRenderFrameScript type:#boolean default:false
		PostRenderFrameScriptText type:#string default:""

		--namesUpdated
		namesUpdated type:#boolean default:false
		maxFileRenderRoot type:#string
		maxfileRenderType type:#integer default:1
		runBatch type:#boolean default:false
		useCommand type:#boolean default:false
		commandLine type:#string default:""
		id type:#integer default:0099
	)
)

LPM_shotRootCA = attributes LPM_shotRoot
attribID:#(0x21251d7e, 0x617b895f)
version:1
(
	parameters main
	(
		type type:#string
		expanded type:#boolean
	)
)

LPM_shotCA = attributes LPM_Shot
attribID:#(0x46b7dff4, 0x73454b9)
version:1
(
	parameters main
	(
		type type:#string
		active type:#boolean default:true
		allPasses type:#boolean default:true
		passes type:#nodeTab tabSizeVariable:true
		passesOn type:#boolTab tabSizeVariable:true
		expanded type:#boolean
		displayPass type:#node
	)
)

LPM_PassGroupCA = attributes LPM_PassGroup
attribID:#(0x3584c80a, 0x762166eb)
version:1
(
	parameters main
	(
		type type:#string
		expanded type:#boolean
		active type:#boolean
	)
)

passCA = attributes pass
attribID:#(0x83813919, 0x02155421)
(
	parameters main
	(
		type type:#string
		expanded type:#boolean
		active type:#boolean default:true

		hideMode type:#integer default:1

		useRootDir type:#boolean default:false
		rootDir type:#string default:""

		UseCustomPath type:#boolean default:false
		CustomPath type:#string default:"$Shot\\$APass$Pass$Element\\$APass$Pass$Element_"

		VRayRaw type:#boolean default:false
		VRayRawFileType type:#integer default:1
		VRayRawFull type:#boolean default:false
		VRayRawDeep type:#boolean default:false

		PostConvert type:#boolean default:false
		PostConvertCompression type:#integer default:3
		PostConvertHalfFoat type:#boolean default:false
		PostConvertDatawindow type:#boolean default:false
	)
)

renderPropsCA = attributes renderProps
attribID:#(0x21910309, 0x01019380)
(
	parameters main
	(
		type type:#string
		props type:#intTab tabSizeVariable:true
		initialized type:#boolean
		active type:#boolean default:true
		propsAlternate type:#string default:""
	)
)

vrayPropsCA = attributes vrayProps
attribID:#(0x21912344, 0x01013380)
(
	parameters main
	(
		type type:#string
		props type:#intTab tabSizeVariable:true
		initialized type:#boolean
		active type:#boolean default:true

		qualityType type:#integer

		global_switches_check type:#boolean
			displacement type:#boolean
			reflrefr type:#boolean

		anti_aliasing_check type:#boolean
			aaMin type:#integer
			aaMax type:#integer

		GI_illum_check type:#boolean
			giOn type:#boolean

		GI_check type:#boolean
			giSkylightOn type:#boolean
			giSkylightMap type:#texturemap
			giSkylightCol type:#color
			giSkylightMult type:#float
			giSkylightMapCheck type:#boolean

			giRefOn type:#boolean
			giRefCol type:#color
			giRefMap type:#texturemap
			giRefMult type:#float
			giRefMapCheck type:#boolean

		moblur_check type:#boolean
			moblurOn type:#boolean
			moblurSubdivs type:#integer

		prog_check type:#boolean
			progMaxSubdiv type:#float
			progTime type:#float

		dmc_check type:#boolean
			dmcThresh type:#float
			dmcMult type:#float

	)
)

-- Dabelow deadlinePropsCA
deadlinePropsCA = attributes deadlineProps
attribID:#(0x73e22a56, 0x439f0d00)
(
	parameters main
	(
		type type:#string
		active type:#boolean default:true
		priorityOn type:#boolean default:false
		priorityOffsetOn type:#boolean default:false
		priorityOffset type:#integer default:0
		priorityAbsoluteOn type:#boolean default:false
		priorityAbsolute type:#integer default:0
		taskSizeOn type:#boolean default:false
		taskSize type:#integer default:1
		submitGroupOn type:#boolean default:false
		submitGroup type:#string default:""
		submitLimitsOn type:#boolean default:false
		submitLimits type:#stringTab tabSizeVariable:true
		renderTicks type:#boolean default:false --Tyson
		renderTicksMult type:#integer default:1 --Tyson
	)
)

-- Dabelow cameraOverscan
cameraOverscanPropsCA = attributes cameraOverscanProps
attribID:#(0x54e3ca47, 0x1381f195)
(
	parameters main
	(
		type type:#string
		active type:#boolean default:true
 		-- initialized type:#boolean

		fovOverride type:#float default:1.1
	    resOverride type:#boolean default:false
    	resXOverride type:#integer default:1920
    	resYOverride type:#integer default:1080
	)
)

-- Dabelow renderImage
renderImagePropsCA = attributes renderImageProps
attribID:#(0x2cc0578d, 0x1919e838)
(
	parameters main
	(
		type type:#string
		active type:#boolean default:true
    
	  renderEnabled type:#boolean default:false

	)
)

-- Dabelow nukeExport
nukeExportPropsCA = attributes nukeExportProps
attribID:#(0x6250aff1, 0x44179dee)
(
	parameters main
	(
		type type:#string
		active type:#boolean default:true

		folderName type:#string
		cameraEnable type:#boolean
		objectsEnable type:#boolean
		objectsList type:#stringTab tabSizeVariable:true
		scriptEnable type:#boolean
	)
)

-- Dabelow aeExport
aeExportPropsCA = attributes aeExportProps
attribID:#(0x2116dbbc, 0x278662ed)
(
	parameters main
	(
		type type:#string
		active type:#boolean default:true

		folderName type:#string
		cameraEnable type:#boolean
		objectsEnable type:#boolean
		objectsList type:#stringTab tabSizeVariable:true
	)
)

-- Dabelow vray render elements
vrayRenderElementsPropsCA = attributes vrayRenderElementsProps
attribID:#(0x25058692, 0x1e340ec9)
(
	parameters main
	(
		type type:#string
		active type:#boolean default:true
 		-- initialized type:#boolean

		elementOverride type:#boolean
		activeElement type:#stringTab tabSizeVariable:true
	)
)

LPM_XrefSceneCA = attributes LPM_XrefScene
attribID:#(0x56140309, 0x010987480)
(
	parameters main
	(
		type type:#string
		active type:#boolean default:true
		fileNames type:#stringTab tabSizeVariable:true
		expanded type:#boolean
	)
)

LPM_XrefObjCA = attributes LPM_XrefObj
attribID:#(0x1d07f41c, 0x13eb8773)
(
	parameters main
	(
		type type:#string
		active type:#boolean default:true
		fileNames type:#stringTab tabSizeVariable:true
		expanded type:#boolean
	)
)

commonPropsCA= attributes commonProps
attribID:#(0x01028309, 0x03010930)
(
	parameters main
	(
		type type:#string
		props type:#stringTab tabSizeVariable:true
		initialized type:#boolean
		active type:#boolean default:true
		--Time output
		timeOutputTgl type:#boolean
		_rendTimeType type:#integer
		_rendNThFrame type:#integer
		_rendStart type:#time
		_rendEnd type:#time
		_rendFileNumberBase type:#integer
		_rendPickupFrames type:#string

		--Output
		outputSizeTgl type:#boolean
		_renderWidth type:#integer
		_renderHeight type:#integer
		_renderPixelAspect type:#float
		_RendApertureWidth type:#float

		--Options
		optionsTgl type:#boolean
		_rendAtmosphere type:#boolean
		_renderEffects type:#boolean
		_renderDisplacements type:#boolean
		_rendColorCheck type:#boolean
		_rendFieldRender type:#boolean
		_rendHidden type:#boolean
		_rendSimplifyAreaLights type:#boolean
		_rendForce2Side type:#boolean
		_rendSuperBlack type:#boolean


		--Advanced Lighting
		advancedLightingTgl type:#boolean
		_useAdvancedLighting type:#boolean
		_computeAdvancedLighting type:#boolean
		--Filetype
		fileTypeTgl type:#boolean
		_fileType type:#string

		--Gamma
		gammaTgl type:#boolean default:false
		_fileOutGamma type:#float default:1.0

		--Deep
		deepEXR type:#boolean default:false

		--Camera
		cameraTgl type:#boolean
		_Camera type:#node

		_CameraExport type:#boolean default:true


		--preScript
		usePreScript type:#boolean
		preScript type:#string
		usePostScript type:#boolean
		postScript type:#string

		--renderType
		rendertype type:#string default:"view"
		renderTypeTgl type:#boolean

		autoUpdateName type:#boolean default:true
		disableFinalOutput type:#boolean default:false

	)
)

envEffectCA = attributes envEffect
attribID:#(0x01020380, 0x03018300)
(
	parameters main
	(
		type type:#string
		initialized type:#boolean
		--render Element
		activeElement type:#stringTab tabSizeVariable:true
		elementOverride type:#boolean
		--atm nodes
		activeAtm type:#stringTab tabSizeVariable:true
		atmOverride type:#boolean
		--effect nodes
		effectOverride type:#boolean
		activeEffect type:#stringTab tabSizeVariable:true
		--bkg nodes
		backgroundOverride type:#boolean
		bgColor type:#color
		envMap type:#texturemap
		useEnvMap type:#boolean
		tint type:#color
		level type:#float
		ambient type:#color
		exposureOverride type:#boolean
		exposureInt type:#integer
		active type:#boolean default:true
	)
)

objectSetCA = attributes objectSet
attribID:#(0x84319010, 0x01920100)
(
	parameters main
	(
		type type:#string
		mats type:#stringTab tabSizeVariable:true
		layers type:#stringTab tabSizeVariable:true
		wildCard type:#stringTab tabSizeVariable:true
		namedSet type:#stringTab tabSizeVariable:true
		nodes type:#nodeTab tabSizeVariable:true
		--Properties--
		intP type:#intTab tabSizeVariable:true
		pMatEnable type:#boolean
		pMaterial type:#material
		expanded type:#boolean
		pColor type:#Color
		visible type:#integer default:1
		selectable type:#integer default:1
		userProp type:#string default:""
	)
)
lightSetCA = attributes lightSet
attribID:#(0x01828340, 0x02948239)
(
	parameters main
	(
		type type:#string
		mats type:#stringTab tabSizeVariable:true
		layers type:#stringTab tabSizeVariable:true
		nodes type:#nodeTab tabSizeVariable:true
		wildCard type:#stringTab tabSizeVariable:true
		namedSet type:#stringTab tabSizeVariable:true
		--Properties--
		pEnable type:#integer
		pMultiplierEnable type:#boolean
		pMultiplier type:#float
		pColorEnable type:#boolean
		pColor type:#Color

		pCastShadows type:#integer default:1
		pAffectDiffuse type:#integer default:1
		pAffectSpecular type:#integer default:1
		pAffectReflections type:#integer default:1
		pUseTexture type:#integer default:1

		pVrayInvisible type:#integer default:1

		pTextureEnable type:#boolean
		pTexture type:#texturemap


		expanded type:#boolean
	)
)


LPM_scriptCA = attributes LPM_ScriptDef
attribID:#(0x236b7a3b, 0x4be701be)
(
	parameters main
	(
		type type:#string
		active type:#boolean default:true
		script type:#string
		script2 type:#string default:""
		preLPM type:#boolean default:false
		postLPM type:#boolean default:false
		preRender type:#boolean default:true
		postRender type:#boolean default:false

		PostRenderFrameScript type:#boolean default:false
		PostRenderFrameScriptText type:#string default:""
	)
)

LPM_emptyCA = attributes LPM_emptyDef
attribID:#(0x236b7a31, 0x4be701b1)
(
	parameters main
	(
		type type:#string
	)
)

LPM_genericCA = attributes LPM_genericDef
attribID:#(0x426c7db3, 0x343c98d9)
(

	parameters main
	(
		type type:#string default:"generic"
		active type:#boolean default:true
		subType type:#String default:""
		keys type:#stringTab tabsizevariable:true
		dClass type:#stringTab tabsizevariable:true
		dValue type:#stringTab  tabsizevariable:true
		dMaxObject type:#maxobjecttab  tabsizevariable:true
		dNode type:#nodeTab tabsizevariable:true
	)
	fn __DeleteAll IKey=
	(
		IKey=toLower IKey
		i=1
		while(i<Keys.count) do
		(
			if(Keys[i]==LKey) then
			(
				deleteItem keys i
				deleteItem dClass i
				deleteItem dValue i
				deleteItem dMaxObject i
				deleteItem dNode i
			)
			else
				i+=1
		)

	)
	fn __AddItem IKey IVal=
	(
		IKey=toLower IKey

		p=(keys.count+1)

		--Initialize all arrays
		keys[p]=IKey
		dClass[p]=classof Ival as string
		dMaxObject[p]=undefined
		dNode[p]=undefined

		try
		(
			sc=superclassof IVal
			if (isvalidnode IVal) then
			(
				dValue[p]="__NODE__"
				dNode[p]=IVal
			)
			else if(sc==material) or (sc==textureMap) or(sc==positionController) then
			(
				dValue[p]=dValue[p]="__MAXOBJECT__"
				dMaxObject[p]=IVal
			)
			else if(superclassof sc)==Value then
			(
				dValue[p]=(IVal as string)
			)
			else
			(
				return false
			)

		)catch (messagebox ("Exception Caught in LPM_GenericDef"+(getcurrentexception as string())); return false)
		return true
	)
	fn __GetItem Ikey IDefault single:false=
	(
		IKey=toLower IKey
		col=for p=1 to keys.count where IKey==keys[p] collect
		(
			val=0
			if(dValue[p]=="__MAXOBJECT__") then
				val=dMaxObject[p]
			else if(dValue[p]=="__NODE__") then
				val=dNode[p]
			else
			(
				if(dClass[p]=="String") then
					val=dValue[p]
				else
					val=(execute (dValue[p]+" as "+dClass[p]))
			)
			if single then
				return val
			val
		)
		if(col.count==0) then
			return IDefault
		else
			return col

	)

	fn setValue IKey IVal =
	(
		__DeleteAll IKey
		__AddItem Ikey IVal
	)
	fn getValue IKey IDefault=
	(
		__GetItem IKey IDefault single:true
	)
	fn setArray IKey arrVal=
	(
		__DeleteAll IKey
		for it in arrVal where not (__AddItem Ikey it)do
		(
			return false
		)
		return true
	)
	fn getArray IKey IDefault=
	(
		__GetItem IKey IDefault single:false
	)
)

ModifierOverCA = attributes ModifierOver
attribID:#(0x46a023af, 0x761d5f73)
(
	parameters main
	(
		type type:#string default:"ModifierOver"
		initialized type:#boolean
		active type:#boolean default:true
		--active Modifiers
		activeModifiers type:#stringTab tabSizeVariable:true
		activeNode type:#node

	)
)

/*EXAMPLE
x=point()
a1=sphere()
b1=noise()
c1=9
d1="hello world!"
e1=99.99
f1=standardMaterial()
g1=noise_position()

custAttributes.add x LPM_genericCA
x.setValue "a1" a1
x.setValue "b1" b1
x.setValue "c1" c1
x.setValue "d1" d1
x.setValue "e1" e1
x.setValue "f1"  f1
x.setValue "g1" g1
x.getValue "a1" 0
x.getValue "b1" 0
x.getValue "c1" 0
x.getValue "d1" 0
x.getValue "e1" 0
x.getValue "f1" 0
x.getValue "g1" 0*/