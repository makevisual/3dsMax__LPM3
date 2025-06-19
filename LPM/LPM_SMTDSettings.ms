-- Created by Aaron Dabelow
-- Used to pass CA data from LPM Pass preperation to the deadline submitter non-destructivly

struct LPM_SMTDSettings_Struct
(
	active = false,
	priorityOn 			,	-- = false,
	priorityOffsetOn 	,	-- = false,
	priorityOffset 		,	-- = 0,
	priorityAbsoluteOn 	,	-- = false,
	priorityAbsolute 	,	-- = 0,
	taskSizeOn 			,	-- = false,
	taskSize 			,	-- = 1,
	submitGroupOn 		,	-- = false,
	submitGroup 		,	-- = "",
	submitLimitsOn 		,	-- = false,
	submitLimits 		,	-- = true
	idiotCheckReports 	,	-- = true
	renderTicks			,	-- = false --Tyson
	renderTicksMult		 	-- = 1 --Tyson
)

LPM_SMTDSettings = undefined
LPM_SMTDSettings = LPM_SMTDSettings_Struct()