-- Dear whoever reads this, I inherited this pile of globals, and wish it was not this way, it keeps me up at night.
-- I added a couple of my own, to be able to pass things between areas of the program out of shame, and confusion.
-- I at least was able to add LPM_ to the beginning of almost all of them, so they were not so egregious. - Aaron Dabelow

global LPM_renderAPI
global LPM_NetworkPlugins=#()
global LPM_Fun
global LPM_FunDeadline
global LPM_Root
global LPM_treeview_rollout
global LPM_RenderRo
global LPM_multiCameraRo
global LPM_RenderPass
global LPM_Data
global LPM_Render
global LPM_atmRollout
global LPM_objectSetProps
global lightSetProps 						-- Difficult to change name, used as class and constructor, I gave up trying to fix -- Dabelow
global LPM_commonRollout
global LPM_activePass
global LPM_LoadingPreset
global LPM_Operators
global LPM_activeElement
global LPM_doubleClick 
global LPM_oldRenderSettings
global LPM_oldRenderSettingsNew
global LPM_renderer_closed
global LPM_ObjSetPropsBuff
global LPM_LightSetPropsBuff
global LPM_iconPath = LPM_Dir + "icons/"
global LPM_disabledIconFolder = "blacks"
global LPM_BackColor 					
global LPM_FontColor
global LPM_ContinueLoad

global LPM_IdiotChecksEnabled 				-- Dabelow	
global LPM_VersionNumber 					-- Dabelow	
global LPM_SMTDSettings 					-- Dabelow
global LPM_NukeAPI 							-- Dabelow
global LPM_RenderDispatchThePass 			-- Dabelow Render Dispatch ( future renderer compatable )
global LPM_RenderDispatchTheShot 			-- Dabelow Render Dispatch ( future renderer compatable )
global LPM_RenderDispatchAction 			-- Dabelow Render Dispatch ( future renderer compatable )
global LPM_RenderDispatchRestoreData 		-- Dabelow Render Dispatch ( future renderer compatable )
global LPM_OperatorData 					-- Dabelow

global LPM_VRayInstalled 					-- Dabelow: true if VRay plugin is present on this machine
global LPM_VRayActive    					-- Dabelow: true if VRay is the currently active renderer