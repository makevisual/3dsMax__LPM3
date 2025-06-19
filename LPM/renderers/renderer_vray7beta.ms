-- Sets the rendderer specific outputs for Vray7 and disables the max save file
-- Included the depreciated function for any possible future use
-- 11/05/2024 Aaron Dabelow theonlyaaron@gmail.com

struct Vray7_RestoreDataStr
(
    -- Scene specific properties
    matEditor_open          = undefined,

    -- Renderer specific globals
    output_on               = undefined,
    output_rawFileName      = undefined,
    output_saveRawFile      = undefined,
    output_splitgbuffer     = undefined,
    output_genpreview       = undefined,
    rendShowVFB             = undefined,
    rendSaveFile            = undefined,
    output_useram           = undefined,
    rendUseActiveView       = undefined,
    regionDimensions        = undefined,

    -- Vray7 Render Element Override
    vrayVFBElementStates    = undefined,

    -- Vray7 Render Override
    qualityType             = undefined,
    global_switches_check   = undefined,
    displacement            = undefined,
    reflrefr                = undefined,
    anti_aliasing_check     = undefined,
    aaMin                   = undefined,
    aaMax                   = undefined,
    GI_illum_check          = undefined,
    giOn                    = undefined,
    GI_check                = undefined,
    giSkylightOn            = undefined,
    giSkylightMap           = undefined,
    giSkylightCol           = undefined,
    giSkylightMult          = undefined,
    giSkylightMapCheck      = undefined,
    giRefOn                 = undefined,
    giRefCol                = undefined,
    giRefMap                = undefined,
    giRefMult               = undefined,
    giRefMapCheck           = undefined,
    moblur_check            = undefined,
    moblurOn                = undefined,
    moblurSubdivs           = undefined,
    prog_check              = undefined,
    progMaxSubdiv           = undefined,
    progTime                = undefined,
    dmc_check               = undefined,
    dmcThresh               = undefined,
    dmcMult                 = undefined
 )

