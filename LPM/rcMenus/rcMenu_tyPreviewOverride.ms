rollout tyPreviewPropsRoll "TyPreview Options 1.0" width:235 height:185
(
	local theNode = undefined

	-- Image-sequence formats first (default exr), then mp4 video. Alpha is auto-enabled for
	-- formats that support it (exr / png / tif).
	local formatList = #("exr", "png", "tif", "jpg", "mp4")

	groupbox grp_viewport "Viewport Settings" width:213 height:60 align:#left offset:[-5,0]
		radiobuttons rdo_viewportSource "" labels:#("Use Active Viewport settings", "Use TyPreview viewport settings") offset:[-15,-42] columns:1

	groupbox grp_output "Output" width:213 height:105 align:#left offset:[-5,5]
		-- +35 (was +15) compensates the taller groupbox so the dropdown keeps its position.
		dropdownlist ddl_outputFormat "" items:formatList width:190 offset:[5,((grp_output.height * -1) +15)] align:#left
		label lab_alpha "" offset:[5,-5] align:#left
		-- mp4 only: write the container beside the shot folder named "<shot>_<pass>".
		checkbox chk_disableNesting "Disable nesting of .mp4 files" offset:[5,2] align:#left
		-- Image sequences only: rename frames from "<name>_####" to "<name>.####" after export.
		checkbox chk_forceDotDelimiter "Force frame delimiter to \".\"  (seq.)" offset:[5,2] align:#left

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
		ca.forceDotDelimiter = chk_forceDotDelimiter.checked

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

	on chk_disableNesting changed state do
	(
		updateCA()
	)

	on chk_forceDotDelimiter changed state do
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

		local fmtIdx = findItem formatList ca.outputFormat
		if (fmtIdx == 0) then fmtIdx = 1		-- fall back to exr if stored value is unrecognised
		ddl_outputFormat.selection = fmtIdx
		updateAlphaLabel ddl_outputFormat.selected

		chk_disableNesting.checked = ca.disableContainerNesting
		chk_forceDotDelimiter.checked = ca.forceDotDelimiter
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

-- createDialog tyPreviewPropsRoll pos:(LPM_Fun.getRoPos  tyPreviewPropsRoll.width)