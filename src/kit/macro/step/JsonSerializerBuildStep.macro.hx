package kit.macro.step;

import haxe.macro.Expr;
import haxe.macro.Context;

using Lambda;
using haxe.macro.Tools;
using kit.macro.Tools;

typedef JsonSerializerBuildStepOptions = {
	public final ?constructorAccessor:Expr;
	public final ?returnType:ComplexType;
	public final ?customParser:(options:{
		name:String,
		type:ComplexType,
		parser:(access:Expr, name:String, t:ComplexType) -> JsonSerializerHook
	}) -> Maybe<JsonSerializerHook>;
}

typedef JsonSerializerHook = {
	public final serializer:Expr;
	public final deserializer:Expr;
}

class JsonSerializerBuildStep implements BuildStep {
	public final priority:Priority = Late;

	final options:JsonSerializerBuildStepOptions;

	public function new(?options) {
		this.options = options ?? {};
	}

	public function apply(builder:ClassBuilder) {
		var ret = options.returnType ?? builder.getComplexType();
		var fields = builder.hook(Init).getProps();
		var serializer:Array<ObjectField> = [];
		var deserializer:Array<ObjectField> = [];

		for (field in fields) {
			var result = parseField(builder, field);
			serializer.push({field: field.name, expr: result.serializer});
			deserializer.push({field: field.name, expr: result.deserializer});
		}

		var serializerExpr:Expr = {
			expr: EObjectDecl(serializer),
			pos: (macro null).pos
		};
		var deserializerExpr:Expr = {
			expr: EObjectDecl(deserializer),
			pos: (macro null).pos
		};

		var constructors = switch options.constructorAccessor {
			case null:
				var clsTp = builder.getTypePath();
				macro class {
					public static function fromJson(data:{}):$ret {
						return new $clsTp($deserializerExpr);
					}
				}
			case access:
				macro class {
					public static function fromJson(data:{}):$ret {
						return $access($deserializerExpr);
					}
				}
		};

		var clsParams = builder.getClass().params.toTypeParamDecl();
		var fromJson = constructors
			.getField('fromJson')
			.unwrap()
			.applyParameters(clsParams);
		builder.addField(fromJson);

		builder.add(macro class {
			public function toJson():Dynamic {
				return $serializerExpr;
			}
		});
	}

	function parseField(builder:ClassBuilder, prop:Field):JsonSerializerHook {
		var field:Field = switch builder.findField(prop.name) {
			case Some(field): field;
			case None: prop;
		}

		var def = switch field.kind {
			case FVar(_, e) if (e != null): e;
			default: macro null;
		}

		return switch field.kind {
			case FVar(t, _) | FProp(_, _, t):
				var meta = field.getMetadata(':json');
				var name = field.name;
				var pos = field.pos;
				var access:Expr = macro this.$name;

				if (meta != null) return switch meta.params {
					case [macro to = ${to}, macro from = ${from}] | [macro from = ${from}, macro to = ${to}]:
						var serializer = macro {
							var value = $access;
							if (value == null) {
								null;
							} else {
								$to;
							}
						};
						var deserializer = switch t {
							case macro :Array<$_>:
								macro {
									var value:Array<Dynamic> = Reflect.field(data, $v{name});
									if (value == null) value = [];
									$from;
								};
							default:
								macro {
									var value:Dynamic = Reflect.field(data, $v{name});
									if (value == null) {
										$def;
									} else {
										${from};
									}
								};
						}

						{
							serializer: serializer,
							deserializer: deserializer
						};
					case []:
						Context.error('There is no need to mark fields with @:json unless you are defining how they should serialize/unserialize', meta.pos);
					default:
						Context.error('Invalid arguments', meta.pos);
				}

				if (options.customParser != null) switch options.customParser({
					name: name,
					type: t,
					parser: (access, name, t) -> parseExpr(access, name, t, pos)
				}) {
					case Some(hook): return hook;
					case None:
				}

				return parseExpr(macro this.$name, name, t, pos);
			default:
				Context.error('Invalid field for json serialization', field.pos);
		}
	}

	// @todo: keep working on this method
	function parseExpr(access:Expr, name:String, t:ComplexType, pos:Position):JsonSerializerHook {
		return switch t {
			case macro :Dynamic:
				{
					serializer: access,
					deserializer: macro Reflect.field(data, $v{name})
				};
			case t if (isScalar(t)):
				{
					serializer: access,
					deserializer: macro Reflect.field(data, $v{name})
				};
			case macro :Null<$t>:
				var path = switch t {
					case TPath(p): p.typePathToArray();
					default: Context.error('Could not resolve type', pos);
				}

				{
					serializer: macro @:pos(pos) $access?.toJson(),
					deserializer: macro {
						var value:Dynamic = Reflect.field(data, $v{name});
						if (value == null) {
							null;
						} else {
							@:pos(pos) $p{path}.fromJson(value);
						}
					}
				};
			case macro :Array<$t>:
				var path = switch t {
					case TPath(p): p.typePathToArray();
					default: Context.error('Could not resolve type', pos);
				}

				{
					serializer: macro $access.map(item -> @:pos(pos) item.toJson()),
					deserializer: macro {
						var values:Array<Dynamic> = Reflect.field(data, $v{name});
						if (values == null) {
							[];
						} else {
							values.map(@:pos(pos) $p{path}.fromJson);
						}
					}
				};
			default:
				var path = switch t {
					case TPath(p): p.typePathToArray();
					default: Context.error('Could not resolve type', pos);
				}

				{
					serializer: macro @:pos(pos) $access?.toJson(),
					deserializer: macro {
						var value:Dynamic = Reflect.field(data, $v{name});
						@:pos(pos) $p{path}.fromJson(value);
					}
				}
		}
	}
}

// @todo: Find a more elegant way to do this?
private function isScalar(type:ComplexType) {
	return switch type {
		case macro :String: true;
		case macro :Int: true;
		case macro :Bool: true;
		case macro :Array<$t>: isScalar(t);
		case macro :Null<$t>: isScalar(t);
		default:
			var t = type.toType();
			if (Context.unify(t, Context.getType('String'))) {
				return true;
			}
			if (Context.unify(t, Context.getType('Int'))) {
				return true;
			}
			if (Context.unify(t, Context.getType('Bool'))) {
				return true;
			}
			false;
	}
}
