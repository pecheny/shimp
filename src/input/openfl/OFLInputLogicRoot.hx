package input.openfl;
import openfl.events.Event;
import openfl.events.MouseEvent;
class OFLInputLogicRoot {
    var input:InputTarget<PointAdapter>;
    var pos:PointAdapter = new PointAdapter();

    public function new(input) {
        this.input = input;
        var st = openfl.Lib.current.stage;
        st.addEventListener(Event.ENTER_FRAME, onEnterFrame);
        st.addEventListener(MouseEvent.MOUSE_UP, onUp);
        st.addEventListener(MouseEvent.MOUSE_DOWN, onDown);
    }

    function onEnterFrame(e) {
        pos.value.setTo(
            openfl.Lib.current.stage.mouseX,
            openfl.Lib.current.stage.mouseY
        );
        input.setPos(pos);
    }

    function onDown(e) {
        input.press();
    }

    function onUp(e) {
        input.release();
    }
}
