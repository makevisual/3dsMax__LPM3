rollout aeExportPropsRoll "After Effects Export 1.0" width:225 height:130
(
	local theNode = undefined

	groupbox grp_folder "Output" width:213 height:50 align:#left offset:[-5,0] enabled:true
		edittext txt_folderName "Folder " width:195 offset:[0, ( ( grp_folder.height * -1 ) + 16 ) ]

	groupbox grp_include "Include" width:213 height:50 align:#left offset:[-5,10] enabled:true
		checkbox chk_cameraEnable "Camera"  offset:[5, ( ( grp_include.height * -1 ) + 18 ) ]
		checkbox chk_objectsEnable "Objects" offset:[5,0]

	function updateCA =
	(
		cp 		=LPM_treeview_rollout.tv.selectedNode.tag.value
		theNode = cp

		ca = custAttributes.get theNode 1

		ca.folderName 		= txt_folderName.text
		ca.cameraEnable 	= chk_cameraEnable.checked
		ca.objectsEnable 	= chk_objectsEnable.checked

		return ca
	)

	on chk_cameraEnable 	changed state do updateCA()
	on chk_objectsEnable 	changed state do updateCA()
	on txt_folderName 		changed txt   do updateCA()

	on aeExportPropsRoll open do
	(
		cp 		=LPM_treeview_rollout.tv.selectedNode.tag.value
		theNode = cp

		ca = custAttributes.get theNode 1

		txt_folderName.text 		= ca.folderName
		chk_cameraEnable.checked 	= ca.cameraEnable
		chk_objectsEnable.checked 	= ca.objectsEnable
	)

	on aeExportPropsRoll close do
	(
		updateCA()
		setFocus aeExportPropsRoll
		LPM_treeview_rollout.UnFreezeWindow()
	)
)

rcMenu rc_aeExportPropsMenu
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
		createDialog aeExportPropsRoll pos:(LPM_Fun.getRoPos  aeExportPropsRoll.width)
	)
)
