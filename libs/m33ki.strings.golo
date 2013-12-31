module m33ki.strings

augment java.lang.String {
  # interpolate
	function T = |this, dataName, data| {
		let tpl = gololang.TemplateEngine()
							:compile("<%@params "+dataName+" %> "+this)
		return tpl(data)
	}
}