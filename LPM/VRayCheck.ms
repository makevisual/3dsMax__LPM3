-- VRayCheck.ms
-- Added by Aaron Dabelow
--
-- Detects VRay availability on startup and sets two globals used throughout LPM.
-- Centralising this check here means every other file can branch on a plain boolean
-- rather than probing the renderer inline, which would scatter silent failures.
--
--   LPM_VRayInstalled : VRay plugin is present on this machine (class definitions available)
--   LPM_VRayActive    : VRay is the currently active renderer
--
-- Both are set conservatively to false before the probe, so any unexpected error
-- during detection leaves the tool in a safe, non-VRay state.

LPM_VRayInstalled = false
LPM_VRayActive    = false

-- Probe for VRay by referencing a known VRay class name.
-- If VRay is not installed the name is undefined, and MaxScript throws
-- "Unknown variable: VRayLight" which the try block catches cleanly.
try ( local _probe = VRayLight; LPM_VRayInstalled = true ) catch()

-- Renderer check is version-agnostic: any V_Ray_* string matches.
-- Wrapped in its own try in case renderers.current is somehow inaccessible.
try ( LPM_VRayActive = matchPattern (renderers.current as string) pattern:"*V_Ray*" ) catch()

-- Log results to the MaxScript Listener so they are visible at startup.
if LPM_VRayInstalled then
	print "LPM VRayCheck: V-Ray plugin detected."
else
	print "LPM VRayCheck: V-Ray not detected. VRay-specific features will be disabled."

if LPM_VRayActive then
	print "LPM VRayCheck: V-Ray is the active renderer."
else
	print "LPM VRayCheck: V-Ray is not the active renderer."
