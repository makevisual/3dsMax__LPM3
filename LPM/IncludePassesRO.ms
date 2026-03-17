		rollout pickPasses_RO "Include Passes" width:200 height:360
		(
			radiobuttons allPassesRB "" pos:[5,7] width:102 height:32 labels:#("All Active Passes", "Selected Passes") default:1 columns:1
			
			--multiListBox passPickerLB "" pos:[5,43] width:187 height:20 enabled:false
			dotNetControl passPickerLB "system.windows.forms.listView" pos:[5,43] width:187 height:265
			
			label playBut "Display Pass" pos:[6,315] width:95 height:13
			dropdownList playButtonDDL "" pos:[6,330] width:187 height:21 items:#("Pass01","Pass02")
			
			local theShot
			local theShotNode
			local passArray
			
			
			on pickPasses_RO open do
			(
				LPM_treeviewRollout.FreezeWindow()
				
				passPickerLB.enabled=false
				
				theShot=LPM_treeviewRollout.tv.selectedNode.tag.value
				theShotNode=LPM_treeviewRollout.tv.selectedNode
				
				
				passArray=for it in (LPM_FUn.getallchildren LPM_Root) where it.type=="pass" collect it
				namesArray=for it in passArray collect (LPM_Fun.generatePassName it)
				
				--passPickerLB.items=namesArray
				playButtonDDL.items=namesArray + #("Not Defined")
				playButtonDDL.selection=playButtonDDL.items.count
				
				
				if(theShot.allpasses==false) then
				(	
					allPassesRB.state=2
					passPickerLB.enabled=true
				)
				
				bitAr=#{}
				TmpSelectedPassesArr = #()
				
				for i=1 to passArray.count do
				(	if((findItem theShot.passes passArray[i])>0) then
					(
						append bitAr i
						append TmpSelectedPassesArr namesArray[i]
					)
					if(theShot.displayPass==passArray[i]) then
					(
						playButtonDDL.selection=i
					)
				)
				--passPickerLB.selection=bitAr
				
				LPM_Fun.InitListView passPickerLB "Passes" 187
				
				LPM_Fun.FillListView passPickerLB namesArray TmpSelectedPassesArr
			)
			
			on allPassesRB changed state do
			(
				if(state==2) then
					passPickerLB.enabled=true
				else
					passPickerLB.enabled=false
			)
			
			on pickPasses_Ro close do
			(
				if(allPassesRB.state==1) then
					theShot.allPasses=true
				else
					theShot.allPasses=false
				theShot.passes=#()
				theShot.passesOn=#()
				
				tmpSelection = LPM_Fun.SaveListViewNumbers passPickerLB
				
				--for i=1 to passArray.count where passPickerLB.selection[i] do
				--(
				--	append theShot.passes passArray[i]
				--	append theShot.passesOn true
				--)
				
				for i = 1 to passArray.count do 
				(
					if (findItem tmpSelection i) > 0 then
					(
						append theShot.passes passArray[i]
						append theShot.passesOn true
					)
				)
				
				theShot.displayPass=passArray[playButtonDDL.selection]
				LPM_treeviewRollout.UnFreezeWindow()
				LPM_treeviewRollout.addShotTv theShotNode
			)
			
			on pickPasses_Ro resized theSize do
			(
				if theSize[1] < 200 then
				(
					pickPasses_Ro.width = 200
				)
				if theSize[2] < 360 then
				(
					pickPasses_Ro.height = 360
				)
				
				
				passPickerLB.width=pickPasses_RO.width-13
				passPickerLB.height=pickPasses_RO.height-94
				
				playBut.pos = [playBut.pos[1],pickPasses_Ro.height-45]
				playButtonDDL.pos = [playButtonDDL.pos[1],pickPasses_Ro.height-30]
				playButtonDDL.width=pickPasses_RO.width-13
			)
			
		)

		createDialog pickPasses_RO pos:(LPM_Fun.getRoPos  pickPasses_Ro.width) style:#(#style_titlebar,#style_border, #style_sysmenu,#style_resizing)