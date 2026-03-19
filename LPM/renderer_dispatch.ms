-- The purpose of this code is to call renderer specific overrides that could be destructive to other workflows.
-- Needs LPM_RenderDispatchAction defined as #preRender or #postRender when the dispatch is called, for the subsequent scripts to work

curRenderer = ( renderers.current as string )

if matchPattern curRenderer pattern:"Default_Scanline_Renderer*"
then ( filein ( LPM_Dir + @"renderers\" + "Default_Scanline_Renderer.ms" ) )
else if matchPattern curRenderer pattern:"V_Ray_7*"
then ( filein ( LPM_Dir + @"renderers\" + "renderer_vray7.20.08.ms" ) )
else ( format "WARNING: LPM renderer_dispatch — unrecognized renderer: %\n" curRenderer )
