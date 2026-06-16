-- Routes a viewport-capture export to the selected preview backend.
-- Mirrors renderer_dispatch.ms: the caller (LPM_renderPass, #tyPreview branch) sets the
-- LPM_RenderDispatch* globals and LPM_PreviewBackend, then fileins this file.
--
-- Scene state (visibility, camera, frame range, resolution, script operators) has already
-- been applied by fnPreRenderAction; backends only translate that state into their own
-- export call. Adding a future backend (e.g. "viewport") means one more branch + file here.

if LPM_PreviewBackend == "tyPreview"
then ( filein ( LPM_Dir + @"previews\preview_tyPreview.ms" ) )
else ( format "WARNING: LPM preview_dispatch — unknown preview backend: %\n" LPM_PreviewBackend )
