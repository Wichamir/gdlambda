##########################################
##               GDLambda               ##
##########################################
## MIT License                          ##
## Copyright (c) 2022 Wichamir          ##
## https://github.com/Wichamir/gdlambda ##
##########################################


# GDLambda is a small, pure GDScript library adding lambdas
# and basic functional programming features to Godot 3.
class_name gdl extends Reference


# Looking for examples?
# See README.md and examples.gd

# Variables and functions prefixed with an underscore should be
# considered (by convention) as private and should not be accessed
# outside of their respective classes.


# warnings-disable


# gdl.lambda
# Shorthand for gdl.Lambda.create
# Use to instance lambdas.
static func lambda(source: String, captured: Dictionary = {}) -> Lambda:
	return Lambda.create(source, captured)


# gdl.arrayex
# Shorthand for gdl.ArrayEx.create
# Use to wrap array to access features like filter, reduce, scan etc.
static func arrayex(array: Array) -> ArrayEx:
	return ArrayEx.create(array)


# gdl.chars
# Converts a String into an Array of characters.
static func chars(string: String) -> Array:
	var result := []
	for c in string:
		result.append(c)
	return result


# gdl.Lambda
# Implements a lambda functionality by parsing source
# code string into a GDScript instance.
class Lambda extends Reference:
	const FUNCNAME_DEFAULT := "_" # used as a name for nameless lambdas
	
	
	var _funcname := ""
	var _script: GDScript = null
	var _instance: Reference = null
	
	
	# gdl.Lambda.create
	# Factory for gdl.Lambda
	static func create(source: String, captured: Dictionary = {}) -> Lambda:
		var result := Lambda.new()
		
		# find lambda's name
		var start := source.find("func") + 4
		var end := source.find("(")
		result._funcname = source.substr(start, end - start).strip_edges()
		
		# insert default name if lambda is nameless
		if result._funcname.empty():
			source = source.insert(
				source.find("("),
				" " + FUNCNAME_DEFAULT
			)
			result._funcname = FUNCNAME_DEFAULT
		
		# parse captured variables
		for name in captured:
			for c in name:
				var code := ord(c)
				assert(
					(code >= ord('A') and code <= ord('Z')) or
					(code >= ord('a') and code <= ord('z')) or
					(code == ord('_')) or
					(code >= ord('0') and code <= ord('9') and name[0] != c),
					"[GDLambda] Captured variable name '%s' includes invalid characters!" % name
				)
			source = source.insert(0, "var %s\n" % name)
		
		# parse source code
		result._script = GDScript.new()
		result._script.source_code = source
		var error := result._script.reload()
		assert(
			 error == OK,
			"[GDLambda] Script reload failed. Error code: %d. Source code:\n%s" % [
				error, result._script.source_code
			]
		)
		
		# create instance
		result._instance = result._script.new()
		
		# set captured variables
		for name in captured:
			result._instance.set(name, captured[name])
		
		return result
	
	
	# gdl.Lambda.get_funcname
	# Getter for gdl.Lambda._funcname
	func get_funcname() -> String:
		return _funcname
	
	
	# gdl.Lambda.get_source
	# Getter for gdl.Lambda._script.source_code
	func get_source() -> String:
		return _script.source_code
	
	
	# gdl.Lambda.get_instance
	# Getter for gdl.Lambda._instance
	func get_instance() -> Reference:
		return _instance
	
	
	# gdl.Lambda.as_funcref
	# Returns a FuncRef instance pointing to the method defined in _instance.
	func as_funcref() -> FuncRef:
		return funcref(_instance, _funcname)
	
	
	# gdl.Lambda.execute
	# Executes a lambda.
	func execute(args: Array = []): # -> Variant
		return _instance.callv(_funcname, args)


# gdl.ArrayEx
# Wrapper class for built-in array.
# Implements various functional programming features like filter, reduce, scan etc.
# Some of them are present in Godot 4.
class ArrayEx extends Reference:
	var _array: Array = []
	
	
	func _to_string() -> String:
		return String(_array)
	
	
	# gdl.ArrayEx.create
	# Factory for gdl.ArrayEx
	static func create(array: Array) -> ArrayEx:
		var result := ArrayEx.new()
		result._array = array
		return result
	
	
	# gdl.ArrayEx.inverted
	# Returns a copy of gdl.ArrayEx with reversed order of elements.
	func inverted() -> ArrayEx:
		var result := _array.duplicate()
		result.invert()
		return ArrayEx.create(result)
	
	
	# gdl.ArrayEx.any
	# Returns true if at least one element meets the condition,
	# otherwise false.
	func any(condition: Lambda) -> bool:
		for i in _array:
			if condition.execute([i]):
				return true
		return false
	
	
	# gdl.ArrayEx.all
	# Returns true if all elements meet the condition, otherwise false.
	func all(condition: Lambda) -> bool:
		for i in _array:
			if not condition.execute([i]):
				return false
		return true
	
	
	# gdl.ArrayEx.filter
	# Returns a copy of gdl.ArrayEx containing only the elements,
	# for which the specified method returns true.
	func filter(method: Lambda) -> ArrayEx:
		var result := []
		for i in _array:
			if method.execute([i]):
				result.append(i)
		return ArrayEx.create(result)
	
	
	# gdl.ArrayEx.map
	# Returns a copy of gdl.ArrayEx with each element
	# replaced by the result of a specified method.
	func map(method: Lambda) -> ArrayEx:
		var result := []
		for i in _array:
			result.append(method.execute([i]))
		return ArrayEx.create(result)
	
	
	# gdl.ArrayEx.reduce
	# Reduces an array into a single value, accum being the starting value.
	func reduce(method: Lambda, accum): # -> Variant
		for i in _array:
			accum = method.execute([accum, i])
		return accum
	
	
	# gdl.ArrayEx.scan
	# Performs a left scan operation on a copy of ArrayEx.
	# To perform a scan right operation invert the array beforehand.
	func scan(method: Lambda, initial) -> ArrayEx:
		var result := []
		if _array.size() > 0:
			result.append(method.execute([_array[0], initial]))
		for i in range(1, _array.size()):
			result.append(method.execute([_array[i], result[i - 1]]))
		return ArrayEx.create(result)
	
	
	# gdl.ArrayEx.unwrap
	# Converts a gdl.ArrayEx back into a built-in Array.
	func unwrap() -> Array:
		return _array

