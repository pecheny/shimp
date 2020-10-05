package input;
import al.al2d.Axis2D;
import al.al2d.Widget2D.AxisCollection2D;
//typedef A2dPoint = Point;
//class A2dPoint implements IPos<A2dPoint> {
//    public var coords:AxisCollection2D<Float> = new AxisCollection2D();
//
//    public var x (get, set):Float;
//    public var y (get, set):Float;
//
//    public function new() {
//        for (a in Axis2D.keys) {
//            coords[a] = 0;
//        }
//    }
//
//    public inline function get(a:Axis2D) {
//        return coords[a];
//    }
//
//    public function equals(other:A2dPoint):Bool {
//        return
//            coords[horizontal] == other.get(horizontal)
//            && coords[vertical] == other.get(vertical);
//
//    }
//
//    public function setValue(other:A2dPoint):Void {
//        coords[horizontal] = other.get(horizontal);
//        coords[vertical] = other.get(vertical);
//    }
//
//    inline function get_x():Float {
//        return coords[horizontal];
//    }
//
//    inline function set_x(value:Float):Float {
//        return coords[horizontal] = value;
//    }
//
//    inline function get_y():Float {
//        return coords[vertical];
//    }
//
//    inline function set_y(value:Float):Float {
//        return coords[vertical] =  value;
//    }
//
//    @:keep
//    function toString():String {
//        return '($x, $y)';
//    }
//}
