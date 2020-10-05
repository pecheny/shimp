package input.openfl;
import openfl.geom.Point;
class PointAdapter implements IPos<PointAdapter> {
    public var value(default, null):Point = new Point(0, 0);

    public function new() {}

    public function equals(other:PointAdapter) {
        return value.equals(other.value);
    }

    public function setValue(other:PointAdapter):Void {
        value.setTo(other.value.x, other.value.y);
    }

    public function toString() {
        return value.toString();
    }
}
