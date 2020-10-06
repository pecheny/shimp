package input.al;
import input.core.SwitchableInputTarget;
import input.core.HitTester;
import crosstarget.shared.Scrollbar;
import al.al2d.Widget2D.AxisCollection2D;
import al.al2d.Axis2D;
import crosstarget.shared.ScrollableContent;
import fsm.FSM;
import fsm.State;
import Math.abs as abs;
import input.Point;


// handles input and indicators

@:enum abstract ScrollboxStateName(String) to String{
    var pressed = "pressed";
    var open = "open";
    var dragged = "dragged";
}
typedef TPos = input.Point;


class ScrollboxInput extends FSM<ScrollboxStateName, ScrollboxInput> implements SwitchableInputTarget<TPos> {
    public static inline var THRESHOLD = 0.05;
    var content:ScrollableContent;
    var scrollbars:AxisCollection2D<Scrollbar>;
    var hitester:HitTester<TPos>;
    var inputPassthrough:SwitchableInputTarget<TPos>;
    var pressOrigin:TPos = new TPos();
    var pos = new TPos();
    var visSize:VisibleSizeProvider;

    public function new(content:ScrollableContent, visSize:VisibleSizeProvider, scrollbars, hittester, subsystem) {
        super();
        this.visSize = visSize;
        this.hitester = hittester;
        this.scrollbars = scrollbars;
        this.content = content;
        this.inputPassthrough = subsystem;
        addState(pressed, new SBPressedState());
        addState(open, new SBOpenState());
        addState(dragged, new SBDragState());
        changeState(open);
    }

    function getTypedState():SBState {
        return cast getCurrentState();
    }

    public function setPos(pos:TPos):Void {
        getTypedState().setPos(pos);
    }

    public function isUnder(pos):Bool {
        return hitester.isUnder(pos);
    }

    public function setOffset(a, val) {
        var offset = content.setOffset(a, val);
        var cs = content.getContentSize(a);
        var vs = visSize.getVisibleSize(a);
        var hndlSize =
        if (cs > vs)
            vs / cs
        else 0 ;
        scrollbars[a].setHandlerSize(hndlSize);
        scrollbars[a].setHandlerPos(-offset / (cs - vs));
    }

    var enabled = true;

    public function setActive(val:Bool):Void {
        enabled = val;
        if (!val)
            changeState(open);
        inputPassthrough.setActive(val);
    }

    public function press():Void {
        getTypedState().press();
    }

    public function release():Void {
        getTypedState().release();
    }
}

@:access(input.al.ScrollboxInput)
class SBState extends State<ScrollboxStateName, ScrollboxInput> {
    public function new() {}

    public function setPos(pos:TPos):Void {
        fsm.pos.setValue(pos);
    }

    public function press():Void {
    }

    public function release():Void {
    }
}
@:access(input.al.ScrollboxInput)
class SBOpenState extends SBState {

    override public function onEnter():Void {
        super.onEnter();
        fsm.inputPassthrough.setActive(true);
    }

    override public function setPos(pos:TPos):Void {
        super.setPos(pos);
        fsm.inputPassthrough.setPos(pos);
    }

    override public function press():Void {
        fsm.pressOrigin.setValue(fsm.pos);
        fsm.inputPassthrough.press();
        fsm.changeState(pressed);
    }
}

@:access(input.al.ScrollboxInput)
class SBPressedState extends SBState {

    override public function setPos(pos:TPos):Void {
        super.setPos(pos);
        var o= fsm.pressOrigin;
        if (abs(o.x - pos.x) > ScrollboxInput.THRESHOLD || abs(o.y - pos.y) > ScrollboxInput.THRESHOLD) {
            fsm.changeState(dragged);
            return;
        }
        fsm.inputPassthrough.setPos(pos);
    }

    override public function release():Void {
        fsm.changeState(open);
        fsm.inputPassthrough.release();
    }
}

@:access(input.al.ScrollboxInput)
class SBDragState extends SBState {
    var initialOffset:Point = new Point();

    override public function onEnter():Void {
        fsm.inputPassthrough.setActive(false);
        initialOffset.x = fsm.content.getOffset(horizontal);
        initialOffset.y = fsm.content.getOffset(vertical);
    }

    override public function setPos(pos:TPos):Void {
        super.setPos(pos);
        fsm.inputPassthrough.setPos(pos);
        fsm.setOffset(horizontal, pos.x - fsm.pressOrigin.x + initialOffset.x);
        fsm.setOffset(vertical, pos.y - fsm.pressOrigin.y + initialOffset.y);
    }

    override public function release():Void {
        fsm.changeState(open);
    }
}


interface VisibleSizeProvider {
    function getVisibleSize(a:Axis2D):Float;
}
