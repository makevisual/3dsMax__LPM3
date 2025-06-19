
macroscript LPM category:"MAKE" icon:#("LPM",1)
(
	filein "$MAX/scripts/LPM/include.ms"
)


--render preview macro script
macroscript LPM_RenderPass category:"MAKE" icon:#("LPM_100",1) tooltip:"Renders the Active Pass, defaults to max render when a pass is not found."
(

	if(isvalidnode LPM_activePass) then
	(
			LPM_renderPass LPM_activePass #preview
	)
	else
	(
		if isvalidnode $LPM_Root then
		(
			filein "$MAX/scripts/LPM/include.ms"
		)
		else
			max quick render
	)
	
)

--render previewHalf macro script
macroscript LPM_RenderPassHalf category:"MAKE" icon:#("LPM_50",1) tooltip:"Renders the Active Pass at half resolution, defaults to max render when a pass is not found."
(

	if(isvalidnode LPM_activePass) then
	(
		LPM_renderPass LPM_activePass #previewHalf
	)
	else
	(
		if isvalidnode $LPM_Root then
		(
			filein "$MAX/scripts/LPM/include.ms"
		)
		else
			max quick render
	)
)

