package shimp;
import shimp.IPos;
#if taxis
import Axis2D;
import macros.AVConstructor;

class Point implements IPos<Point> implements PosAccess<Axis2D> {
	public var vec:AVector2D<Float> = AVConstructor.create(0., 0.);

	public var x(get, set):Float;
	public var y(get, set):Float;

	public function new() {}

	public function equals(other:Point):Bool {
		return x == other.x && y == other.y;
	}

	public function setValue(other:Point):Void {
		x = other.x;
		y = other.y;
	}

	function get_x():Float {
		return vec[horizontal];
	}

	function set_x(value:Float):Float {
		return vec[horizontal] = value;
	}

	function get_y():Float {
		return vec[vertical];
	}

	function set_y(value:Float):Float {
		return vec[vertical] = value;
	}

	function toString() {
		return '[$x, $y]';
	}

	public function getValue(key:Axis2D):Float {
		return vec[key];
	}
}

#else
class Point implements IPos<Point> {
    public var x:Float = 0;
    public var y:Float = 0;

    public function new() {}

    public function equals(other:Point):Bool {
        return x == other.x && y == other.y;
    }

    public function setValue(other:Point):Void {
        x = other.x;
        y = other.y;
    }

    public function toString() {
        return'($x, $y)';
    }
    
    public function getValue(key:Axis2D):Float {
		throw "not implemented for now";
	}


}
#end