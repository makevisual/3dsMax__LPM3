-- clearListener()

-- Assign the global root object
LPM_Root = $LPM_Root

-- If the scene has existing LPM Data, test the data version
if LPM_Root != undefined
then 
(
	loadedVersion = ( ( getUserProp LPM_Root "LPM_VersionNumber" ) as string )
	if loadedVersion == "undefined" then ( loadedVersion = "Legacy")
	if LPM_VerboseLogging do
	(
		print("LPM Scene Data Version - " + loadedVersion)
		print("LPM Application Version - " + LPM_VersionNumber)
	)

	-- Function for comparing versions verA - Scene loaded version, verB - current program version
	fn compareVersions verA verB =
	(
	    local partsA = filterString verA "."
	    local partsB = filterString verB "."

	    -- Pad both arrays to 3 parts
	    while partsA.count < 3 do append partsA "0"
	    while partsB.count < 3 do append partsB "0"

	    for i = 1 to 3 do
	    (
	        local a = partsA[i] as integer
	        local b = partsB[i] as integer

	        if a < b do return "older"
	        if a > b do return "newer"
	    )
	    
	    return "equal"
	)

	-- Function to make a window if the versions mismatch and the scene version is a legacy non-version number version.
	-- Prompts user to contine with a choice
	fn showLPMVersionWarning =
	(
	    result = undefined  -- will hold return value

	    rollout lpmWarningRollout "Legacy LPM Data Detected"
	    (
	        dotNetControl rtb "System.Windows.Forms.RichTextBox" width:330 height:80
	        button continueBtn "Continue" width:120 align:#center
	        button abortBtn "Abort" width:120 align:#center

	        on lpmWarningRollout open do
	        (

			    local dotNetColorBG = (dotNetClass "System.Drawing.Color").FromArgb 69 69 69
			    local dotNetColorText = (dotNetClass "System.Drawing.Color").FromArgb 255 255 255

			    rtb.readOnly = true
			    rtb.wordWrap = true
			    rtb.borderStyle = rtb.borderStyle.None
			    rtb.backColor = dotNetColorBG
			    rtb.foreColor = dotNetColorText
			    rtb.margin = dotNetObject "System.Windows.Forms.Padding" 6
			    rtb.text = 
			        "\nThis scene contains LPM data from a legacy version.\n" +
			        "Continuing will update it and make it no longer backward compatible.\n\n" +
			        "Keep a copy of your scene, and inspect your LPM before continuing. "+
			        "Check the listener for details. "
	        )

	        on continueBtn pressed do
	        (
	            LPM_ContinueLoad = True
	            destroyDialog lpmWarningRollout
	        )

	        on abortBtn pressed do
	        (
	            LPM_ContinueLoad = False
	            destroyDialog lpmWarningRollout
	        )
	    )

	    createDialog lpmWarningRollout modal:true width:360
	    return result
	)

	-- Function to make a window if the versions mismatch and the scene version is newer then the LPM version
	-- Prompts user to contine with a choice
	fn showLPMVersionTooNewWarning =
	(
	    result = undefined  -- will hold return value

	    rollout lpmTooNewWarningRollout "LPM Version Mismatch"
	    (
	        local vScene = ""  -- rollout-local version placeholders
	        local vTool = ""

	        dotNetControl rtb "System.Windows.Forms.RichTextBox" width:330 height:100
	        button continueBtn "Continue" width:120 align:#center
	        button abortBtn "Abort" width:120 align:#center

	        on lpmTooNewWarningRollout open do
	        (
	            local dotNetColorBG = (dotNetClass "System.Drawing.Color").FromArgb 69 69 69
	            local dotNetColorText = (dotNetClass "System.Drawing.Color").FromArgb 255 255 255

	            rtb.readOnly = true
	            rtb.wordWrap = true
	            rtb.borderStyle = rtb.borderStyle.None
	            rtb.backColor = dotNetColorBG
	            rtb.foreColor = dotNetColorText
	            rtb.margin = dotNetObject "System.Windows.Forms.Padding" 6

	            rtb.text = 
	                "\nThis scene was created with a newer version of LPM.\n" +
	                "This may cause incompatibilities or errors.\n\n" +
	                "Proceed only if you know what you're doing." +
	               	"Check the listener for details. "
	        )

	        on continueBtn pressed do
	        (
	            LPM_ContinueLoad = True
	            destroyDialog lpmTooNewWarningRollout
	        )

	        on abortBtn pressed do
	        (
	            LPM_ContinueLoad = False
	            destroyDialog lpmTooNewWarningRollout
	        )
	    )

	    createDialog lpmTooNewWarningRollout modal:true width:360
	    return result
	)

	-- Logic of testing the scene 

	if loadedVersion == "Legacy" 			--If there was no version number ( legacy )
	then( showLPMVersionWarning() ) 		-- Warn user of data compatability
	else 									-- Compare versions and warn if opening a newer scene in an older version of LPM
	(
		result = compareVersions loadedVersion LPM_VersionNumber
		if result == "newer"
		then ( showLPMVersionTooNewWarning())
		else ( LPM_ContinueLoad = true)
	)
)

-- If the secene does not contain LPM data, start fresh.
else( LPM_ContinueLoad = True )
