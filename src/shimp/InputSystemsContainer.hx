package shimp;

import fsm.FSM;
import fsm.State;
import shimp.IPos;
import shimp.InputSystem;

@:enum abstract InputSystemsContainerStates(String) to String {
    var open = "open";
    var pressed = "pressed";
    var pressed_outside = "pressed_outside";
    var disabled = "disabled";
}

class ISCState<TPos:IPos<TPos>> extends State<InputSystemsContainerStates, InputSystemsContainer<TPos>> {
    public function new() {}

    public function hover(target:InputSystemTarget<TPos>) {}
}

class ISCOpenState<T:IPos<T>> extends ISCState<T> {
    override public function onEnter():Void {
        super.onEnter();
        fsm.changeTarget(fsm.hovered);
    }

    override public function hover(target:InputSystemTarget<T>) {
        fsm.changeTarget(target);
    }
}

class ISCPressedState<T:IPos<T>> extends ISCState<T> {
    override public function onEnter():Void {
        super.onEnter();
        fsm.changeTarget(fsm.pressed);
    }

    override public function onExit():Void {
        super.onExit();
        fsm.changeTarget(fsm.hovered);
    }
}

class ISCPressedOutsideState<T:IPos<T>> extends ISCState<T> {
    override public function onExit():Void {
        super.onExit();
        fsm.changeTarget(fsm.hovered);
    }
}

class ISCDisabledState<T:IPos<T>> extends ISCState<T> {
    override public function onEnter():Void {
        super.onEnter();
        if (fsm.active != null)
            fsm.active.setActive(false);
        fsm.pressed = null;
        fsm.changeTarget(null);
    }

    override public function onExit():Void {
        super.onExit();
        fsm.changeTarget(fsm.hovered);
    }
}

class InputSystemsContainer<TPos:IPos<TPos>> extends FSM<InputSystemsContainerStates, InputSystemsContainer<TPos>> implements InputSystemTarget<TPos>
implements InputSystem<TPos> {
    var targets:Array<InputSystemTarget<TPos>> = [];

    public var movingTargets = false;
    public var hovered:InputSystemTarget<TPos>;
    public var pressed:InputSystemTarget<TPos>;
    public var active(default, null):InputSystemTarget<TPos>;

    var lastPos:TPos;
    var enabled = true;

    public function new(posContainer:TPos, hits) {
        super();
        this.hittester = hits;
        this.lastPos = posContainer;
        addState(InputSystemsContainerStates.open, new ISCOpenState<TPos>());
        addState(InputSystemsContainerStates.pressed, new ISCPressedState<TPos>());
        addState(InputSystemsContainerStates.pressed_outside, new ISCPressedOutsideState<TPos>());
        addState(InputSystemsContainerStates.disabled, new ISCDisabledState<TPos>());
        changeState(open);
    }

    function myState():ISCState<TPos> {
        return cast getCurrentState();
    }

    public function changeTarget(t:InputSystemTarget<TPos>) {
        if (active == t)
            return;
        if (active != null)
            active.setActive(false);
        active = t;
        if (active != null) {
            active.setActive(true);
            active.setPos(lastPos);
        }
    }

    public function setPos(pos:TPos):Void {
        if (lastPos.equals(pos) && !movingTargets)
            return;
        lastPos.setValue(pos);
        processPosition();
    }

    function processPosition() {
        var lastHovered = hovered;
        hovered = null;
        for (trg in targets) {
            if (trg.isUnder(lastPos)) {
                hovered = trg;
                break;
            }
        }
        if (lastHovered != hovered) {
            myState().hover(hovered);
        }
        if (active != null)
            active.setPos(lastPos);
    }

    public function press():Void {
        if (pressed != null)
            throw "Wrong";
        if (hovered == null) {
            changeState(pressed_outside);
            return;
        }
        pressed = hovered;
        changeState(InputSystemsContainerStates.pressed);
        if (active != null)
            active.press();
    }

    public function release():Void {
        pressed = null;
        changeState(open);
        if (active != null)
            active.release();
    }

    public function addChild(target:InputSystemTarget<TPos>):Void {
        targets.unshift(target);
        processPosition();
    }

    public function removeChild(target:InputSystemTarget<TPos>):Void {
        targets.remove(target);
        processPosition();
    }

    public function setActive(val:Bool):Void {
        enabled = val;
        if (val)
            changeState(open);
        else
            changeState(disabled);
    }

    var hittester:HitTester<TPos>;

    public function isUnder(pos:TPos):Bool {
        return hittester.isUnder(pos);
    }
}
