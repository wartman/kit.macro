import kit.spec.Runner;
import kit.spec.reporter.ConsoleReporter;

function main() {
	var runner = new Runner();

	runner.addReporter(new ConsoleReporter({
		verbose: true,
		trackProgress: true
	}));
	runner.add(kit.macro.suite.BasicsSuite);

	runner.run();
}
