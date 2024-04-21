import example.Object;

function main() {
	var test = new Test({
		name: 'foo',
		lastName: 'bar'
	});
	trace(test.fullName);
}

class Test implements Object {
	@:auto public final name:String;
	@:auto public final lastName:String;
	@:prop(get = name + ' ' + lastName) public final fullName:String;
}
