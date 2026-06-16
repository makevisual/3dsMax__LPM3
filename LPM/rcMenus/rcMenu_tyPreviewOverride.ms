rollout tyPreviewPropsRoll "TyPreview Options 1.0" width:225 height:95
(
	local theNode = undefined

	groupbox grp_viewport "Viewport Settings" width:213 height:60 align:#left offset:[-5,0]
		radiobuttons rdo_viewportSource "" labels:#("Use Active Viewport settings", "Use TyPreview viewport settings") offset:[5,-42] columns:1

	function updateCA =
	(
		-- Get the scene node for the operator
		cp 		= LPM_treeview_rollout.tv.selectedNode.tag.value
		theNode = cp

		ca = custAttributes.get theNode 1

		ca.viewportSource = rdo_viewportSource.state

		return ca
	)

	on rdo_viewportSource changed state do
	(
		updateCA()
	)

	-- event for rollout open
	on tyPreviewPropsRoll open do
	(
		cp 		= LPM_treeview_rollout.tv.selectedNode.tag.value
		theNode = cp

		ca = custAttributes.get theNode 1

		rdo_viewportSource.state = ca.viewportSource
	)

	on tyPreviewPropsRoll close do
	(
		updateCA()

		-- Refresh the tree label so the [viewport] suffix reflects the new choice
		try(LPM_treeview_rollout.tv.selectedNode.text = LPM_Fun.generateTyPreviewName theNode)catch()

		LPM_treeview_rollout.UnFreezeWindow()
	)
)

rcMenu rc_tyPreviewPropsMenu
(
	menuItem	editProps	"Edit"
	menuItem 	copyProps 	"Copy"
	menuItem   	removeProps "Remove"

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
		createDialog tyPreviewPropsRoll pos:(LPM_Fun.getRoPos  tyPreviewPropsRoll.width)
	)
)
