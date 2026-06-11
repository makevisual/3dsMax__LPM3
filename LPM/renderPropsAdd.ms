		thePassNode=LPM_activeElement
		thePass=LPM_activePass
		
		if((LPM_Fun.firstChildByType thePass "renderProps")==undefined)and(thePassNode!=undefined) then
		(
			theProps=LPM_Fun.createNode "Render Override" "renderProps"
			theProps.parent=thePassNode.tag.value
				
			LPM_treeview_rollout.addPassTV thePassNode
			tvRoot=LPM_Treeview_Rollout.tvRoot
			--Find and reselect the node
			for i=0 to (tvRoot.nodes.count-1) do
			(
				newNode=tvRoot.nodes.item[i]
				for j=0 to (newNode.nodes.count-1) do
				if(newNode.nodes.item[j].tag.value==theProps) then
				(	
					LPM_Treeview_Rollout.tv.selectedNode=newNode.nodes.item[j]
				)
			)
			
		    LPM_treeview_rollout.tv.enabled=false
			
			rollout LPM_rendererPicker "Pick a Render Type" width:200
			(
				listbox renderPicker height:15 width:190 pos:[5,5]
				local renderTypes=#()
				on LPM_rendererPicker close do
				(
					renderSceneDialog.close()
					LPM_oldRenderSettings=LPM_Fun.saveRenderPreset() 
					LPM_oldRenderSettingsNew=LPM_Fun.saveRenderPresetNew() 
					
					renderers.current=renderTypes[renderPicker.selection]()
					renderSceneDialog.open()
					
					tabbedDialogs.setCurrentPage #render #(1126448576, 479530250)
					
					callbacks.addScript #tabbedDialogDeleted "LPM_rendererClosed()" id:#myscript_update
				)
				on renderPicker doubleClicked item do
				(
					destroyDialog LPM_rendererPicker
				)
				on LPM_rendererPicker open do 
				(	
					renderTypes=for it in RendererClass.classes  where (it!= RLF_Network_Renderer) and (it!=Missing_Renderer) collect it
					renderPicker.items=for it in renderTypes collect (it as string)
				)
			)
			createDialog LPM_rendererPicker pos:(LPM_Fun.GetRoPos LPM_rendererPicker.width)
		)