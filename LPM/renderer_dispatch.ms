-- The purpose of this code is to call renderer specific overrides that could be destructive to other workflows.
-- Needs LPM_RenderDispatchAction defined as #preRender or #postRender when the dispatch is called, for the subsequent scripts to work

curRenderer = ( renderers.current as string )

case curRenderer of
(
    default                                                 : ( messagebox("Render Engine not found in render Dispatch!"))
    "Default_Scanline_Renderer:Default_Scanline_Renderer"   : ( filein ( LPM_Dir + @"renderers\" +"Default_Scanline_Renderer.ms" ) )
    "V_Ray_7_Hotfix_1:V_Ray_7_Hotfix_1"                     : ( filein ( LPM_Dir + @"renderers\" +"renderer_vray7.00.04.ms" ) )
)