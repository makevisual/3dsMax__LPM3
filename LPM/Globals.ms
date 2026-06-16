-- Global declarations shared between LPM modules.

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
global LPM_lightSetProps
global LPM_commonRollout
global LPM_activePass
global LPM_LoadingPreset
global LPM_Operators
global LPM_activeElement
global LPM_doubleClick 
global LPM_oldRenderSettings
global LPM_oldRenderSettingsNew
global LPM_rendererClosed
global LPM_ObjSetPropsBuff
global LPM_LightSetDataBuff
global LPM_iconPath = LPM_Dir + "icons/"
global LPM_disabledIconFolder = "blacks"
global LPM_BackColor 					
global LPM_FontColor
global LPM_ContinueLoad

global LPM_IdiotChecksEnabled
global LPM_VersionNumber
global LPM_SMTDSettings
global LPM_NukeAPI
global LPM_RenderDispatchThePass 			-- Render Dispatch ( future renderer compatible )
global LPM_RenderDispatchTheShot 			-- Render Dispatch ( future renderer compatible )
global LPM_RenderDispatchAction 			-- Render Dispatch ( future renderer compatible )
global LPM_RenderDispatchRestoreData 		-- Render Dispatch ( future renderer compatible )
global LPM_OperatorData

global LPM_PreviewBackend = "tyPreview"		-- Selects which preview backend preview_dispatch.ms loads ("tyPreview"; future: "viewport")

global LPM_VRayInstalled 					-- true if VRay plugin is present on this machine
global LPM_VRayActive    					-- true if VRay is the currently active renderer
global LPM_TyFlowInstalled 				-- true if tyFlow plugin is present on this machine

-- Read directly (LPM_Fun.getIni is not loaded yet when the startup checks print)
global LPM_VerboseLogging = ((getINISetting ((getdir #plugcfg) + "\\LPM.ini") "Settings" "VerboseLogging") == "true")