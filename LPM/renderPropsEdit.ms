renderSceneDialog.close()
	
try
(
	if(LPM_treeviewRollout.tv.selectedNode.tag.value.propsAlternate != "")then
	(
		LPM_oldRenderSettingsNew=LPM_Fun.saveRenderPresetNew()
	)
	else
	(
		LPM_oldRenderSettings=LPM_Fun.saveRenderPreset() 
	)
)
catch
(
	LPM_oldRenderSettings=LPM_Fun.saveRenderPreset() 
)

if(LPM_treeviewRollout.tv.selectedNode.tag.value.initialized)then
(	
	try
	(
		if LPM_treeviewRollout.tv.selectedNode.tag.value.propsAlternate != "" then
		(
			LPM_Fun.loadRenderPresetNew LPM_treeviewRollout.tv.selectedNode.tag.value.propsAlternate
		)
		else
		(
			LPM_Fun.loadRenderPreset LPM_treeviewRollout.tv.selectedNode.tag.value.props
		)
	)
	catch
	(
		LPM_Fun.loadRenderPreset LPM_treeviewRollout.tv.selectedNode.tag.value.props
	)
	
)

renderSceneDialog.open()

tabbedDialogs.setCurrentPage #render #(1126448576, 479530250)
LPM_treeviewRollout.FreezeWindow()

callbacks.addScript #tabbedDialogDeleted "LPM_rendererClosed()" id:#myscript_update
