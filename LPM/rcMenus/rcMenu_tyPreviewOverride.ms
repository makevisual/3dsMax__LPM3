rollout tyPreviewPropsRoll "TyPreview Options 1.0" width:225 height:195
(
	local theNode = undefined

	-- Image-sequence formats first (default exr), then mp4 video. Alpha is auto-enabled for
	-- formats that support it (exr / png / tif).
	local formatList = #("exr", "png", "tif", "jpg", "mp4")

	groupbox grp_viewport "Viewport Settings" width:213 height:60 align:#left offset:[-5,0]
		radiobuttons rdo_viewportSource "" labels:#("Use Active Viewport settings", "Use TyPreview viewport settings") offset:[5,-42] columns:1

	groupbox grp_output "Output Format" width:213 height:75 align:#left offset:[-5,5]
		dropdownlist ddl_outputFormat "" items:formatList width:120 offset:[5,-32] align:#left
		label lab_alpha "" offset:[5,-2] align:#left
		-- mp4 only: write the container beside the shot folder named "<shot>_<pass>".
		checkbox chk_disableNesting "Disable nesting of container files" offset:[5,2] align:#left

	function fnFormatSupportsAlpha fmt =
	(
		(fmt == "exr") or (fmt == "png") or (fmt == "tif")
	)

	function updateAlphaLabel fmt =
	(
		if (fnFormatSupportsAlpha fmt)
		then ( lab_alpha.text = "Alpha: included" )
		else ( lab_alpha.text = "Alpha: not supported by this format" )
	)

	function updateCA =
	(
		-- Get the scene node for the operator
		cp 		= LPM_treeview_rollout.tv.selectedNode.tag.value
		theNode = cp

		ca = custAttributes.get theNode 1

		ca.viewportSource = rdo_viewportSource.state
		ca.outputFormat = ddl_outputFormat.selected
		ca.disableContainerNesting = chk_disableNesting.checked

		return ca
	)

	on rdo_viewportSource changed state do
	(
		updateCA()
	)

	on ddl_outputFormat selected i do
	(
		updateAlphaLabel ddl_outputFormat.selected
		updateCA()
	)

	-- event for rollout open
	on tyPreviewPropsRoll open do
	(
		cp 		= LPM_treeview_rollout.tv.selectedNode.tag.value
		theNode = cp

		ca = custAttributes.get theNode 1

		rdo_viewportSource.state = ca.viewportSource

		local fmtIdx = findItem formatList ca.outputFormat
		if (fmtIdx == 0) then fmtIdx = 1		-- fall back to exr if stored value is unrecognised
		ddl_outputFormat.selection = fmtIdx
		updateAlphaLabel ddl_outputFormat.selected

		chk_disableNesting.checked = ca.disableContainerNesting
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
