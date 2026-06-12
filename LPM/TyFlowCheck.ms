-- TyFlowCheck.ms
--
-- Detects tyFlow availability on startup and sets a global used throughout LPM.
-- Centralising this check here means every other file can branch on a plain boolean
-- rather than probing the plugin inline, which would scatter silent failures.
--
--   LPM_TyFlowInstalled : tyFlow plugin is present on this machine (class definitions available)
--
-- Set conservatively to false before the probe, so any unexpected error
-- during detection leaves the tool in a safe, non-tyFlow state.

LPM_TyFlowInstalled = false

-- Probe for tyFlow by referencing a known tyFlow class name.
-- If tyFlow is not installed the name is undefined, and MaxScript throws
-- "Unknown variable: tyFlow" which the try block catches cleanly.
try ( local _probe = tyFlow; LPM_TyFlowInstalled = true ) catch()

-- Log results to the MaxScript Listener when verbose logging is enabled.
if LPM_VerboseLogging do
(
	if LPM_TyFlowInstalled then
		print "LPM TyFlowCheck: tyFlow plugin detected."
	else
		print "LPM TyFlowCheck: tyFlow not detected. tyFlow-specific features will be disabled."
)
