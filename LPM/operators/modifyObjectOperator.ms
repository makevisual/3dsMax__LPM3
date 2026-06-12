/*
Pass operator written by Jacob Jeziorski (www.JakubJeziorski.com)
for Lukas Lepicovsky's LPass Manager
www.lukashi.com
*/
/* OPERATORS*/
--All operators MUST implement the following:
--this (Pointer to the instance of the struct)
--INode (Pointer to the node holding the data)
--fnGetSubType (The type of the operator, alphaCharacters only, no spaces
--fnPerformAction (Function that takes as input a action type), return #NOT_IMPLEMENTED if I a function is not implemented


struct LPM_modifyObjectOperator
(
	
--	this,--Required
	INode=0,--Required
	fn fnGetSubType=--Required
	(
		return "ModifyObject"
	),
	-- Custom data for the operator
	myObject=undefined,
	disabledModifiers=#(),
	isLoaded=false,
	--Save and store functions for the custom data
	fn fnload =
	(
		if(isLoaded==false) then
		(
			if(isvalidnode INode) then
			(
				myObject=INode.getValue "myObject" undefined
				disabledModifiers=INode.getArray "disabledModifiers" #()
			)
			isLoaded=true
		)
	),
	
	fn fnStore =
	(
		if(isvalidnode INode) then
		(
			
			INode.setValue "myObject" myObject
			INode.setArray "disabledModifiers" disabledModifiers
			
			
		)
	),
	--Actions
	fn fnDisableModifiers=
	(
		
			--Make sure we at least loaded...
			--setCommandPanelTaskMode #Create
			if(isvalidnode myObject) then
			(
				for modi in myObject.modifiers do
				(
					if (findItem disabledModifiers modi.name !=0) then
						modi.enabled=false
					else
						modi.enabled=true
				)
			)
		
		
	),
	
	fn fnEnableModifiers=
	(
			--Make sure we at least loaded...
			--setCommandPanelTaskMode #Create
			if(isvalidnode myObject) then
			(
				for modi in myObject.modifiers do
				(
					if (findItem disabledModifiers modi.name !=0) then
						modi.enabled=true
					else
						modi.enabled=false
				)
			)
		
		
	),

	--#Edit
	fn fnEdit =
	(
		try(destroyDialog myRollout)catch()
		
		rollout myRollout "Modifiers On/Off"
		(
			local this
			pickbutton  pbObject ""
			label lbl1 "Disabled Modifiers"--\n Note: All Selected Modifiers Will Be Disabled" width:170
			multilistbox LBDisabledModifiers 
			--button btnDisable "Disabled Selected"
			fn fnUpdateUI=
			(
				if(isvalidnode this.myObject==false) then
				(
					pbObject.text="Pick the Object To Modify"
				)
				else
				(
					pbObject.text=this.myObject.name
					LBDisabledModifiers.items=for modi in this.myObject.modifiers collect modi.name
					sel=#{}
					for i=1 to LBDisabledModifiers.items.count do
					(
						if(finditem this.disabledModifiers LBDisabledModifiers.items[i] !=0) then
							sel[i]=true
					)
					
					LBDisabledModifiers.selection=sel
					
				)
			)
			on LBDisabledModifiers selectionEnd do
			(
				this.disabledModifiers=for i=1 to LBDisabledModifiers.items.count where LBDisabledModifiers.selection[i] collect LBDisabledModifiers.items[i]
			)
			on pbObject picked obj do
			(
				this.myObject=obj
				fnUpdateUI()
			)
			on btnDisable pressed do
			(
				this.fnDisableModifiers()
			)
			fn fnOpen =
			(
				pbObject.object=this.myObject
				fnUpdateUI()
			)
			on myRollout close do
			(
				this.myObject=pbObject.object
				this.fnStore()
			)
		)
		
		createdialog myRollout
		myRollout.this=this	
		myRollout.fnOpen()
		return true
	),
	fn fnRightClick=
	(
		rcmenu rctest
		(
			local this
			menuItem editMe "Edit"
			menuItem DeleteMe "Delete"
			on editMe picked do
			(
				this.fnEdit()
			)
			on deleteMe picked do
			(
				LPM_Operators.fnDeleteOperatorByNode this.INode
			)
		)
		popUpMenu rctest
		rcTest.this=this
	),
	
	fn fnPerformAction action param:#() =--Required
	(
		fnload()
		case action of
		(
			#Edit:(fnEdit())
			#preRender:(fnDisableModifiers())
			#postRender:(fnEnableModifiers())
			#middleClick:(fnDisableModifiers())
			#rightClick:(fnRightClick())
			default:(return #NOT_IMPLEMENTED)
		)
	)
	
)

LPM_operators.fnRegisterOperator LPM_modifyObjectOperator