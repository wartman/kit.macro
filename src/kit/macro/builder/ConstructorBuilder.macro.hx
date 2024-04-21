package kit.macro.builder;

import haxe.macro.Context;
import haxe.macro.Expr;

using haxe.macro.Tools;
using kit.macro.Tools;

typedef ConstructorBuilderOptions = {
	public final ?initHook:BuilderHookName;
	public final ?lateInitHook:BuilderHookName;
	public final ?propertyCategory:BuilderPropertyCategory;
	public final ?privateConstructor:Bool;
	public final ?customBuilder:(options:{
		builder:ClassBuilder,
		props:ComplexType,
		previousExpr:Maybe<Expr>,
		inits:Expr,
		lateInits:Expr
	}) -> Function;
}

class ConstructorBuilder implements Builder {
	public final priority:BuilderPriority = Late;

	final options:ConstructorBuilderOptions;

	public function new(?options) {
		this.options = options ?? {};
	}

	public function apply(builder:ClassBuilder) {
		var props = builder.getProps(options.propertyCategory ?? ConstructorProperty);
		var init = builder.getHook(options.initHook ?? InitHook);
		var late = builder.getHook(options.lateInitHook ?? LateInitHook);
		var propsType:ComplexType = TAnonymous(props);
		var currentConstructor = builder.findField('new');
		var previousConstructorExpr:Maybe<Expr> = switch currentConstructor {
			case Some(field): switch field.kind {
					case FFun(f):
						if (f.args.length > 0) {
							Context.error(
								'You cannot pass arguments to this constructor -- it can only '
								+ 'be used to run code at initialization.',
								field.pos);
						}

						if (options.privateConstructor == true && field.access.contains(APublic)) {
							Context.error('Constructor must be private (remove the `public` keyword)', field.pos);
						}

						Some(f.expr);
					default:
						throw 'assert';
				}
			case None:
				None;
		}
		var func:Function = switch options.customBuilder {
			case null:
				(macro function(props:$propsType) {
					@:mergeBlock $b{init};
					@:mergeBlock $b{late};
					${
						switch previousConstructorExpr {
							case Some(expr): expr;
							case None: macro null;
						}
					}
				}).extractFunction();
			case custom:
				custom({
					builder: builder,
					props: propsType,
					previousExpr: previousConstructorExpr,
					inits: macro @:mergeBlock $b{init},
					lateInits: macro @:mergeBlock $b{late},
				});
		}

		switch currentConstructor {
			case Some(field):
				field.kind = FFun(func);
			case None:
				builder.addField({
					name: 'new',
					access: if (options.privateConstructor) [APrivate] else [APublic],
					kind: FFun(func),
					pos: (macro null).pos
				});
		}
	}
}
