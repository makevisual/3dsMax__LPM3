renderSceneDialog.close()
	
try
(
	if(LPM_treeview_rollout.tv.selectedNode.tag.value.propsAlternate != "")then
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

if(LPM_treeview_rollout.tv.selectedNode.tag.value.initialized)then
(	
	try
	(
		if LPM_treeview_rollout.tv.selectedNode.tag.value.propsAlternate != "" then
		(
			LPM_Fun.loadRenderPresetNew LPM_treeview_rollout.tv.selectedNode.tag.value.propsAlternate
		)
		else
		(
			LPM_Fun.loadRenderPreset LPM_treeview_rollout.tv.selectedNode.tag.value.props
		)
	)
	catch
	(
		LPM_Fun.loadRenderPreset LPM_treeview_rollout.tv.selectedNode.tag.value.props
	)
	
)

renderSceneDialog.open()

if(classof renderers.current)==mental_ray_renderer then
(
	tabbedDialogs.setCurrentPage #render #(188154248, 1489465121)
)
else
(
	tabbedDialogs.setCurrentPage #render #(1126448576, 479530250)
)
LPM_treeview_rollout.FreezeWindow()

callbacks.addScript #tabbedDialogDeleted "LPM_renderer_closed()" id:#myscript_update