function Vray7_Globals_Override_PreRender =
(
    -- Fetch the global variable and assign the current state to it
    Vray7_RestoreData = LPM_RenderDispatchRestoreData

    Vray7_RestoreData.output_on           = renderers.current.output_on

    -- stores the vray vfb output path, if one is not set, then and empty string is stored instead
    if renderers.current.output_rawFileName == undefined
    then ( Vray7_RestoreData.output_rawFileName  = "" )
    else ( Vray7_RestoreData.output_rawFileName  = renderers.current.output_rawFileName )

    Vray7_RestoreData.output_saveRawFile  = renderers.current.output_saveRawFile
    Vray7_RestoreData.output_splitgbuffer = renderers.current.output_splitgbuffer
    Vray7_RestoreData.output_genpreview   = renderers.current.output_genpreview
    Vray7_RestoreData.output_useram       = renderers.current.output_useram
    Vray7_RestoreData.rendShowVFB         = rendShowVFB
    Vray7_RestoreData.rendSaveFile        = rendSaveFile
    Vray7_RestoreData.rendUseActiveView   = rendUseActiveView
    Vray7_RestoreData.regionDimensions    = (vfbControl #getregion )

    -- Scene properties 
    Vray7_RestoreData.matEditor_open    = MatEditor.isOpen() 

    -- SMTD Settings
    SMTDSettings.LimitGroupsToUse

    -- Fetch, parse and make the output directory
    thePath=getFilenamePath rendOutputFilename
    theFile=getFilenameFile rendOutputFilename
    theType=getFilenameType rendOutputFilename

    -- Makes the directory
    makeDir thePath

    -- Set the properties to their desired values
    renderers.current.output_on             = true                           -- force vray frame buffer on
    renderers.current.output_rawFileName    = (thePath + theFile + ".exr")   -- ( previously rendOutputFilename ) steal the name from the 3dsmax render output filename global ( set in render.ms )
    renderers.current.output_saveRawFile    = true                           -- enable saving the file
    renderers.current.output_splitgbuffer   = true                           -- enable render elements to be stored in the output ??????
    renderers.current.output_genpreview     = true                           -- Not sure if this needs to be on or not
    rendShowVFB                             = false                          -- Turn off max default frame buffer
    rendSaveFile                            = false                          -- Turn off max default file save option
    rendUseActiveView                       = true                           -- Disables the lock on the camera view, this causes bugs on network renders knowing which camera to use
    vfbControl #setregion 0 0 0 0                                            -- Sets the region render to zero pixels, effectivly disabling the render region function
    MatEditor.Close()                                                        -- Close the material editor ( faster operation )

    -- If the renderer is set to progressive, it turns the memory frame buffer on, which is necessary for it to work
    -- otherwise it turns the memory frame buffer off, which is the preferred method, for memory handling, and performance
    -- however, note that the frame buffer will not be interactive in this mode, and will only clone a small window for the viewer
    if renderers.current.imageSampler_type == 3
    then( renderers.current.output_useram = true )
    else( renderers.current.output_useram = false )
)

function Vray7_Globals_Override_PostRender =
(
    -- Get the restore data from global variable
    Vray7_RestoreData = LPM_RenderDispatchRestoreData

    -- Restore the previous data
    renderers.current.output_rawFileName    = Vray7_RestoreData.output_rawFileName
    renderers.current.output_saveRawFile    = Vray7_RestoreData.output_saveRawFile
    renderers.current.output_splitgbuffer   = Vray7_RestoreData.output_splitgbuffer
    renderers.current.output_genpreview     = Vray7_RestoreData.output_genpreview
    renderers.current.output_useram         = Vray7_RestoreData.output_useram
    rendShowVFB                             = Vray7_RestoreData.rendShowVFB
    rendSaveFile                            = Vray7_RestoreData.rendSaveFile
    rendUseActiveView                       = Vray7_RestoreData.rendUseActiveView
    vfbControl #setregion Vray7_RestoreData.regionDimensions[1][1] Vray7_RestoreData.regionDimensions[1][2] Vray7_RestoreData.regionDimensions[1][3] Vray7_RestoreData.regionDimensions[1][4]

    -- Open the material editor if it was open
    if Vray7_RestoreData.matEditor_open then (MatEditor.Open())
)

function Vray7_Globals_Override_Preview_PreRender =
(
    --Builds an empty struct and and marks the RestorePoint flag as false
    Vray7_RestoreData = LPM_RenderDispatchRestoreData
)

function Vray7_RE_Override_PreRender =
(
    print "= Vray7 Vray7_RE_Override_PreRender ="

    -- object for holding render element states
    struct elementObjStr
    (
        animhandle = undefined,
        name = "",
        enabled = false
    )

    -- Get the render element manager
    re                  = maxOps.GetCurRenderElementMgr()
    existingElements    = #()

    -- Get the current render elements
    for i in 0 to ( re.NumRenderElements() - 1 ) do
    (
        -- Try Catch added for non v-ray supported render elements, or vrayAlpha render element
        try(
            curEnabled = false

            curElement = ( re.GetRenderElement i )
            elementObj = elementObjStr()

            elementObj.animhandle       = gethandlebyanim curElement
            elementObj.name             = curElement.elementName
            elementObj.enabled          = curElement.vrayVFB

            append existingElements elementObj
        )catch()
    )


    ---- Auto assign the correct deadline limit ----
    
    try(
        -- make a new empty list
        newList = #()

        -- loop through existing SMTD Settings limits ( set by user / submitter )
        for limit in SMTDSettings.LimitGroupsToUse do 
            
            -- add to the new empty list, if it is not v-ray 6 - effectivly removing that limit from the list 
            if limit != "v-ray 6" then append newlist limit 

        -- add v-ray 7 to the limit list, and remove any duplicates
        append newlist "v-ray 7"
        makeUniqueArray newList

        -- set the SMTD Settings limit to the newly filtered list 
        SMTDSettings.LimitGroupsToUse = newlist
    )
    catch( print"SMTD Settings have not been imported!")

    -- Store the collected data for later restoration
    LPM_RenderDispatchRestoreData.vrayVFBElementStates = existingElements

    -- get the active pass from the global variable
    thePass = LPM_RenderDispatchThePass

-- TODO:
    -- Elements are beiing stored, but not being applied, keep looking around here


    -- Collect the operators that are "Vray7RenderElements", get their "activeElementList" and enable them
    theVray7RenderElements =for it in thePass.children where ((it.type=="Vray7RenderElements") and (it.active)) collect it
    for theVray7RenderElement in theVray7RenderElements do
    (
        -- get the custom attribute from the current operator ( active elements as string array )
        ca = custAttributes.get theVray7RenderElement 1
        activeElements = ca.activeElement

        -- loop through all of the render elements
        for i in 0 to ( re.NumRenderElements() - 1 ) do
        (
            -- try -- Try Catch for elements that do not have a .vrayVFB property, like vryaAlpha, that cannot render int the frame buffer
            (
                print (curElement)
                -- turn the render element off
                curElement = ( re.GetRenderElement i )
                curElement.vrayVFB = false

                -- turn on the ones that matche the activeElement name
                for activeElement in activeElements do
                (
                    if curElement.elementName == activeElement then (curElement.vrayVFB = true)
                )
            )
            -- catch()
        )
    )
)

function Vray7_RE_Override_PostRender =
(
    -- print "= Vray7 Vray7_RE_Override_PostRender ="

    -- Get the elements stored earlier and restore them
    curElements = LPM_RenderDispatchRestoreData.vrayVFBElementStates

    for curElement in curElements do
    (
        curNode = getAnimByHandle curElement.animhandle
        curNode.vrayVFB = curElement.enabled
    )
)

function Vray7_Override_PreRender =
(

)

function Vray7_Override_PostRender =
(

)

function curPrerenderAction =
(
    print "== Vray7 PreRenderAction =="

    -- Construct object for storing pre-render state for use for restoring later
    LPM_RenderDispatchRestoreData = Vray7_RestoreDataStr()

    -- call each of the prerender functions
    Vray7_Globals_Override_PreRender()

    Vray7_RE_Override_PreRender()
    Vray7_Override_PreRender()
)

function curPreviewPrerenderAction =
(
    print "== Vray7 Preview PreRenderAction =="

    -- Construct object for storing pre-render state for use for restoring later
    LPM_RenderDispatchRestoreData = Vray7_RestoreDataStr()
    Vray7_RE_Override_PreRender()

    -- call each of the prerender functions
    Vray7_Globals_Override_Preview_PreRender()
)

function curPostRenderAction =
(
    --Calls Data from the global to check the restorepoint flag
    Vray7_RestoreData = LPM_RenderDispatchRestoreData

    -- print "== Vray7 PostRenderAction =="

    --Only runs the Post render action if Settings were altered in the prerender based on the restorepoint flag
    if LPM_RenderDispatchAction != #PreviewRender then
    (
        try( Vray7_Globals_Override_PostRender() )catch() -- TODO: remove later????
        try( Vray7_Override_PostRender() )catch() -- TODO: remove later????
    )

     Vray7_RE_Override_PostRender()
    -- call each of the postrender functions

)

-- print " Vray 5.1.3 sucsusfully called from RenderDispatch "

if LPM_RenderDispatchAction == #preRender then curPrerenderAction()
if LPM_RenderDispatchAction == #postRender then curPostRenderAction()
if LPM_RenderDispatchAction == #PreviewRender then curPreviewPrerenderAction()