package fixture;

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
