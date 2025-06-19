struct LPM_MaxFileSubmitAPI
(
    type="MaxFile",
    fn submit=
    (
        rollout LPM_MaxFileSubmit_Ro "Max File / 3rd-Party Submit" width:300 height:95
        (
            GroupBox grp1 "Max File Directory" pos:[8,2] width:289 height:45
            button pickPathButton "..." pos:[13,22] width:35 height:17
            edittext pathText "" pos:[48,22] width:200 height:17 enabled:false
            button openButton "Open" pos:[252,22] width:35 height:18
            button generateMaxFilesButton "Submit" pos:[7,55] width:100 height:28
            progressBar submitProgress "" pos:[111,55] width:185 height:30 visible:true

            on LPM_MaxFileSubmit_Ro open do
            (
                if(LPM_Root.maxFileRenderRoot==undefined) then
                (   
                    LPM_Root.maxFileRenderRoot=maxFilePath
                    pathText.text=maxFilePath
                )
                else
                (
                    pathText.text=LPM_Root.maxFileRenderRoot
                )
            )

            on pickPathButton pressed do
            (
                thePath=getSavePath caption:"Pick the pass root" initialDir:LPM_Root.rootDir
                if(thePath!=undefined) then
                (   
                    LPM_Root.maxFileRenderRoot=thePath+"\\"
                    pathText.text=LPM_Root.maxFileRenderRoot
                )       
            )

            on generateMaxFilesButton pressed do
            (
                submitProgress.value = 0
                submitProgress.visible = true
                
                renderCollect = LPM_Fun.getWhoToRender()
                flag=true
                
                for i=1 to renderCollect.count where flag do
                (
                    submitProgress.value = (100*(i-1))/renderCollect.count
                    
                    LPM_Render.fnPreRenderAction renderCollect[i][1] renderCollect[i][2]
                    thePass=renderCollect[i][1]
                    theShot=renderCollect[i][2]

                    if(theShot==undefined) then
                    (
                        theFileName=    ((getFilenameFile maxFileName) + "_" + (LPM_Fun.generatePassName thePass))
                    )
                    else
                    (
                        theFileName= ((getFilenameFile maxFileName) + "_" + (LPM_Fun.getname theShot.name) +"_" +(LPM_Fun.generatePassName thePass)) 
                    )
                    
                    for i=1 to theFileName.count do if (theFileName[i]==" ") then theFileName[i]="_"--replace spaces with _ for Deadline
                    theFilename=LPM_Root.maxFileRenderRoot+theFileName
                        
                    saveMaxFile theFileName useNewFile:false quiet:true 
                    
                    -- Put the scene back together
                    LPM_Render.fnPostRenderAction renderCollect[i][1] renderCollect[i][2]
                    if(keyboard.escPressed) then flag=false
                )
                
                try(destroyDialog LPM_MaxFileSubmit_Ro)catch()
            )

            on openButton pressed do
            (
                shelllaunch pathText.text ""
            )
        )
        
        createdialog LPM_MaxFileSubmit_Ro pos:(LPM_Fun.getRoPos LPM_MaxFileSubmit_Ro.width)
        
        return #SUCCESS
    )
)

LPM_MaxFileSubmitAPI.submit()