package shimp;

import shimp.InputSystem;
import shimp.IPos;

class HoverInputSystem<TPos:IPos<TPos>> implements InputSystemTarget<TPos> implements InputSystem<TPos> {
    var lastPos:TPos;
    var hittester:HitTester<TPos>;
    var children:Array<InputSystemTarget<TPos>> = [];
    var active:InputSystemTarget<TPos>;
    var pressed:Bool;

    public function new(posContainer:TPos, hits) {
        this.hittester = hits;
        this.lastPos = posContainer;
    }

    public function setActive(val:Bool) {
        if (!val)
            activateChild(null);
    }

    function activateChild(ch) {
        if (active == ch)
            return;
        if (active != null) {
            active.release();
            active.setActive(false);
        }
        active = ch;
        active?.press();
    }

    public function setPos(pos:TPos) {
        if (lastPos.equals(pos))
            return;
        lastPos.setValue(pos);
        invalidate();
        active?.setPos(pos);
    }

    public function press() {
        pressed = true;
        invalidate();
    }

    public function release() {
        pressed = false;
        activateChild(null);
    }

    public function isUnder(pos:TPos):Bool {
        return hittester.isUnder(pos);
    }

    function invalidate() {
        if (!pressed) {
            activateChild(null);
            return;
        }
        for (ch in children)
            if (ch.isUnder(lastPos)) {
                activateChild(ch);
                return;
            }
    }

    public function addChild(c:InputSystemTarget<TPos>) {
        children.unshift(c);
        invalidate();
    }

    public function removeChild(c:InputSystemTarget<TPos>) {
        children.remove(c);
        invalidate();
    }
}
