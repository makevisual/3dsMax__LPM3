-- Add reflectors category

		--create the pass
		thePass=LPM_Fun.createPass LPM_Root
 		thePass.name="LPM_Beauty"

		-- All Objects Off
		newSet=LPM_Fun.createObjectSet "All Objects"
		newSet.wildCard[1]="*"
		newSet.intp[1] = 3
 		newSet.parent=thePass

		-- Renderable Geo
		newSet=LPM_Fun.createObjectSet "Geo"
		newSet.intp[1] = 2
 		newSet.parent=thePass

		-- Mattes
		newSet=LPM_Fun.createObjectSet "Mattes"
		newSet.intp[1] = 2
 		newSet.parent=thePass

		newSet.userProp="
		VRay_Matte_Enable = True
		VRay_Secondary_Matte_Enable = false
		VRay_Matte_Alpha = -1.000000
		VRay_Matte_ReflectionAmount = 0
		"
		newSet.intP[9]=2

		-- Shadow Casters
		newSet=LPM_Fun.createObjectSet "ShadowCasters"
 		newSet.intp[1] = 2
  		newSet.intP[4] = 3 -- invisible to camera
 		newSet.parent=thePass

		-- Reflectors
		newSet=LPM_Fun.createObjectSet "Reflectors"
 		newSet.intp[1] = 2
 		newSet.intP[2] = 3 -- cast shadows off
 		newSet.intP[3] = 3 -- recieve shadows off
  		newSet.intP[4] = 3 -- invisible to camera
 		newSet.parent=thePass

-- 		---- Environment Operator
--		theSet=LPM_Fun.createVray6RenderElementsProps "vray6RenderElements"
--		theSet.parent=thePass

 		---- Environment Operator
		theSet=LPM_Fun.createVrayRenderElementsProps "vrayRenderElements"
		theSet.parent=thePass
		
		--All Lights Off
		newSet=LPM_Fun.createLightSet "All Lights"
		newSet.wildCard[1]="*"
		newSet.pEnable = 3
		newSet.parent=thePass

		--Renderable Lights
		newSet=LPM_Fun.createLightSet "Lights"
		newSet.pEnable = 2
		newSet.parent=thePass

		LPM_treeview_rollout.updateTV()