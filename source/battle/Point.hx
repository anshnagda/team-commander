package battle;

class Point
{
	public var x:Int;
	public var y:Int;

	public function new(x:Int, y:Int)
	{
		if (x < 0) {
			x = 0;
		} else if (x > 7) {
			x = 7;
		}
		if (y < 0) {
			y = 0;
		} else if (y > 7) {
			y = 7;
		}
		this.x = x;
		this.y = y;
	}

	public function toString()
	{
		return "Point(" + x + "," + y + ")";
	}

	public function equals(b: Point) {
		return this.x == b.x && this.y == b.y;
	}
}