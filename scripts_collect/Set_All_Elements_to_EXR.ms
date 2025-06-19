tmp_cur_rend_man = maxOps.GetCurRenderElementMgr()

for i = 1 to tmp_cur_rend_man.NumRenderElements() do
(
	tmp_cur_rend_el = tmp_cur_rend_man.GetRenderElement (i - 1)
	print tmp_cur_rend_el
	tmp_cur_rend_man.SetRenderElementFilename (i - 1) "Z:\\2014\\1.exr"
)
 
SMTDFunctions.RebuildRenderElements()