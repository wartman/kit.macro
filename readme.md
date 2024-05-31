Kit Macro
=========

Macro tools for Haxe

Usage
-----

Kit Macros are build around composable `BuildSteps` which can be used to build classes.

```haxe
// in "ObjectBuilder.hx":
import kit.macro.step.*;
import kit.macro.ClassBuilderFactory;

final builder = new ClassBuilderFactory([
	new AutoInitializedFieldBuildStep({
		meta: 'auto',
		hook: Init
	}),
	new ConstructorBuildStep({
		hook: Init
	}),
	new PropertyBuildStep(),
	new JsonSerializerBuildStep()
]);

function build() {
	return builder.fromContext().export();
}
```

```haxe
// in "Object.hx"
@:autoBuild(ObjectBuilder.build())
interface Object {}
```

```haxe
// in "Main.hx"
function main() {
  var name = new Name({first: 'Guy', last: 'Manly'});
  trace(name.full);
  trace(name.toJson());
}

class Name implements Object {
	@:auto public final first:String;
	@:auto public final last:String;
	@:prop(get = first + ' ' + last) public final full:String;
}
```
