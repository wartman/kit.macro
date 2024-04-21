package kit.macro;

interface Parser {
	public final priority:Priority;
	public function apply(builder:ClassBuilder):Void;
}
