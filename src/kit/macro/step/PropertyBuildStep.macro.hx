package kit.macro.step;

import haxe.macro.Expr;

using kit.macro.Tools;

class PropertyBuildStep implements BuildStep {
	public final priority:Priority = Before;

	public function new() {}

	public function apply(builder:ClassBuilder) {
		var fields = builder.findFieldsByMeta(':prop');
		for (field in fields) {
			parseField(builder, field);
		}
	}

	function parseField(builder:ClassBuilder, field:Field) {
		switch field.kind {
			case FVar(t, e):
				if (e != null) {
					e.pos.error('Expressions are not allowed in :prop fields');
				}

				var name = field.name;
				var getterName = 'get_$name';
				var setterName = 'set_$name';
				var meta = field.getMetadata(':prop');

				switch meta?.params {
					case [macro get = $expr]:
						field.kind = FProp('get', 'never', t);
						builder.add(macro class {
							function $getterName():$t return $expr;
						});
					case [macro set = $expr]:
						field.kind = FProp('never', 'set', t);
						builder.add(macro class {
							function $setterName(value : $t):$t return $expr;
						});
					case [macro get = $getter, macro set = $setter] | [macro set = $setter, macro get = $getter]:
						field.kind = FProp('get', 'set', t);
						builder.add(macro class {
							function $getterName():$t return $getter;

							function $setterName(value : $t):$t return $setter;
						});
					case []:
						field.pos.error('Expected a getter and/or setter');
					default:
						field.pos.error('Invalid arguments for :prop');
				}
			default:
				field.pos.error('Invalid field for :prop');
		}
	}
}
