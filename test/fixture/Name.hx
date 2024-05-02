package fixture;

class Name implements Object {
	@:auto public final first:String;
	@:auto public final last:String;
	@:prop(get = first + ' ' + last) public final full:String;
}
