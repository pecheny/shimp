package shimp;

import shimp.InputSystem.InputTarget;

interface MultiInputTarget<TPos> {
    public function setPos(id:Int, pos:TPos):Void;

    public function press(id:Int):Void;

    public function release(id:Int):Void;

    public function setActive(v:Bool):Void;
}

class InputToMultiTarget<TPos> implements InputTarget<TPos> {
    var target:MultiInputTarget<TPos>;
    var id:Int;

    public function new(trg, id) {
        this.target = trg;
        this.id = id;
    }

    public function setPos(pos:TPos) {
        target.setPos(id, pos);
    }

    public function press() {
        target.press(id);
    }

    public function release() {
        target.release(id);
    }
}
