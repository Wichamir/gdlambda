extends SceneTree


## Run examples from terminal using:
## godot --no-window --script examples.gd


# warnings-disable


func _init() -> void:
	# run examples
	creating_and_executing_lambdas()
	passing_and_returning_values()
	multiline_lambdas()
	using_lambdas_for_sorting()
	yield(using_lambdas_with_signals(), "completed")
	capturing_environment()
	array_wrapper()
	
	quit()


func creating_and_executing_lambdas() -> void:
	print("Creating and executing lambdas:")
	
	# access GDLambda functions and classes using gdl class
	var mylambda := gdl.lambda("func(): print('Hello from lambda!')")
	
	# optionally you can assign a name to your lambda
	var mylambda_but_named := gdl.lambda("func l(): print('Hello from lambda named l!')")
	
	# execute lambdas using the execute method
	mylambda.execute()
	mylambda_but_named.execute()
	
	print()


func passing_and_returning_values() -> void:
	print("Passing arguments and returning values:")
	
	var squared := gdl.lambda("func(x): return x*x")
	
	print(
		squared.execute([4]) # pass arguments using array
	)
	
	print(
		squared.as_funcref().call_func(4) # or directly using funcref
	)
	
	print()


func multiline_lambdas() -> void:
	print("Multiline lambdas:")
	# it's advised to keep your lambdas short
	# writing multiline lambdas is probably not the best of ideas in most cases
	
	print("1) Using escape characters (very unreadable, discouraged)")
	var l1 := gdl.lambda("func(x):\n\tprint(x)\n\treturn x*x")
	var r1 := l1.execute([8]) as int
	
	print("2) Using docstrings (more readable)")
	var l2 := gdl.lambda(
"""
func(x):
	print(x)
	return x*x
"""
	)
	var r2 := l2.execute([8]) as int
	
	assert(r1 == r2)
	
	print()


func using_lambdas_for_sorting() -> void:
	print("Using lambdas for sorting:")
	
	var data := [3, 1, 2]
	print(data)
	
	var sorter := gdl.lambda("func(a, b): return a < b")
	data.sort_custom(
		sorter.as_funcref(), # convert lambda to funcref so that you can pass
		"call_func"          # multiple arguments without using array
	)
	
	print(data)
	
	print()


var persistent_lambda: gdl.Lambda
func using_lambdas_with_signals() -> void:
	print("Using lambdas with signals:")
	
	# lambdas inherit Reference
	# if you want them to persist, then you have to store them somewhere externally
	# for example:
	persistent_lambda = gdl.lambda("func(): print('timeout')")
	
	# then you can safely use them with signals
	create_timer(1.0).connect(
		"timeout",
		persistent_lambda,
		"execute"
	)
	
	yield(create_timer(1.1), "timeout") # wait for example to finish
	
	print()


func capturing_environment() -> void:
	print("Capturing environment:")
	
	# variables can be captured only by copy
	var answer := 42
	var answer_printer := gdl.lambda(
		"func(): print(a)", # lambda prints variable a
		{"a" : answer} # capture variable answer by copy and give it a name using dictionary
	)
	answer_printer.execute()
	
	print()


func array_wrapper() -> void:
	print("Array wrapper:")
	
	var data := range(10)
	
	# if you want to use functional programming features of Array,
	# then you have to wrap it in gdl.ArrayEx
	var wrapped := gdl.arrayex(data)
	
	wrapped = wrapped.filter(
		gdl.lambda("func(x): return bool(x % 2 == 0)") # get only even numbers
	)
	
	print(wrapped) # wrapped Array gets converted to String
	var result := wrapped.unwrap() # or you can unwrap an ArrayEx and get a built-in Array back
	print(result) # Array gets converted to String
	
	print()


func get_children_by_type(node: Node, Type) -> Array:
	# use backslashes to continue the line in the next one
	return gdl.arrayex(node.get_children()) \
		.filter(gdl.lambda("func(n): return node is T", {"T":Type})) \
		.unwrap()
