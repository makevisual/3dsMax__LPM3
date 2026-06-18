-- Sets the rendderer specific outputs for Vray7 and disables the max save file
-- Included the depreciated function for any possible future use


-- CLASSES

-- Object to hold all the restore data
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
    renderElements_active   = undefined,

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

-- GLOBAL SWITCHES

-- Prerender Globals
-- When rendering Production, these settings are applied
function preRenderAction_ProductionGlobals =
(
    -- Disable the interactive renderer if it is running.
    vrayStopIPR()

    -- Fetch the global variable and assign the current state to it
    Vray7_RestoreData                      = LPM_RenderDispatchRestoreData
    Vray7_RestoreData.output_on            = renderers.current.output_on

    -- stores the vray vfb output path, if one is not set, then and empty string is stored instead
    if renderers.current.output_rawFileName == undefined
    then ( Vray7_RestoreData.output_rawFileName  = "" )
    else ( Vray7_RestoreData.output_rawFileName  = renderers.current.output_rawFileName )



-- TODO: Attach the deep hooks
--    renderers.current.output_rawExrDeep = cp.deepEXR



    -- stores various other output and frame buffer settings
    Vray7_RestoreData.output_saveRawFile        = renderers.current.output_saveRawFile
    Vray7_RestoreData.output_splitgbuffer       = renderers.current.output_splitgbuffer
    Vray7_RestoreData.output_genpreview         = renderers.current.output_genpreview
    Vray7_RestoreData.output_useram             = renderers.current.output_useram
    Vray7_RestoreData.rendShowVFB               = rendShowVFB
    Vray7_RestoreData.rendSaveFile              = rendSaveFile
    Vray7_RestoreData.rendUseActiveView         = rendUseActiveView
    Vray7_RestoreData.regionDimensions          = (vfbControl #getregion )

    -- Active render elements empty for now, they are populated in the render elements prerender function
    Vray7_RestoreData.renderElements_active     = #() -- active render elements

    -- Scene properties 
    Vray7_RestoreData.matEditor_open    = MatEditor.isOpen() 

    -- Fetch, parse and make the output directory
    thePath=getFilenamePath rendOutputFilename
    theFile=getFilenameFile rendOutputFilename
    theType=getFilenameType rendOutputFilename

    -- Makes the output directory
    makeDir thePath

    -- Set the properties to their desired values
    renderers.current.output_on             = true                           -- force vray frame buffer on

    -- NOTE: Forcing .exr filetype over other filetypes for compatability with the VRAY Frame buffer memory management benefits
    renderers.current.output_rawFileName    = (thePath + theFile + ".exr")   -- ( previously rendOutputFilename ) steal the name from the 3dsmax render output filename global ( set in render.ms )
    renderers.current.output_saveRawFile    = true                           -- enable saving the file
    renderers.current.output_splitgbuffer   = true                           -- enable render elements to be stored in the output ??????
    renderers.current.output_genpreview     = true                           -- Not sure if this needs to be on or not
    rendShowVFB                             = false                          -- Turn off max default frame buffer
    rendSaveFile                            = false                          -- Turn off max default file save option
    rendUseActiveView                       = true                           -- Disables the lock on the camera view, this causes bugs on network renders knowing which camera to use
    vfbControl #setregion 0 0 0 0                                            -- Sets the region render to zero pixels, effectivly disabling the render region function
    MatEditor.Close()                                                        -- Close the material editor ( faster operation )
    vfbControl #setregion "reset"                                            -- Turns off any region renders, before submitting

    -- If the renderer is set to progressive, it turns the memory frame buffer on, which is necessary for it to work
    -- otherwise it turns the memory frame buffer off, which is the preferred method, for memory handling, and performance
    -- however, note that the frame buffer will not be interactive in this mode, and will only clone a small window for the viewer
    if renderers.current.imageSampler_type == 3
    then( renderers.current.output_useram = true )
    else( renderers.current.output_useram = false )

    -- Auto assign the correct deadline limit if deadline has been initialized
    if SMTDSettings != undefined and SMTDSettings.LimitGroupsToUse != undefined 
    then(
        append SMTDSettings.LimitGroupsToUse "v-ray 7"                                  -- adds "v-ray 7" to the list of limits
        SMTDSettings.LimitGroupsToUse = (makeUniqueArray SMTDSettings.LimitGroupsToUse) -- Removes any duplicates from the list
    )else()
)

-- Postrender Globals
-- When rendering Production, these settings will be restored
function postRenderAction_ProductionGlobals =
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

-- RENDER ELEMENTS OPERATOR

-- Prerender Render Elements
function preRenderAction_RenderElements =
(
    -- localize this variable for readability and Collect the render elements node from LPM
    Vray7_RestoreData           = LPM_RenderDispatchRestoreData
    vrayRenderElementsNode      = LPM_Fun.firstChildByType LPM_RenderDispatchThePass "vrayRenderElements"

    -- Early exit if there is no render elements operator on this pass, or it is disabled
    if vrayRenderElementsNode == undefined then ( return undefined )
    if vrayRenderElementsNode.active == False then ( return undefined )

    -- Class for holding render element states, to be used for storing enabled / disabled state for restore
    struct elementObjStr
    (
        animhandle = undefined,
        name = "",
        enabled = false
    )

    -- Get the render element manager, and clear out any previous references to existing elements
    re                  = maxOps.GetCurRenderElementMgr()
    existingElements    = #()

    -- Go through all of the render elements in the render element manager 'REM'
    -- NOTE: render elements start at index 0, unlike most arrays in 3dsMax
    for rem_elementId in 0 to ( re.NumRenderElements() - 1 ) do
    (
        -- Get the render element from the REM, and turn it off
        rem_element                 = ( re.GetRenderElement rem_elementId )

        -- Create an elementObj to store the states for restoring later.
        elementObj                  = elementObjStr()
        elementObj.animhandle       = gethandlebyanim rem_element
        elementObj.name             = rem_element.elementName
        elementObj.enabled          = rem_element.vrayVFB

        -- Add it to the array
        append existingElements elementObj

        -- After recording its state, turn it off
        rem_element.vrayVFB     = false

        -- Then go through all of the active elements enabled in the LPM override 'OVR'
        for ovr_element in vrayRenderElementsNode.activeElement do
        (
            -- If the 'OVR' element matches name with one of the 'REM' names, turn it on.
            if ( ovr_element ) == ( rem_element.elementName ) then ( rem_element.vrayVFB = true )
        )
    )

    -- Put the collected element definitions in the restore data object for later
    Vray7_RestoreData.renderElements_active = existingElements
)

-- Postrender Render Elements
-- Restores each render element's .vrayVFB state to its pre-render value.
-- V-Ray's VFB may internally reset these after rendering, but we cannot rely on that
-- undocumented behavior across versions or render modes (local vs Deadline farm).
-- Setting .vrayVFB to its saved value is idempotent — safe whether V-Ray already restored it or not.
-- This is critical for optionRE and other elements that control compression and output format.
function postRenderAction_RenderElements =
(
    Vray7_RestoreData = LPM_RenderDispatchRestoreData

    -- Nothing to restore if pre-render never populated the dispatch data (e.g. a preview
    -- export that skipped the renderer dispatch entirely)
    if Vray7_RestoreData == undefined then return undefined

    -- Nothing to restore if no elements were captured during pre-render
    if Vray7_RestoreData.renderElements_active == undefined then return undefined
    if Vray7_RestoreData.renderElements_active.count == 0 then return undefined

    -- Restore each element's vrayVFB state to its pre-render value
    for elementObj in Vray7_RestoreData.renderElements_active do
    (
        try
        (
            local elem = getAnimByHandle elementObj.animhandle
            if elem != undefined then
            (
                elem.vrayVFB = elementObj.enabled
            )
        )catch( format "LPM warning: could not restore render element: %\n" elementObj.name )
    )
)

-- UTILITIES

-- Add optionRE metadata to the .exr files
function preRenderAction_OptionRECustomMetadata = 
(
    function applyExrMetadataToAllOptionRes arg_string = (

        -- Get the render element manager
        re                  = maxOps.GetCurRenderElementMgr()   
        existingElements    = #()

        -- loop through the elemnts looking for the right one
        for i in 0 to ( re.NumRenderElements() - 1 ) do         
        (
            curElement                  = ( re.GetRenderElement i )

            -- return the element if its name matches the arg_name
            --if curElement.elementName   == arg_name then( return curElement )
            if (classof curElement) == VRayOptionRE 
            then 
            (
                curElement.exr_metadata = arg_string
            )
        )
    )

    newStr = ""

    try( newStr += ( "MAKE3dsMaxMetadata_maxFileName = "                     + ( maxFileName as string ) )                                      )catch()
    try( newStr += ( "; MAKE3dsMaxMetadata_maxFilePath = "                   + ( maxFilePath as string ) )                                      )catch()
    try( newStr += ( "; MAKE3dsMaxMetadata_localTime = "                     + ( localTime as string ) )                                        )catch()
    try( newStr += ( "; MAKE3dsMaxMetadata_fileOutGamma = "                  + ( fileOutGamma as string ) )                                     )catch()
    try( newStr += ( "; MAKE3dsMaxMetadata_rendOutputFilename = "            + ( rendOutputFilename as string ) )                               )catch()
    try( newStr += ( "; MAKE3dsMaxMetadata_submitUsername = "                + ( sysInfo.username as string ) )                                 )catch()
    try( newStr += ( "; MAKE3dsMaxMetadata_submitComputername = "            + ( sysInfo.computername as string ) )                             )catch()
    try( newStr += ( "; MAKE3dsMaxMetadata_rendApertureWidth = "             + ( getRendApertureWidth() as string ) )                           )catch()
    try( newStr += ( "; MAKE3dsMaxMetadata_rendImageAspect = "               + ( getRendImageAspect() as string ) )                             )catch()
    try( newStr += ( "; MAKE3dsMaxMetadata_cameraFocalLenthMM = "            + ( LPM_Root.renderCamera.focal_length_mm as string ) )            )catch()
    try( newStr += ( "; MAKE3dsMaxMetadata_cameraShutterLenthFrames = "      + ( LPM_Root.renderCamera.shutter_length_frames as string ) )      )catch()
    try( newStr += ( "; MAKE3dsMaxMetadata_cameraShutterOffsetFrames = "     + ( LPM_Root.renderCamera.shutter_offset_frames as string ) )      )catch()
    try( newStr += ( "; MAKE3dsMaxMetadata_V-Ray_imageSampler_shadingRate = "+ ( renderers.current.imageSampler_shadingRate as string ) )       )catch()
    try( newStr += ( "; MAKE3dsMaxMetadata_V-Ray_twoLevel_baseSubdivs = "    + ( renderers.current.twoLevel_baseSubdivs as string ) )           )catch()
    try( newStr += ( "; MAKE3dsMaxMetadata_V-Ray_twoLevel_fineSubdivs = "    + ( renderers.current.twoLevel_fineSubdivs as string ) )           )catch()
    try( newStr += ( "; MAKE3dsMaxMetadata_V-Ray_twoLevel_threshold = "      + ( renderers.current.twoLevel_threshold as string ) )             )catch()

    -- apply the metadata string to all option RE render elements
    applyExrMetadataToAllOptionRes newStr
)

-- TODO:
-- CAMERA OVERSCAN OPERATOR


-- PROGRAM FLOW

-- Pre-Render Action for Production
function preRenderAction_Production =
(
    -- Construct object for storing pre-render state for use for restoring later
    LPM_RenderDispatchRestoreData = Vray7_RestoreDataStr()

    -- call each of the prerender functions
    preRenderAction_ProductionGlobals()             -- For all global actions
    preRenderAction_RenderElements()                -- For all Render Elements Operator
    preRenderAction_OptionRECustomMetadata()        -- Add additional metadata to the .exr files through the option RE render element for vray
)

-- Pre-Render Action for Preview
function preRenderAction_Preview =
(
    -- Construct object for storing pre-render state for use for restoring later
    LPM_RenderDispatchRestoreData = Vray7_RestoreDataStr()

    -- Execute The Render Elements Prerender
    preRenderAction_RenderElements()
)

-- Post-Render Action for Production
function postRenderAction_Production =
(
    --Calls Data from the global to check the restorepoint flag
    Vray7_RestoreData = LPM_RenderDispatchRestoreData

    --Only runs the Post render action if Settings were altered in the prerender based on the restorepoint flag
    if LPM_RenderDispatchAction != #PreviewRender then
    (
        try( postRenderAction_ProductionGlobals() )catch() -- TODO: remove later????
    )

    -- call each of the postrender functions
    postRenderAction_RenderElements()
)

function localRenderAction =
(
    theShot = LPM_RenderDispatchTheShot

    SetQuietMode LPM_Root.quietMode
    cp=LPM_Fun.firstChildByType theShot "commonProps"

    if cp._rendTimeType == 1 then
    (
        render fromframe:currentTime toframe:currentTime
    )

    if cp._rendTimeType == 2 then
    (
        render fromframe:animationRange.start toframe:animationRange.end
    )

    if cp._rendTimeType == 3 then
    (
        render fromframe:( cp._rendStart) toframe:( cp._rendEnd )
    )

    if cp._rendTimeType == 4 then
    (

        frames = #()
        parts = filterString cp._rendPickupFrames "," -- split on commas
        
        for part in parts do
        (
            if findString part "-" != undefined then
            (
                rangeParts = filterString part "-"
                if rangeParts.count == 2 then
                (
                    startVal    = rangeParts[1] as integer
                    endVal      = rangeParts[2] as integer
                    for i       = startVal to endVal do append frames i
                )
            )
            else ( append frames (part as integer) )
        )
        
        -- Render each of the frames from the built list
        for frame in frames do ( render fromframe:(frame) toframe:(frame) )
    )
)

-- API HOOKS

-- Cases for each of the methods a dispatch can be called.
if LPM_RenderDispatchAction == #preRender       then preRenderAction_Production()
if LPM_RenderDispatchAction == #PreviewRender   then preRenderAction_Preview()
if LPM_RenderDispatchAction == #LocalRender     then localRenderAction()
if LPM_RenderDispatchAction == #postRender      then postRenderAction_Production()