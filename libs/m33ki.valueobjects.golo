module m33ki.valueobjects

struct vo = { value }

function ValueObject = |value| -> vo(value)

augment m33ki.valueobjects.types.vo {

	function to_s = |this| -> this: value(): toString()

	function log = |this|{
	  println(this: value())
	  return this
	}

	function add = |this, n| {
		if n oftype m33ki.valueobjects.types.vo.class {
			this: value(this: value() + n: value())
		} else {
			this: value(this: value() + n)
		}
		return this
	}
	function substract = |this, n| {
		if n oftype m33ki.valueobjects.types.vo.class {
			this: value(this: value() - n: value())
		} else {
			this: value(this: value() - n)
		}
		return this
	}
	function multiply = |this, n| {
		if n oftype m33ki.valueobjects.types.vo.class {
			this: value(this: value() * n: value())
		} else {
			this: value(this: value() * n)
		}
		return this
	}
	function divide = |this, n| {
		if n oftype m33ki.valueobjects.types.vo.class {
			this: value(this: value() / n: value())
		} else {
			this: value(this: value() / n)
		}
		return this
	}

	function increment = |this| -> this: add(1)
	function decrement = |this| -> this: substract(1)

	# === TODO: === Transaction with semaphores ?
	#
	# T(56):start():add(45):multiply(12):end()

}

