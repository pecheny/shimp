package;

import shimp.InputSystemsContainer;
import shimp.InputSystem;
import shimp.ClicksInputSystem;
import shimp.Point;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;

class Sample extends Sprite {
    var buttonInput:ClicksInputSystem<Point>;

    public function new() {
        super();
        var s = new InputSystemsContainer(new Point(), null);
        new InputRoot(s);
        buttonInput = new ClicksInputSystem(new Point());
        s.addChild(createAdapter(buttonInput));

        addButton(new RectButton(10, 10, 100, 36));
        addButton(new CircleButton(100, 100, 36));
    }

    function addButton(b:ButtonBase) {
        buttonInput.addHandler(b);
        addChild(b);
    }

    function createAdapter(input) {
        var outside = new Point();
        outside.x = -9999999;
        outside.y = -9999999;
        return new SwitchableInputAdapter(input, new AlwaysHit(), new Point(), outside);
    }
}
// Depending on your needs you may want to implement boundbox-based or more complex tester.
// Partioning buttons into groups is a way of optimization since the shimp system itrerates over all children 
// in order to find the hit.
class AlwaysHit implements HitTester<Point> {
    public function new() {}

    public function isUnder(_:Point) {
        return true;
    }
}

class ButtonBase extends Sprite implements ClickTarget<Point> {
    public function isUnder(pos:Point):Bool {
        throw "abstract method";
    }

    public function handler():Void {}

    public function changeViewState(st:ClickTargetViewState):Void {}
}

class RectButton extends ButtonBase {
    var __x:Float;
    var __y:Float;
    var __width:Float;
    var __height:Float;

    public function new(x, y, w, h):Void {
        super();
        __x = x;
        __y = y;
        __width = w;
        __height = h;
        changeViewState(Idle);
    }

    override public function isUnder(pos:Point):Bool {
        return pos.x > __x && pos.x < __x + __width && pos.y > __y && pos.y < __y + __height;
    }

    override public function handler():Void {
        trace("button pressed");
    }

    override public function changeViewState(st:ClickTargetViewState):Void {
        graphics.clear();
        var color = switch st {
            case Idle: 0;
            case Hovered: 0xd46e00;
            case Pressed: 0xd46e00;
            case PressedOutside: 0x505050;
        }
        var pressedPadding = 1;
        var x = switch st {
            case Pressed: __x + pressedPadding;
            case _: __x;
        }
        var y = switch st {
            case Pressed: __y + pressedPadding;
            case _: __y;
        }
        var w = switch st {
            case Pressed: __width - pressedPadding * 2;
            case _: __width;
        }
        var h = switch st {
            case Pressed: __height - pressedPadding * 2;
            case _: __height;
        }
        graphics.beginFill(color);
        graphics.drawRect(x, y, w, h);
        graphics.endFill();
    }
}

class CircleButton extends ButtonBase {
    var __x:Float;
    var __y:Float;
    var __r:Float;

    public function new(x, y, r):Void {
        super();
        __x = x;
        __y = y;
        __r = r;
        changeViewState(Idle);
    }

    override public function isUnder(pos:Point):Bool {
        var dx = pos.x - __x;
        var dy = pos.y - __y;
        var r = __r;
        return (dx * dx + dy * dy) < r * r;
    }

    override public function handler():Void {
        trace("button pressed");
    }

    override public function changeViewState(st:ClickTargetViewState):Void {
        graphics.clear();
        var color = switch st {
            case Idle: 0;
            case Hovered: 0xd46e00;
            case Pressed: 0xd46e00;
            case PressedOutside: 0x505050;
        }
        var pressedPadding = 1;
        var r = switch st {
            case Pressed: __r - pressedPadding;
            case _: __r;
        }
        graphics.beginFill(color);
        graphics.drawCircle(__x, __x, r);
        graphics.endFill();
    }
}

class InputRoot {
    var input:InputTarget<Point>;
    var pos = new Point();
    var stg:openfl.display.Stage;

    public function new(input) {
        this.input = input;
        stg = openfl.Lib.current.stage;
        stg.addEventListener(Event.ENTER_FRAME, onEnterFrame);
        stg.addEventListener(MouseEvent.MOUSE_UP, onUp);
        stg.addEventListener(MouseEvent.MOUSE_DOWN, onDown);
    }

    function onEnterFrame(e) {
        updatePos();
    }

    inline function updatePos() {
        pos.x = openfl.Lib.current.stage.mouseX;
        pos.y = openfl.Lib.current.stage.mouseY;
        input.setPos(pos);
    }

    function onDown(e) {
        updatePos();
        input.press();
    }

    function onUp(e) {
        input.release();
    }
}
