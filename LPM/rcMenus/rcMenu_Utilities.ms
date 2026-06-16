global utilityCurProps

struct UtilityTools_Def 
(
	function makeCurProps =
	(
		struct curPropsStr
		(
			node,
			radius,
			falloff,
			subdivs,
	  		extrapolateOn,
	  		nearDistance,
	  		farDistance
	  	)

	  	result = curPropsStr()
	  	return result
	)

--	)
)

utilityTools 	= UtilityTools_Def
utilityCurProps = utilityTools.makeCurProps()