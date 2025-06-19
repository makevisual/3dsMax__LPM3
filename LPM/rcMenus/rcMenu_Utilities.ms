global utilityCurProps

struct UtilityTools_Def 
(
	function makeCurProps =
	(
		struct curPropsStr
		(
			node,
			radius,
			falloff,
			subdivs,
	  		extrapolateOn,
	  		nearDistance,
	  		farDistance
	  	)

	  	result = curPropsStr()
	  	return result
	)

--	function rollout_setAOprops_Function =
--	(
--		rollout rollout_setAOprops "AO Settings" width:200 height:110
--		(
--			groupbox grp1 "AO Settings" pos:[10,5] width:(rollout_setAOprops.width - 20) height:95
--
--			spinner spn_radius 			"Radius"		type:#float range:[0.0,100000,500] offset:[ ( - 5 ) , ( ( grp1.height * -1 ) + 20) ] enabled:false
--			spinner spn_falloff 		"Falloff" 		type:#float range:[0.0,1.0,0.3]  offset:[ ( - 5 ) , 0 ] enabled:false
--			spinner spn_subdivs		 	"Subdivisions" 	type:#integer range:[1,256,16]	offset:[ ( - 5 ) , 0 ] enabled:false
--
--			on rollout_setAOprops open do 
--			(
--				re = maxOps.GetCurRenderElementMgr()  					-- Get the render element manager
--				existingElements = #()
--
--				for i in 0 to ( re.NumRenderElements() - 1 ) do 		-- Get the current render elements
--				(
--					append existingElements ( re.GetRenderElement i )
--				)
--
--				utilityCurProps.node = undefined
--
--				for existingElement in existingElements do 
--				(
--					if VRayExtraTex == ( classof existingElement ) and "VRayAO" == existingElement.elementName
--					then ( utilityCurProps.node = existingElement )
--				)
--
--				if utilityCurProps.node != undefined
--				then 
--				(
--					utilityCurProps.radius 		= utilityCurProps.node.texture.radius
--					utilityCurProps.falloff 	= utilityCurProps.node.texture.falloff
--					utilityCurProps.subdivs 	= utilityCurProps.node.texture.subdivs
--
--					spn_radius.enabled  = true
--					spn_falloff.enabled = true
--					spn_subdivs.enabled = true
--
--					spn_radius.value 	= utilityCurProps.radius
--					spn_falloff.value 	= utilityCurProps.falloff
--					spn_subdivs.value 	= utilityCurProps.subdivs
--				)
--			)
--
--			on rollout_setAOprops close do 
--			(
--				utilityCurProps.node.texture.radius 	= utilityCurProps.radius 
--				utilityCurProps.node.texture.falloff 	= utilityCurProps.falloff
--				utilityCurProps.node.texture.subdivs 	= utilityCurProps.subdivs
--			)
--
--			on spn_radius changed arg 	do ( utilityCurProps.radius 	= arg )
--			on spn_falloff changed arg 	do ( utilityCurProps.falloff 	= arg )
--			on spn_subdivs changed arg 	do ( utilityCurProps.subdivs 	= arg )
--		)
--
--		createDialog rollout_setAOprops lockHeight:false style:#(#style_titlebar,#style_border, #style_sysmenu,#style_resizing,#style_minimizebox)
--	)
)

utilityTools 	= UtilityTools_Def
utilityCurProps = utilityTools.makeCurProps()