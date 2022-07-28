# GDLambda

![icon](icon.png)

GDLambda is a small, pure GDScript library adding lambdas
and basic functional programming features to Godot 3.

Most of these are already available in GDScript 2.0, but at the time of writing this Godot 4 is still not a stable release.

## Installation

Copy GDLambda directory into addons directory of your project.

## Usage and examples

### Creating and executing lambdas

```gdscript
# access GDLambda functions and classes using gdl class
var mylambda := gdl.lambda("func(): print('Hello from lambda!')")

# optionally you can assign a name to your lambda
var mylambda_but_named := gdl.lambda("func l(): print('Hello from lambda named l!')")

# execute lambdas using the execute method
mylambda.execute()
mylambda_but_named.execute()
```

### Passing arguments and returning values

```gdscript
var squared := gdl.lambda("func(x): return x*x")

print(
    squared.execute([4]) # pass arguments using array
)

print(
    squared.as_funcref().call_func(4) # or directly using funcref
)
```

### Multiline lambdas

```gdscript
# it's advised to keep your lambdas short
# writing multiline lambdas is probably not the best of ideas in most cases

# using escape characters (very unreadable, discouraged)
var l1 := gdl.lambda("func(x):\n\tprint(x)\n\treturn x*x")
var r1 := l1.execute([8]) as int

# using docstrings (more readable)
var l2 := gdl.lambda(
"""
func(x):
	print(x)
	return x*x
"""
)
var r2 := l2.execute([8]) as int

assert(r1 == r2) # 64 == 64
```

### Using lambdas for sorting

```gdscript
var data := [3, 1, 2]

var sorter := gdl.lambda("func(a, b): return a < b")
data.sort_custom(
    sorter.as_funcref(), # convert lambda to funcref so that you can pass
    "call_func"          # multiple arguments without using array
)

print(data) # [1, 2, 3]
```

### Using lambdas with signals

```gdscript
var persistent_lambda: gdl.Lambda
func using_lambdas_with_signals() -> void:
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
```

### Capturing environment

```gdscript
# variables can be captured only by copy
var answer := 42
var answer_printer := gdl.lambda(
    "func(): print(a)", # lambda prints variable a
    {"a" : answer} # capture variable answer by copy and give it a name using dictionary
)
answer_printer.execute()
```

### Array wrapper

```gdscript
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
```

### Practical example (get only child nodes of a specified type)

```gdscript
func get_children_by_type(node: Node, Type) -> Array:
	# use backslashes to continue the line in the next one
	return gdl.arrayex(node.get_children()) \
		.filter(gdl.lambda("func(n): return node is T", {"T":Type})) \
		.unwrap()
```

## License

See [LICENSE](LICENSE)