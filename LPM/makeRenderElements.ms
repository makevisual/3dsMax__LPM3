
-- Designed for V-Ray 5.1 
-- Defines and creates default and templated render element passes.

struct elementsDefStr
(

	function element_DepthRGB = 
	(
		Falloff_texR = falloff()
		Falloff_texG = falloff()
		Falloff_texB = falloff()
		RGB_Composite = CompositeTextureMap()
		RGB_Composite.add()
		RGB_Composite.add()

	  	Falloff_texR.color1 					= (color 0 0 0)
	  	Falloff_texR.map1Amount 				= 100.0 
	  	Falloff_texR.map1On 				 	= true 
	  	Falloff_texR.color2 			 		= (color 255 0 0) 
	  	Falloff_texR.map2Amount 				= 100.0  
	  	Falloff_texR.map2On 				 	= true 
	  	Falloff_texR.type  						= 4 
	  	Falloff_texR.direction 					= 0 
	  	Falloff_texR.extrapolateOn 				= true 
	  	Falloff_texR.nearDistance  				= 0.0
	  	Falloff_texR.farDistance  				= 500.0

	  	Falloff_texG.color1 					= (color 0 0 0)
	  	Falloff_texG.map1Amount 				= 100.0 
	  	Falloff_texG.map1On 				 	= true 
	  	Falloff_texG.color2 			 		= (color 0 255 0) 
	  	Falloff_texG.map2Amount 				= 100.0  
	  	Falloff_texG.map2On 				 	= true 
	  	Falloff_texG.type  						= 4 
	  	Falloff_texG.direction 					= 0 
	  	Falloff_texG.extrapolateOn 				= true 
	  	Falloff_texG.nearDistance  				= 0.0
	  	Falloff_texG.farDistance  				= 5000.0

	  	Falloff_texB.color1 					= (color 0 0 0)
	  	Falloff_texB.map1Amount 				= 100.0 
	  	Falloff_texB.map1On 				 	= true 
	  	Falloff_texB.color2 			 		= (color 0 0 255) 
	  	Falloff_texB.map2Amount 				= 100.0  
	  	Falloff_texB.map2On 				 	= true 
	  	Falloff_texB.type  						= 4 
	  	Falloff_texB.direction 					= 0 
	  	Falloff_texB.extrapolateOn 				= true 
	  	Falloff_texB.nearDistance  				= 0.0
	  	Falloff_texB.farDistance  				= 50000.0

		RGB_Composite.mapList[1] = Falloff_texR
		RGB_Composite.mapList[2] = Falloff_texG
		RGB_Composite.mapList[3] = Falloff_texB

		RGB_Composite.blendMode[2] = 2
		RGB_Composite.blendMode[3] = 2

		newElement 								= VRayExtraTex()
		newElement.enabled 						= false
		newElement.filterOn 					= true
		newElement.elementName 					= "VRayDepthRGB"
		newElement.auto_update_name 			= false
		newElement.texture 						= RGB_Composite
		newElement.consider_for_antialiasing 	= false
		newElement.affect_matte_objects 		= false

		newElement.vrayVFB 						= false

		return newElement 
	),

	function element_VrayLightmix = 
	(
		newElement = VrayLightmix()

		newElement.enabled 			= false 
		newElement.elementName 		= "VrayLightmix" 
		newElement.vrayVFB 			= false 

		return newElement 
	),

	function element_VRayBackToBeauty = 
	(
		newElement = VRayBackToBeauty()

		newElement.enabled 			= false 
		newElement.elementName 		= "VRayBackToBeauty" 
		newElement.vrayVFB 			= false 

		return newElement 
	),

	function element_VRayDenoiser = 
	(
		newElement = VRayDenoiser()

		newElement.enabled 			= false 
		newElement.elementName 		= "VRayDenoiser" 
		newElement.vrayVFB 			= false 

		return newElement 
	),

	function element_VRayAO = 
	(
		newElement = VRayAO()

		newElement.enabled 			= false 
		newElement.elementName 		= "VRayAO" 
		newElement.vrayVFB 			= false 

		return newElement 
	),

	function element_VRaySampleRate = 
	(
		newElement = VRaySampleRate()

		newElement.enabled 			= false 
		newElement.elementName 		= "VRaySampleRate" 
		newElement.vrayVFB 			= false 

		return newElement 
	),

	function element_VRayCryptomatte = 
	(
		newElement = VRayCryptomatte()

		newElement.enabled 			= false 
		newElement.elementName 		= "VRayCryptomatte" 
		newElement.vrayVFB 			= false 
		newElement.id_type 			= 2

		return newElement 
	),

	function element_VRayOptionRe_Uncompressed = 
	(
		newElement = VRayOptionRE()

		newElement.enabled 						= false 
		newElement.elementName 					= "VRayOptionRe_Uncompressed" 
		newElement.vrayVFB 						= false 
		newElement.exr_compression 				= 0
		newElement.use_dwa_compression_level	= false
		newElement.dwa_compression_level 		= 45.0
		newElement.exr_multipart 				= true 
		newElement.exr_metadata					= ""

		return newElement 
	),

	function element_VRayOptionRe_Compressed = 
	(
		newElement = VRayOptionRE()

		newElement.enabled 						= false 
		newElement.elementName 					= "VRayOptionRE_Compressed" 
		newElement.vrayVFB 						= false 
		newElement.exr_compression 				= 9
		newElement.use_dwa_compression_level	= true
		newElement.dwa_compression_level 		= 45.0
		newElement.exr_multipart 				= true 
		newElement.exr_metadata					= ""

		return newElement 
	)
)

function sortByElementName arg_1 arg_2 = 
(
	stricmp arg_1.elementName arg_2.elementName  
)

function makeRenderElements =
(
	if not LPM_VRayInstalled then
	(
		if LPM_VerboseLogging do print "LPM makeRenderElements: V-Ray not installed -- skipping render element creation."
		return undefined
	)

	re = maxOps.GetCurRenderElementMgr()  					-- Get the render element manager
	existingElements = #()

	for i in 0 to ( re.NumRenderElements() - 1 ) do 		-- Get the current render elements
	(
		append existingElements ( re.GetRenderElement i )
	)

	elementsStr = elementsDefStr 							-- Instiantiate the elements definition struct
	elements 	= (getPropNames elementsStr)				-- Get a list of all the members of that struct
	newElements = #()

	for id in elements do 									-- go through the list of members of the struct
	(
		try(
			curElementFunction = (getProperty elementsStr id)	-- Retrive the function out of the struct
			curElement = ( curElementFunction() )				-- Execute the function, and assign it to curElement

			append newElements curElement
		)catch(print("LPM - Unable to create render element - "+(id as string)))
	)

	qsort newElements sortByElementName 					-- Alphabetize the names 

	for newElement in newElements do  -- Check to see if the element already exists, and if not, add it 
	(
		exists = false

		for existingElement in existingElements do 
		(
			if ( classof newElement ) == ( classof existingElement ) and newElement.elementName == existingElement.elementName
			then ( exists = true )
		)

		if exists == false
		then ( re.addrenderelement newElement )
	)
)

makeRenderElements()