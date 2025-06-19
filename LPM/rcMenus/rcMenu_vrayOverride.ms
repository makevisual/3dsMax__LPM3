rollout vrayPropsRoll "test Vray Overrides 1.1" width:370
(
	local theNode = undefined
	
	group "Quality Control"
	(
		radiobuttons qualityType labels:#("Final/Preview", "Final Only", "Preview Only" ) align:#center default:1
	)
	group "Vray Control"
	(		
		checkbox global_switches_check "" pos:[12,70] width:10
			groupbox grp1 "Global switches" width:325 height:45 offset:[20,-25] 
			checkbox displacement "Displacement" offset:[40,-grp1.height + 15] checked:true
			checkbox reflrefr "Reflect/Refract" offset:[150,-20] checked:true
		
		checkbox anti_aliasing_check "" pos:[12,grp1.pos.y + grp1.height + 5] width:10
			groupbox grp2 "Anti Aliasing" width:325 height:65 offset:[20,-25]
			spinner AAmin "Min subdivs:  " range:[1,100,1] type:#integer width:60 align:#left offset:[41, -grp2.height + 15] scale:.1
			spinner AAmax "Max subdivs: " range:[1,100,4] type:#integer width:60 align:#left offset:[40, 0] scale:.1
			
		checkbox GI_illum_check "" pos:[12, grp2.pos.y + grp2.height + 5] width:10
			groupbox grp21 "Indirect Illumination" width:325 height:45 offset:[20,-25]
			checkbox giOn "On" offset:[40,-grp21.height + 15] checked:false
		
		checkbox GI_check "" pos:[12,grp21.pos.y + grp21.height + 5] width:10
			groupbox grp3 "Environment" width:325 height:135 offset:[20,-25] 
				groupbox giGrp1 "Environment (skylight) override" width:310 height:55 offset:[30, -grp3.height + 10] 
					checkbox giSkylightOn "On" offset:[40, -giGrp1.height + 15] checked:true
					colorpicker giSkylightCol offset:[75, -20] height:17 width:25 color:(color 205 230 255) 
					spinner giSkylightMult "Multiplier: " type:#float range:[0,1,1] align:#left width:60 offset:[105,-22] 
					mapbutton giSkylightMap "None" align:#left height:17 width:110 offset:[207,-30]		
					button giSkylightMapSend "to M.E." align:#left width:50 offset:[207,0] height:18
					button giSkylightMapGet "from M.E." align:#left width:55 offset:[262,-23] height:18
					checkbox giSkylightMapCheck "" width:10 align:#left offset:[322, -45] checked:true
		
				groupbox giGrp2 "Reflection/Refraction environment override" width:310 height:55 offset:[30, -grp3.height + 165] 
					checkbox giRefOn "On" offset:[40, -giGrp1.height + 15] checked:true
					colorpicker giRefCol offset:[75, -20] height:17 width:25 color:(color 0 0 0) 
					spinner giRefMult "Multiplier: " type:#float range:[0,1,1] align:#left width:60 offset:[105,-22] 
					mapbutton giRefMap "None" align:#left height:17 width:110 offset:[207,-30]
					button giRefMapSend "to M.E." align:#left width:50 offset:[207,0] height:18
					button giRefMapGet "from M.E." align:#left width:55 offset:[262,-23] height:18					
					checkbox giRefMapCheck "" width:10 align:#left offset:[322, -45] checked:true
					
		
		checkbox moblur_check "" pos:[12, grp3.pos.y + grp3.height + 5] width:10
			groupbox grp4 "Motion Blur" width:325 height:45 offset:[20,-25]
			checkbox moblurOn "On" offset:[40,-grp4.height + 15] checked:true
			spinner moblurSubdivs "Subdivs: " range:[1,64,6] type:#integer width:60 align:#left offset:[90, -20] 
		
		checkbox prog_check "" pos:[12,grp4.pos.y + grp4.height + 5] width:10
			groupbox grp5 "Progressive Sampler" width:325 height:50 offset:[20,-25]
			spinner progMaxSubdiv "Max. subdivs: " range:[0,1000,20] type:#integer width:85 align:#left offset:[41, -grp4.height + 15]
			spinner progTime "Render time (min): " range:[0,100,1] type:#float width:75 align:#left offset:[190, -20] 

		checkbox dmc_check "" pos:[12,grp5.pos.y + grp5.height + 5] width:10
			groupbox grp6 "DMC Sampler" width:325 height:50 offset:[20,-25] 
			spinner dmcThresh "Noise Threshold: " range:[0,1,.01] type:#float width:85 align:#left offset:[41, -grp5.height + 15]
			spinner dmcMult "Global subdivs mult: " range:[0,100,1] type:#float width:75 align:#left offset:[190, -20] 
			
			
		label null pos:[12, grp6.pos.y + grp6.height - 10]
	)
	
	
	fn toggleState = 
	(
		state = global_switches_check.checked
			grp1.enabled = state
			displacement.enabled = state
			reflrefr.enabled = state
		
		state = anti_aliasing_check.checked
			grp2.enabled = state
			AAmin.enabled = state
			AAmax.enabled = state
		
		state = GI_illum_check.checked
			grp21.enabled = state
			gion.enabled = state
		
		state = GI_check.checked
			grp3.enabled = state
			giGrp1.enabled = state
			giGrp2.enabled = state
			giSkylightOn.enabled = state
			giRefOn.enabled = state
				state = giSkylightOn.checked and giSkylightOn.enabled
					giSkylightCol.enabled = state
					giSkylightMult.enabled = state
					giSkylightMap.enabled = state
					giSkylightMapCheck.enabled = state
					giSkylightMapSend.enabled = state
					giSkylightMapGet.enabled = state
				state = giRefOn.Checked and giRefOn.enabled
					giRefCol.enabled = state
					giRefMult.enabled = state
					giRefMap.enabled = state
					giRefMapCheck.enabled = state
					giRefMapSend.enabled = state
					giRefMapGet.enabled = state
					
		state = moblur_check.checked
			grp4.enabled = state
			moblurOn.enabled = state
			state = moblurOn.checked
				moblurSubdivs.enabled = state
				
		state = prog_check.checked
			grp5.enabled = state
			progMaxSubdiv.enabled = state
			progTime.enabled = state

		state = dmc_check.checked
			grp6.enabled = state
			dmcThresh.enabled = state
			dmcMult.enabled = state
	)
	
	on giSkylightMapSend pressed do
	(
		if giSkylightMap.map != undefined then
		(
			MatEditor.open()
			meditmaterials[1] = giSkylightMap.map
		)
	)
	on giRefMapSend pressed do
	(
		if giRefMap.map != undefined then
		(
			MatEditor.open()
			meditmaterials[1] = giRefMap.map
		)
	)
	on giSkylightMapGet pressed do
	(
		if iskindof meditmaterials[1] texturemap then
		(
			MatEditor.open()
			giSkylightMap.map = meditmaterials[1]
		)
	)
	on giRefMapGet pressed do
	(
		if iskindof meditmaterials[1] texturemap then
		(
			MatEditor.open()
			giRefMap.map = meditmaterials[1]
		)
	)
	
	on global_switches_check changed val do togglestate()
	on anti_aliasing_check changed val do togglestate()
	on GI_illum_check changed val do togglestate()
	on GI_check changed val do togglestate()
	on giSkylightOn changed val do togglestate()
	on giRefOn changed val do togglestate()
		
	on moblur_check changed val do togglestate()
		on moblurOn changed val do togglestate()
	
	on dmc_check changed val do togglestate()
	on prog_check changed val do togglestate()
	
	on giSkylightMap picked texmap do
	(
		giSkylightMap.map = texmap
	)
	
	on giRefMap picked texmap do
	(
		giRefMap.map = texmap
	)
	
	
	on vrayPropsRoll open do
	(		
		LPM_treeview_rollout.tv.enabled=false
		cp=LPM_treeview_rollout.tv.selectedNode.tag.value
		theNode=LPM_treeview_rollout.tv.selectedNode
		
		qualityType.state = cp.qualityType
		
		global_switches_check.state = cp.global_switches_check
			displacement.state = cp.displacement
			reflrefr.state = cp.reflrefr
		
		anti_aliasing_check.state = cp.anti_aliasing_check
			AAmin.value = cp.AAmin
			AAmax.value = cp.AAmax
		
		GI_illum_check.state = cp.GI_illum_check
			giOn.state = cp.giOn
		
		GI_check.state = cp.GI_check
			giSkylightOn.state = cp.giSkylightOn
			giSkylightMap.map = cp.giSkylightMap
			giSkylightMult.value = cp.giSkylightMult
			giSkylightCol.color = cp.giSkylightCol
			giSkylightMapCheck.state = cp.giSkylightMapCheck
		
			giRefOn.state = cp.giRefOn
			giRefMap.map = cp.giRefMap
			giRefMult.value = cp.giRefMult
			giRefCol.color = cp.giRefCol
			giRefMapCheck.state = cp.giRefMapCheck
			
		moblur_check.state = cp.moblur_check
			moblurOn.state = cp.moblurOn
			moblurSubdivs.value = cp.moblurSubdivs

  		prog_check.state = cp.prog_check
  			progMaxSubdiv.value = cp.progMaxSubdiv
  			progTime.value = cp.progTime
			
		dmc_check.state = cp.dmc_check
			dmcThresh.value = cp.dmcThresh
			dmcMult.value = cp.dmcMult
			
		
		toggleState()
	)
	
	on vrayPropsRoll close do
	(
		setFocus vrayPropsRoll
		cp=theNode.tag.value
		
		cp.qualityType = qualityType.state
		
		cp.global_switches_check = global_switches_check.state
		cp.displacement = displacement.state 
		cp.reflrefr = reflrefr.state
		
		cp.anti_aliasing_check = anti_aliasing_check.state
		cp.AAmin = AAmin.value
		cp.AAmax = AAmax.value 
		
		cp.GI_illum_check = GI_illum_check.state
			cp.giOn = giOn.state
		
		cp.GI_check = GI_check.state
		cp.giSkylightOn = giSkylightOn.state
		cp.giSkylightMap = giSkylightMap.map
		cp.giSkylightCol = giSkylightCol.color
		cp.giSkylightMult = giSkylightMult.value
		cp.giSkylightMapCheck = giSkylightMapCheck.state
		
		cp.giRefOn = giRefOn.state
		cp.giRefMult = giRefMult.value
		cp.giRefMap = giRefMap.map
		cp.giRefCol = giRefCol.color
		cp.giRefMapCheck = giRefMapCheck.state
			
		cp.moblur_check = moblur_check.state
		cp.moblurOn = moblurOn.state
		cp.moblurSubdivs = moblurSubdivs.value

 		cp.prog_check = prog_check.state
 		cp.progMaxSubdiv = progMaxSubdiv.value
 		cp.progTime = progTime.value
			
		cp.dmc_check = dmc_check.state
		cp.dmcThresh = dmcThresh.value
		cp.dmcMult = dmcMult.value
					
		theNode.text=LPM_Fun.generateVrayPropName cp
		
		LPM_treeview_rollout.tv.enabled=true
	)
)

rcMenu rc_vrayPropsMenu
(
	menuItem	editProps	"Edit"
	menuItem copyProps "Copy"
	menuItem   removeProps "Remove"
	
	on copyProps picked do
	(
		LPM_treeview_rollout.copyNode=LPM_treeview_rollout.tv.selectedNode.tag.value
	)
	
	on removeProps picked do
	(
		theNode=LPM_treeview_rollout.tv.selectedNode.tag.value
		delete theNode
		LPM_treeview_rollout.tv.selectedNode.remove()
	)
	on editProps picked do
	(		
		createDialog vrayPropsRoll pos:(LPM_Fun.getRoPos  vrayPropsRoll.width)
	)
	
)
