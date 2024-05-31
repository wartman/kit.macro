package kit.macro.step;

import kit.macro.Hook;
import haxe.macro.Expr;

using kit.macro.Tools;

class AutoInitializedFieldBuildStep implements BuildStep {
	public final priority:Priority = Before;

	final options:{
		public final meta:String;
		public final ?hook:HookName;
	};

	public function new(options) {
		this.options = options;
	}

	public function apply(builder:ClassBuilder) {
		var fields = builder.findFieldsByMeta(':${options.meta}');
		for (field in fields) {
			parseField(builder, field);
		}
	}

	function parseField(builder:ClassBuilder, field:Field) {
		switch field.kind {
			case FVar(t, e):
				var name = field.name;
				builder.hook(options.hook ?? Init)
					.addProp({name: name, type: t, optional: e != null})
					.addExpr(if (e == null) {
						macro this.$name = props.$name;
					} else {
						macro if (props.$name != null) this.$name = props.$name;
					});
			default:
				field.pos.error('Invalid field for :${options.meta}');
		}
	}
}
