package kit.macro;

enum abstract BuilderHookName(String) from String {
	final InitHook = 'init';
	final LateInitHook = 'init:late';
}
