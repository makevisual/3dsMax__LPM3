-- Nuke Export Operator — NOT YET IMPLEMENTED
--
-- This file is a placeholder. The nukeExportPropsCA custom attribute
-- exists in CA.ms but the operator logic has not been written.
-- See also: LPM/NukeAPI.ms for the Nuke integration API.
--
-- When implementing, follow the pattern in operator_cameraOverscan.ms:
--   1. Define a restore data struct
--   2. Define pre/post render functions using LPM_Root.renderCamera (NOT selection[1])
--   3. Hook into LPM_RenderDispatchAction dispatch via curPrerenderAction/curPostRenderAction

-- No-op: do nothing when dispatched
function curPrerenderAction = ()
function curPostRenderAction = ()
