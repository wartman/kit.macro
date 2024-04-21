package kit.macro.builder;

import haxe.macro.Expr;

using kit.macro.Tools;

class AutoInitializedFieldBuilder implements Builder {
	public final priority:BuilderPriority = Before;

	final meta:String;

	public function new(meta) {
		this.meta = meta;
	}

	public function apply(builder:ClassBuilder) {
		var fields = builder.findFieldsByMeta(':$meta');
		for (field in fields) {
			parseField(builder, field);
		}
	}

	function parseField(builder:ClassBuilder, field:Field) {
		switch field.kind {
			case FVar(t, e):
				var name = field.name;
				builder.addProp(ConstructorProperty, {name: name, type: t, optional: e != null});
				builder.addHook(InitHook, if (e == null) {
					macro this.$name = props.$name;
				} else {
					macro if (props.$name != null) this.$name = props.$name;
				});
			default:
				field.pos.error('Invalid field for :$meta');
		}
	}
}
