package kit.macro;

interface BuildStep {
	public final priority:Priority;
	public function apply(builder:ClassBuilder):Void;
}
