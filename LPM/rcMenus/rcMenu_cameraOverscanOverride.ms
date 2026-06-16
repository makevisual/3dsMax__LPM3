rollout cameraOverscanPropsRoll "Camera Overscan Override 1.0" width:225 height:130
(
	local theNode = undefined

	groupbox grp_overscanAmmount "Oversan / Underscan Ammount" width:213 height:50 slign:#left offset:[-5,0] enabled:true--false
		spinner spn_overscanAmmount "" range:[0.1,2.0,1.1] offset:[0, ( ( grp_overscanAmmount.height * -1 ) + 14 ) ]

	groupbox grp_resolution "Effect Resolution " width:213 height:65 slign:#left offset:[-5,15] enabled:true--false
		checkbox chk_effectResolution "" range:[1.0,2.0,1.1] offset:[5, ( ( grp_resolution.height * -1 ) + 18 ) ]
		label lab_resolutionCurrent "current: 1920 x 1080" offset:[0,-20] align:#right enabled:false
		label lab_resolutionOverscanned "overscanned: 2112 x 1188" offset:[0,0] align:#right enabled:false

	function updateCA = 
	(
		-- Get the scene node for the element operator
		cp 		=LPM_treeview_rollout.tv.selectedNode.tag.value
		theNode = cp

		ca = custAttributes.get theNode 1

		ca.fovOverride = spn_overscanAmmount.value
	    ca.resOverride = chk_effectResolution.checked
    	ca.resXOverride = ( renderWidth * spn_overscanAmmount.value )
    	ca.resYOverride = ( renderHeight * spn_overscanAmmount.value )

		-- show ca
	
    	return ca 
	)

	function updateResolution =
	(
		ca = updateCA()

		lab_resolutionCurrent.text = ( "current: " + ( renderWidth as string ) + " x " + ( renderHeight as string ) )
		lab_resolutionOverscanned.text = ( "overscanned: " + ( ( ca.resXOverride as integer ) as string ) + " x " + ( ( ca.resYOverride as integer ) as string ) )

		lab_resolutionCurrent.enabled = ca.resOverride
		lab_resolutionOverscanned.enabled = ca.resOverride
	)

	on chk_effectResolution changed state do 
	(
		updateResolution()
	)

	on spn_overscanAmmount changed state do 
	(
		updateResolution()
	)

	-- event for rollout open 
	on cameraOverscanPropsRoll open do
	(
		cp 		=LPM_treeview_rollout.tv.selectedNode.tag.value
		theNode = cp

		ca = custAttributes.get theNode 1

		spn_overscanAmmount.value 			=ca.fovOverride 
		chk_effectResolution.checked 		=ca.resOverride 
		updateResolution()	
 	)
	
	on cameraOverscanPropsRoll close do
	(

		updateCA()
	
		setFocus cameraOverscanPropsRoll

		-- TODO: having issues updating the name in LPM_Fun.generateCameraOverscanName, so it is just set to static for now

		-- cp  	=theNode.tag.value
		-- cp 		=LPM_treeview_rollout.tv.selectedNode.tag.value
		-- show cp
		-- 
		-- show theNode

		--theNode.text = LPM_Fun.generateCameraOverscanName cp

		--LPM_Fun.generateCameraOverscanName cp
		--LPM_treeview_rollout.tv.enabled=true

		----theNode.text=LPM_Fun.generateCommonPropName cp
 		--LPM_Fun.generateCameraOverscanName theNode

		LPM_treeview_rollout.UnFreezeWindow()

	)
)

rcMenu rc_CameraOverscanPropsMenu
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
		createDialog cameraOverscanPropsRoll pos:(LPM_Fun.getRoPos  cameraOverscanPropsRoll.width)
	)
)
--createDialog cameraOverscanPropsRoll pos:(LPM_Fun.getRoPos  cameraOverscanPropsRoll.width)