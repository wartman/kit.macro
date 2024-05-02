package fixture;

import kit.macro.parser.*;
import kit.macro.ClassBuilderFactory;

final builder = new ClassBuilderFactory([
	new AutoInitializedFieldParser({
		meta: 'auto',
		hook: Init
	}),
	new ConstructorParser({
		hook: Init
	}),
	new PropertyParser(),
	new JsonSerializerParser()
]);

function build() {
	return builder.fromContext().export();
}
