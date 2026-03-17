		--create the pass
		thePass=LPM_Fun.createPass LPM_Root
 		thePass.name="LPM_Shadow"

		-- All Objects Off
		newSet=LPM_Fun.createObjectSet "All Objects"
		newSet.wildCard[1]="*"
		newSet.intp[1] = 3
 		newSet.parent=thePass

		-- Shadows
		newSet=LPM_Fun.createObjectSet "Shadows"
		newSet.intp[1] = 2
 		newSet.parent=thePass

		newSet.userProp="
		VRay_Matte_Enable = True
		VRay_Secondary_Matte_Enable = True
		VRay_Matte_Alpha = -1.000000
		VRay_Matte_Shadows = True
		VRay_Matte_ShadowAlpha = True
		VRay_Matte_ShadowColor = [0,0,0]
		"
		newSet.intP[9]=2

		-- Shadow Casters
		newSet=LPM_Fun.createObjectSet "ShadowCasters"
 		newSet.intp[1] = 2
  		newSet.intP[4] = 3 -- invisible to camera
 		newSet.parent=thePass

		-- Mattes
		newSet=LPM_Fun.createObjectSet "Mattes"
		newSet.intp[1] = 2
 		newSet.parent=thePass

		newSet.userProp="
		VRay_Matte_Enable = True
		VRay_Secondary_Matte_Enable = True
		VRay_Matte_Alpha = -1.000000
		"
		newSet.intP[9]=2
	
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