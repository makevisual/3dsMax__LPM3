-- 3/16/2021 Aaron Dabelow theonlyaaron@gmail.com

struct cameraOverscan_RestoreDataStr
(
    newCamAnimhanlde     = undefined,
    fovOverride          = undefined,
    resXOriginal         = undefined,
    resYOriginal         = undefined,
    resOverride          = undefined,
    resXOverride         = undefined,
    resYOverride         = undefined,
    null                 = undefined
 )

fn getExportCamera =
(
    local curCam = undefined
    if isValidNode LPM_Root.renderCamera then
        curCam = LPM_Root.renderCamera
    if curCam == undefined then
    (
        messagebox "No render camera set for export."
        return undefined
    )
    return curCam
)

function cameraOverscan_Override_PreRender =
(
    -- Fetch the global variable and assign the current state to it
    curCam = getExportCamera()
    if curCam == undefined then return false
    newCam = copy curCam
    newCam.name = ( curCam.name + "_temp-overscan" )

    -- Store the animhandle of the new camera, to be deleted later
    LPM_OperatorData.cameraOverscan.newCamAnimhanlde  = getHandleByAnim newCam
    curFov = LPM_OperatorData.cameraOverscan.fovOverride

    -- Wire the FOV 
    case ( classof curCam ) of
    (
        Freecamera:
            (
            print "Free"
            paramWire.connect curCam.baseObject[#fov] newCam.baseObject[#fov] ( "fov * " + ( curFov as string ) )
            )
        Targetcamera:
            (
            print "Target"
            paramWire.connect curCam.baseObject[#fov] newCam.baseObject[#fov] ( "fov * " + ( curFov as string ) )
            )
        Physical:
            (
            print "PHYS"
            paramWire.connect curCam.baseObject[#fov] newCam.baseObject[#fov] ( "fov * " + ( curFov as string ) )
            )
    )
    

    -- TODO:
    -- Set as the camera to actually render from 
    -- Set as the resolution to actually render 
    
)

function cameraOverscan_Override_PostRender =
(
    -- Delete the new camera that was created 
    curDelete = getAnimByHandle LPM_OperatorData.cameraOverscan.newCamAnimhanlde 
    --delete curDelete

    -- TODO:
    -- reset resolution
)

function curPrerenderAction =
(
    print "== cameraOverscan PreRenderAction =="

    -- Construct object for storing pre-render state for use for restoring later
    LPM_OperatorData.cameraOverscan = cameraOverscan_RestoreDataStr()

    -- call each of the prerender functions
    cameraOverscan_Override_PreRender()
)

function curPostRenderAction =
(
    print "== cameraOverscan PostRenderAction =="

    -- call each of the postrender functions
    cameraOverscan_Override_PostRender()
)

if LPM_RenderDispatchAction == #preRender then curPrerenderAction()
if LPM_RenderDispatchAction == #postRender then curPostRenderAction()
