-- 3/16/2021 Aaron Dabelow theonlyaaron@gmail.com

struct renderImage_RestoreDataStr
(
    renderCameraOriginal = undefined, -- for backing up LPM_Root.renderCamera
    newCamAnimhanlde     = undefined,
    fovOverride          = undefined,
    resXOriginal         = undefined,
    resYOriginal         = undefined,
    resOverride          = undefined,
    resXOverride         = undefined,
    resYOverride         = undefined,
    null                 = undefined
 )

function renderImage_Override_PreRender =
(
    -- Fetch the global variable and assign the current state to it
    curCam = LPM_Root.renderCamera -- get the current camera from LPM
    newCam = copy curCam
    newCam.name = ( curCam.name + "_temp-overscan" )

    -- Store the animhandle of the new camera, to be deleted later
    LPM_OperatorData.renderImage.newCamAnimhanlde  = getHandleByAnim newCam
    -- Store the original camera, to restore it to the render camera later
    LPM_OperatorData.renderImage.renderCameraOriginal = curCam
    -- get the FOV from the override
    curFov = LPM_OperatorData.renderImage.fovOverride

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
            newCam.specify_fov = off
            paramWire.connect curCam.baseObject[#Lens_Focal_Length_mm] newCam.baseObject[#Lens_Focal_Length_mm] ( "Lens_Focal_Length_mm  * " + ( ( 1 / curFov ) as string ) )
            )
    )

    -- Set as the camera to actually render from
    LPM_Root.renderCamera = newCam

    -- TODO:?
    -- Store the original resoultion
    LPM_OperatorData.renderImage.resXOriginal = renderHeight
    LPM_OperatorData.renderImage.resYOriginal = renderWidth
    print "---original res----"
    print renderHeight
    print renderWidth

    -- Set the desired resolution
    renderHeight = LPM_OperatorData.renderImage.resXOverride
    renderWidth  = LPM_OperatorData.renderImage.resYOverride
    print "---overscan res----"
    print renderHeight
    print renderWidth

)

function renderImage_Override_PostRender =
(
    -- reset the originalRenderCamera
    LPM_Root.renderCamera = LPM_OperatorData.renderImage.renderCameraOriginal

    -- Delete the new camera that was created
    try(
		curDelete = getAnimByHandle LPM_OperatorData.renderImage.newCamAnimhanlde
        delete curDelete
	)catch()

    -- TODO:
    -- reset resolution
    renderHeight = LPM_OperatorData.renderImage.resXOriginal
    renderWidth  = LPM_OperatorData.renderImage.resYOriginal
)

function curPrerenderAction =
(
    print "== renderImage PreRenderAction =="

    -- Construct object for storing pre-render state for use for restoring later
    LPM_OperatorData.renderImage = renderImage_RestoreDataStr()

    -- call each of the prerender functions
    renderImage_Override_PreRender() -- TODO: turn this back on once testing is complete
)

function curPostRenderAction =
(
    print "== renderImage PostRenderAction =="

    -- call each of the postrender functions
    renderImage_Override_PostRender()
)

--if LPM_RenderDispatchAction == #preRender then curPrerenderAction()
--if LPM_RenderDispatchAction == #postRender then curPostRenderAction()
--if LPM_RenderDispatchAction == #PreviewRender then()
