		-- create the pass
		thePass=LPM_Fun.createPass LPM_Root
 		thePass.name="LPM_ReflectionDark"

		-- All Objects Off
		newSet=LPM_Fun.createObjectSet "All Objects"
		newSet.wildCard[1]="*"
		newSet.intp[1] = 3
 		newSet.parent=thePass

		-- Reflections
		newSet=LPM_Fun.createObjectSet "Reflections"
		newSet.intp[1] = 2
 		newSet.parent=thePass

		newMat = vrayMtl()
			newMat.diffuse = (color 0 0 0 )
			newMat.reflection_glossiness = .9
			newMat.reflection_subdivs = 32
			newFalloff = falloff()
			newMat.texmap_reflection = newFalloff
			newMat.option_cutOff = 0.0
			newMat.reflection_fresnel = false
			newMat.reflection_lockGlossiness = false

		newSet.pMatEnable = true
		newSet.pMaterial = newMat

		-- Reflected Objects
		newSet=LPM_Fun.createObjectSet "Objects"
 		newSet.intp[1] = 2
  		newSet.intP[4] = 3 -- invisible to camera
 		newSet.parent=thePass

		--All Lights Off
		newSet=LPM_Fun.createLightSet "All Lights"
		newSet.wildCard[1]="*"
		newSet.pEnable = 3
		newSet.parent=thePass

		--Renderable Lights
		newSet=LPM_Fun.createLightSet "Lights"
		newSet.pEnable = 2
		newSet.pAffectReflections=3 -- no reflection by lights
		newSet.parent=thePass

		LPM_treeview_rollout.updateTV()