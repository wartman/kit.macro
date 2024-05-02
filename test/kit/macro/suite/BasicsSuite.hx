package kit.macro.suite;

import fixture.Name;
import kit.spec.Suite;

using kit.spec.Should;

class BasicsSuite extends Suite {
	function execute() {
		describe('@:auto', () -> {
			it('automatically creates constructor arguments', () -> {
				var name = new Name({first: 'Guy', last: 'Manly'});
				name.first.should().be('Guy');
				name.last.should().be('Manly');
			});
		});
		describe('@:prop', () -> {
			it('converts a field into a property', () -> {
				var name = new Name({first: 'Guy', last: 'Manly'});
				name.full.should().be('Guy Manly');
			});
		});
	}
}
