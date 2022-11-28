package shimp;
import shimp.IPos;
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

}
