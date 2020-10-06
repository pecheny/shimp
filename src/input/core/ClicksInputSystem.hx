package input.core;
import input.core.IPos;
import fsm.FSM;
import fsm.State;
import input.core.SwitchableInputTarget;
import input.core.HitTester;
import input.core.InputTarget;

interface ClicksSystem<TPos> {
    function addHandler(target:ClickTarget<TPos>):Void;

    function removeHandler(target:ClickTarget<TPos>):Void;
}

@:enum abstract SingleTargetInputStates(String) to String{
    var open = "open";
    var pressed = "pressed";
    var pressed_outside = "pressed_outside";
}

class STIState<TPos:IPos<TPos>> extends State<SingleTargetInputStates, ClicksInputSystem<TPos>> {

    public function new() {}

    public function hover(target:ClickTarget<TPos>) {
    }
}

class STIOpenState<T:IPos<T>> extends STIState<T> {
    var current:ClickTarget<T>;

    override public function hover(target:ClickTarget<T>) {
        super.hover(target);
        if (current != null)
            current.viewHandler(ClickTargetViewState.Idle);
        current = target;
        if (current != null)
            current.viewHandler(ClickTargetViewState.Hovered);
    }

    override public function onEnter():Void {
        super.onEnter();
        current = fsm.hovered;
        hover(current);
    }

    override public function onExit():Void {
        super.onExit();
        if (current != null)
            current.viewHandler(ClickTargetViewState.Idle);
        current = null;
    }


}
class STIPressedState<T:IPos<T>> extends STIState<T> {
    var target:ClickTarget<T>;

    override public function hover(target:ClickTarget<T>) {
        super.hover(target);
        if (this.target == target) {
            this.target.viewHandler(ClickTargetViewState.Pressed);
        } else {
            this.target.viewHandler(ClickTargetViewState.PressedOutside);
        }
    }

    override public function onEnter():Void {
        this.target = fsm.pressed;
        hover(target);
        super.onEnter();
    }

    override public function onExit():Void {
        super.onExit();
        this.target.viewHandler(ClickTargetViewState.Idle);
        target = null;
    }
}
class STIPressedOutsideState<T:IPos<T>> extends STIState<T> {

}

class ClicksInputSystem<TPos:IPos<TPos>> extends FSM<SingleTargetInputStates, ClicksInputSystem<TPos>> implements InputTarget<TPos> implements ClicksSystem<TPos> {
    var targets:Array<ClickTarget<TPos>> = [];
    public var movingTargets = false;
    public var hovered:ClickTarget<TPos>;
    public var pressed:ClickTarget<TPos>;
    var lastPos:TPos;

    public function new(posContainer:TPos) {
        super();
        this.lastPos = posContainer;
        addState(SingleTargetInputStates.open, new STIOpenState<TPos>());
        addState(SingleTargetInputStates.pressed, new STIPressedState<TPos>());
        addState(SingleTargetInputStates.pressed_outside, new STIPressedOutsideState<TPos>());
        changeState(open);
    }

    function myState():STIState<TPos> {
        return cast getCurrentState();
    }

    public function setPos(pos:TPos):Void {
        if (lastPos.equals(pos) && !movingTargets)
            return;
        lastPos.setValue(pos);
        processPosition();
    }

    inline function processPosition() {
        var lastHovered = hovered;
        hovered = null;
        for (trg in targets) {
            if (trg.isUnder(lastPos)) {
                hovered = trg;
                break;
            }
        }

        if (lastHovered != hovered) {
            // hover changed
            myState().hover(hovered);
        }
    }

    public function press():Void {
//        trace("press");
        if (pressed != null)
            throw "Wrong";
        if (hovered == null) {
            changeState(pressed_outside);
            return;
        }
        pressed = hovered;
        changeState(SingleTargetInputStates.pressed);
    }

    public function release():Void {
//        trace("Release ");
        if (hovered != null && hovered == pressed) {
            // call click
            pressed.handler();
        }
        pressed = null;
        changeState(open);
    }

    public function addHandler(target:ClickTarget<TPos>):Void {
        targets.unshift(target);
    }

    public function removeHandler(target:ClickTarget<TPos>):Void {
        targets.remove(target);
    }

}
class SwitchableInputAdapter<TPos:IPos<TPos>> implements SwitchableInputTarget<TPos> {
    var target:InputTarget<TPos>;
    var hittesetr:HitTester<TPos>;
    var enabled:Bool;
    var outside:TPos;
    var pos:TPos;


    public function new(t, h, pos, outside) {
        this.outside = outside;
        this.pos = pos;
        target = t;
        hittesetr = h;
    }

    public function setPos(pos:TPos):Void {
        this.pos.setValue(pos);
        if (enabled)
            target.setPos(pos);
    }

    public function isUnder(pos:TPos):Bool {
        return hittesetr.isUnder(pos);
    }

    public function setActive(val:Bool):Void {
        enabled = val;
        if (!enabled) {
            target.setPos(outside);
            target.release();
        } else {
            target.setPos(pos);
        }
    }

    public function press():Void {
        if (enabled)
            target.press();
    }

    public function release():Void {
        if (enabled)
            target.release();
    }
}


interface ClickTarget<TPos> extends HitTester<TPos> {
    public function handler():Void;

    public function viewHandler(st:ClickTargetViewState):Void ;
}


enum ClickTargetViewState {
    Idle;
    Hovered;
    Pressed;
    PressedOutside;
}

