-- All of the libraries needed for LPM to run, and then call the main thread

global LPM_Dir = trimright (getThisScriptFilename()) "Include.ms"

filein (LPM_Dir+"Globals.ms")
filein (LPM_Dir+"VRayCheck.ms") 			-- Added by Aaron Dabelow
filein (LPM_Dir+"VersionNumber.ms") 		-- Added by Aaron Dabelow
filein (LPM_Dir+"versionCheck.ms")  		-- Added by Aaron Dabelow

-- If user confirms old scene load, continue to run the program.
if LPM_ContinueLoad
then (

	filein (LPM_Dir+"include.mcr")
	filein (LPM_Dir+"CA.ms")
	filein (LPM_Dir+"output_paths.ms") 		-- Added by Aaron Dabelow
	filein (LPM_Dir+"functions.ms")
	filein (LPM_Dir+"functions_deadline.ms")-- Added by Aaron Dabelow
	filein (LPM_Dir+"render.ms")
	filein (LPM_Dir+"rcMenus.ms")
	filein (LPM_Dir+"LPM_SMTDSettings.ms") 	-- Added by Aaron Dabelow
	filein (LPM_Dir+"NukeAPI.ms") 			-- Added by Aaron Dabelow
	filein (LPM_Dir+"treeView.ms")
	filein (LPM_Dir+"operatorsAPI.ms")
	filein (LPM_Dir+"MAKE_nukeem.ms") 		-- Added by Aaron Dabelow
	filein (LPM_Dir+"OperatorData.ms") 		-- Added by Aaron Dabelow

	-- Set some common properties in an easy place
	LPM_Root.renderType = 3 												-- Force to shots

	-- TODO: Consider moving these to CA.ms on rootCA
	setUserProp LPM_Root "DeadlineRepository" @"N:\DeadlineRepository10"    -- Set your deadline Repository
	setUserProp LPM_Root "LPM_VersionNumber" LPM_VersionNumber    			-- Set your LPM Version Number
)
else()