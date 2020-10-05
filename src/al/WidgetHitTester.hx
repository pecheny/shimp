package input.al;
import input.core.HitTester;
import al.al2d.Axis2D;
import al.al2d.Widget2D;
class WidgetHitTester implements HitTester<Point> {
    var w:Widget2D;

    public function new(w) {
        this.w = w;
    }

    inline function checkAxisHit(a:Axis2D, val:Float) {
        var axis = w.axisStates[a];
        if (val < axis.getPos())
            return false;
        if (val > (axis.getPos() + axis.getSize()))
            return false;
        return true;
    }

    public function isUnder(pos:Point):Bool {
        return checkAxisHit(horizontal, pos.x) && checkAxisHit(vertical, pos.y);
    }
}
