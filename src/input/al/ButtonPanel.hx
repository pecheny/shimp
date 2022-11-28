package input.al;
import al.al2d.Placeholder2D;
import ec.CtxWatcher;
import input.al.WidgetHitTester;
import input.core.ClicksInputSystem;
import input.core.InputSystem;
import input.core.Point;
import input.ec.binders.ClickInputBinder;
import input.ec.binders.SwitchableInputBinder;

class ButtonPanel {
    public static function make(w:Placeholder2D) {
        var input = new ClicksInputSystem(new Point());
        w.entity.addComponent(new ClickInputBinder(input));
        var outside = new Point();
        outside.x = -9999999;
        outside.y = -9999999;
        w.entity.addComponentByType(InputSystemTarget, new SwitchableInputAdapter(input, new WidgetHitTester(w),new Point(), outside));
        new CtxWatcher(SwitchableInputBinder, w.entity);
        return w;
    }
}
