package kit.macro;

import haxe.macro.Context;

class ClassBuilderFactory {
	final steps:Array<BuildStep>;

	public function new(steps) {
		this.steps = steps;
	}

	public function withSteps(...step:BuildStep) {
		return new ClassBuilderFactory(steps.concat(step));
	}

	public function from(options) {
		return new ClassBuilder({
			type: options.type,
			fields: options.fields,
			steps: steps
		});
	}

	public function fromContext() {
		return from({
			fields: Context.getBuildFields(),
			type: Context.getLocalType(),
		});
	}
}
