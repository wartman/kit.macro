package kit.macro;

import haxe.macro.Expr;

enum abstract HookName(String) from String {
	final Init = 'init';
	final LateInit = 'init:late';
	// @todo: more?
}

typedef HookProp = {
	public final name:String;
	public final type:ComplexType;
	public final optional:Bool;
}

class Hook {
	public final name:HookName;

	var exprs:Array<Expr> = [];
	var props:Array<Field> = [];

	public function new(name) {
		this.name = name;
	}

	public function addExpr(...newExprs:Expr) {
		exprs = exprs.concat(newExprs);
		return this;
	}

	public function addProp(...newProps:HookProp) {
		var pos = (macro null).pos;
		var fields:Array<Field> = newProps.toArray().map(f -> ({
			name: f.name,
			kind: FVar(f.type),
			meta: f.optional ? [{name: ':optional', pos: pos}] : [],
			pos: pos
		} : Field));
		props = props.concat(fields);
		return this;
	}

	public function getExprs() {
		return exprs;
	}

	public function getProps() {
		return props;
	}
}
