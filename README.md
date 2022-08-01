# GDLambda

![icon](icon.png)

GDLambda is a small, pure GDScript library adding lambdas
and basic functional programming features to Godot 3.

Most of these are already available in GDScript 2.0, but at the time of writing this Godot 4 is still not a stable release.

## Installation

Copy GDLambda directory into addons directory of your project.

## Usage

```gdscript
var lambda := gdl.lambda("func(x): return x*x*x")
print(lambda.execute(4)) # 64
```

```gdscript
var units := get_children()
units.sort_custom( # sort units by their initiative
    gdl.lambda("func(a, b): return a.initiative > b.initiative").as_funcref(),
    "call_func"
)
```

See [examples.gd](examples.gd).

## Is it safe?

Generally yes. Just DON'T concatenate lambda source with any kind of user input.
Doing so can be highly dangerous and allow cheating or remote code execution, which is a huge no no.
Think of [eval](https://www.geeksforgeeks.org/is-javascripts-eval-evil/) method from JavaScript.
Godot's built-in [Expression](https://docs.godotengine.org/en/stable/tutorials/scripting/evaluating_expressions.html)
has a similar problem, when you want to "capture" its environment,
although it can't access any built-in classes, only methods, variables and constants of a captured object 
(which can still cause some considerable issues, when implemented in a wrong way),
whereas lambdas can access and instance any built-in class as well as singletons.

To be safe:
If you want to have an access to any external variables ONLY pass them as arguments or capture them using Dictionary
(see [examples.gd](examples.gd)) and NEVER insert any user-defined strings into lambda source
(again, think of eval from JavaScript).

## Is it production ready?

I don't know lol.
I just wrote it for fun in a few hours and it turned out to be less confusing and error-prone than I initially imagined,
so I added comments here and there and a few examples and made this repository.
When Godot 4 is stable, this will be pretty much useless, but again, it's more of an experimental thing.

## License

See [LICENSE](LICENSE)