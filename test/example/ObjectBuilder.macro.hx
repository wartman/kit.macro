package example;

import kit.macro.builder.*;
import kit.macro.ClassBuilderFactory;

final builder = new ClassBuilderFactory([
	new AutoInitializedFieldBuilder('auto'),
	new PropertyBuilder(),
	new ConstructorBuilder(),
	new JsonSerializerBuilder()
]);

function build() {
	return builder.fromContext().export();
}
