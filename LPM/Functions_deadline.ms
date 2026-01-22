Struct LPM_FunctionsDeadlineStr
(

	-- Gets the automatic Deadline Path
	function deadline_GetRepoPath =
	(
		result = undefined

		-- Attempt to retrieve the environment variable for the deadline repository
		try( result = (dotNetClass "System.Environment").GetEnvironmentVariable "DEADLINE_CUSTOM_PATH" )catch()
		-- If it is undefined, return a message.
		if result == undefined then ( result = "DEADLINE_CUSTOM_PATH Environment Variable not set" )

		return result
	),

	function test = ( print "LPM_FunctionsDeadline Loaded")
)

LPM_FunDeadline=(LPM_FunctionsDeadlineStr())

-- LPM_FunDeadline.deadline_GetRepoPath()
-- LPM_FunDeadline.test()
