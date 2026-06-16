-- Because there is no good global location to get and set data from, this struct was added to be able to add a property for each custom operator to have data stored on as needed.
-- This struct is instantiated and stored on the global LPM_OperatorData to be accessed anywhere
-- Extra props can be added for any future operators or data needs.

struct LPM_OperatorDataStr (
	cameraOverscan      = undefined,
    renderImage         = undefined,
    nukeExport          = undefined,
    aeExport            = undefined,
    tyPreview           = undefined,
    null                = undefined
)

LPM_OperatorData = LPM_OperatorDataStr()
