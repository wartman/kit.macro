package kit.macro;

import haxe.macro.Context;

class ClassBuilderFactory {
	final parsers:Array<Parser>;

	public function new(parsers) {
		this.parsers = parsers;
	}

	public function withParsers(...parser:Parser) {
		return new ClassBuilderFactory(parsers.concat(parser));
	}

	public function from(options) {
		return new ClassBuilder({
			type: options.type,
			fields: options.fields,
			parsers: parsers
		});
	}

	public function fromContext() {
		return from({
			fields: Context.getBuildFields(),
			type: Context.getLocalType(),
		});
	}
}
