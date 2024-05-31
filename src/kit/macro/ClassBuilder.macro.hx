package kit.macro;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

using Kit;
using Lambda;
using haxe.macro.Tools;

class ClassBuilder {
	public static function fromContext() {
		return new ClassBuilder({
			type: Context.getLocalType(),
			fields: Context.getBuildFields(),
			steps: []
		});
	}

	final type:Type;
	final steps:Array<BuildStep>;
	final fields:ClassFieldCollection;

	var hookCollection:Array<Hook> = [];

	public function new(options) {
		this.steps = options.steps;
		this.fields = new ClassFieldCollection(options.fields);
		this.type = options.type;
	}

	public function hook(name):Hook {
		return hookCollection
			.find(hook -> hook.name == name)
			.toMaybe()
			.or(() -> {
				var hook = new Hook(name);
				hookCollection.push(hook);
				hook;
			});
	}

	public function getType() {
		return type;
	}

	public function getComplexType() {
		return type.toComplexType();
	}

	public function getTypePath():TypePath {
		var cls = getClass();
		return {
			pack: cls.pack,
			name: cls.name
		};
	}

	public function getClass() {
		return switch type {
			case TInst(t, _): t.get();
			default: throw 'assert';
		}
	}

	public inline function getFields() {
		return fields.getFields();
	}

	public function add(t:TypeDefinition) {
		fields.add(t);
		return this;
	}

	public function addField(f:Field) {
		fields.addField(f);
		return this;
	}

	public function findField(name:String):Maybe<Field> {
		return fields.findField(name);
	}

	public function findFieldsByMeta(name:String):Array<Field> {
		return fields.findFieldsByMeta(name);
	}

	public function export() {
		apply(Before);
		apply(Normal);
		apply(Late);
		return fields.export();
	}

	function apply(priority:Priority) {
		var selected = steps.filter(b -> b.priority == priority);
		for (builder in selected) builder.apply(this);
	}
}
