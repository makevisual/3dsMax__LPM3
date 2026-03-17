rollout vrayRenderElementsPropsRoll "VRay Render Elements Override 1.0" width:325 height:390
(
	local theNode = undefined

	groupbox grp_RenderElements "Select Render Elements" width:313 height:378 slign:#left offset:[-5,0] enabled:true--false
	dotNetControl elementList "system.windows.forms.listView" width:293 height:350 offset:[5, ( ( grp_RenderElements.height * -1 ) + 14 ) ] --pos:[4,248]

	-- returns an array of checked items from the elementlist
	function getCheckedItemsInLV =
	(
		listOfCheckedItems = #()

		-- For each item in the list, get if it is enabled and if true, then append the .text field to the list
		for i in 1 to elementlist.Items.count do 
		(
			if elementlist.Items.item[i-1].checked then append listOfCheckedItems elementlist.Items.item[i-1].subitems.item[1].text
		)

		return listOfCheckedItems
	)

	-- when an item is checked in the list view the ca is updated with the checked items 
	on elementList ItemChecked arg do
	(
		checkedItems = getCheckedItemsInLV()

		--TODO: try / catch needed because checked events happen when ui is building, need better handling
		try
		(
			ca = custAttributes.get theNode 1
			ca.activeElement = checkedItems
			--print ca.activeElement
		)catch()
	)

	function LVsetproperties arg_LV =
	(
		arg_LV.view 			= (dotNetClass "system.windows.forms.view").details
		arg_LV.GridLines 		= false
		arg_LV.FullRowSelect 	= true
		arg_LV.Sorting 			= (dotNetClass "System.Windows.Forms.SortOrder").None
		arg_LV.HideSelection 	= false
		arg_LV.AutoArrange 		= false
		arg_LV.HeaderStyle 		= (dotNetClass "System.Windows.Forms.ColumnHeaderStyle").none
		arg_LV.MultiSelect 		= true													-- Set to single selection mode
		arg_LV.BackColor 		= (dotNetClass "System.Drawing.Color").FromArgb 200 200 200
 		arg_LV.ForeColor 		= (dotNetClass "System.Drawing.Color").FromArgb 30 30 30
		arg_LV.CheckBoxes 		= true
	)

	-- Sets the width of the list view columns, and their names
	function LVsetColumns arg_LV columnsAr =
	(
		arg_LV.columns.add columnsAr[1] 20
		arg_LV.columns.add columnsAr[2] 200
	)

	-- fill the list view with data 
	function LVpopulate arg_LV arg_RenderElements = 
	(
		-- clear and reset the List View
		try( SceneCheck_MainUI.arg_LV.items.clear() )catch()
		rows 			= #()
	
		-- Loop through the render elements and make their entries
		for arg_RenderElement in arg_RenderElements do 
		(
			li=dotNetObject "System.Windows.Forms.ListViewItem" ""
			li.UseItemStyleForSubItems = false

			li.subitems.add arg_RenderElement.name
			li.checked 	=  arg_RenderElement.enabled -- TODO: change this from reading the current state
 			li.tag 		= arg_RenderElement.animhandle 
			
			-- Add it to the array of items to be added to the list view
			append rows li
		)

		-- add the array of items to the list view
		arg_LV.items.addRange rows
	)

	-- get the render elements in the scene 
	function collectElements arg_checkedItems =
	(
		struct elementObjStr
		(
			animhandle = undefined,
			name = "",
			enabled = false
		)

		re 					= maxOps.GetCurRenderElementMgr()  	-- Get the render element manager
		existingElements 	= #()

		for i in 0 to ( re.NumRenderElements() - 1 ) do 		-- Get the current render elements
		(
			curEnabled = false 

			curElement = ( re.GetRenderElement i )
			elementObj = elementObjStr()
			elementObj.animhandle 		= gethandlebyanim curElement
			elementObj.name 			= curElement.elementName
			
			for checkedItem in arg_checkedItems do 
			(
				if elementObj.name == checkedItem then curEnabled = true 
			)
		
			elementObj.enabled = curEnabled

			append existingElements elementObj
		)

		return existingElements
	)

	-- event for rollout open 
	on vrayRenderElementsPropsRoll open do
	(
		elementList.enabled = true 
		LVsetproperties 	elementList
		LVsetColumns 		elementList #("","Elements" )

		-- Get the scene node for the element operator
		cp 		=LPM_treeviewRollout.tv.selectedNode.tag.value
		theNode = cp

		ca = custAttributes.get theNode 1
		checkedItems = ca.activeElement

		filteredElements = #()
		filteredElements = collectElements checkedItems 

		-- populate the listview with the filtered elements
		LVpopulate elementList filteredElements
 	)
	
	on vrayRenderElementsPropsRoll resized arg do
	(

		elementList.height = ( vrayRenderElementsPropsRoll.height - 34 )

	)

	on vrayRenderElementsPropsRoll close do
	(
		-- ca properties are set in the ItemChecked event, so every check operation updates the data
	)
)

rcMenu rc_vrayRenderElementsPropsMenu
(
	menuItem	editProps	"Edit"
	menuItem 	copyProps 	"Copy"
	menuItem   	removeProps "Remove"
	
	on copyProps picked do
	(
		LPM_treeviewRollout.copyNode=LPM_treeviewRollout.tv.selectedNode.tag.value
	)
	
	on removeProps picked do
	(
		theNode=LPM_treeviewRollout.tv.selectedNode.tag.value
		delete theNode
		LPM_treeviewRollout.tv.selectedNode.remove()
	)
	on editProps picked do
	(		
		createDialog vrayRenderElementsPropsRoll pos:(LPM_Fun.getRoPos  vrayRenderElementsPropsRoll.width)
	)
	
)
-- createDialog vrayRenderElementsPropsRoll pos:(LPM_Fun.getRoPos  vrayRenderElementsPropsRoll.width)