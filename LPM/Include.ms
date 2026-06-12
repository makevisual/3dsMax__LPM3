-- All of the libraries needed for LPM to run, and then call the main thread

global LPM_Dir = trimright (getThisScriptFilename()) "Include.ms"

filein (LPM_Dir+"Globals.ms")
filein (LPM_Dir+"VRayCheck.ms")
filein (LPM_Dir+"TyFlowCheck.ms")
filein (LPM_Dir+"VersionNumber.ms")
filein (LPM_Dir+"versionCheck.ms")

-- If user confirms old scene load, continue to run the program.
if LPM_ContinueLoad
then (

	filein (LPM_Dir+"include.mcr")
	filein (LPM_Dir+"CA.ms")
	filein (LPM_Dir+"output_paths.ms")
	filein (LPM_Dir+"functions.ms")
	filein (LPM_Dir+"functions_deadline.ms")
	filein (LPM_Dir+"render.ms")
	filein (LPM_Dir+"rcMenus.ms")
	filein (LPM_Dir+"LPM_SMTDSettings.ms")
	filein (LPM_Dir+"NukeAPI.ms")
	filein (LPM_Dir+"treeView.ms")
	filein (LPM_Dir+"operatorsAPI.ms")
	filein (LPM_Dir+"MAKE_nukeem.ms")
	filein (LPM_Dir+"OperatorData.ms")

	-- Set some common properties in an easy place
	LPM_Root.renderType = 3 												-- Force to shots

	setUserProp LPM_Root "LPM_VersionNumber" LPM_VersionNumber    			-- Set your LPM Version Number
)
else()