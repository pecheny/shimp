package input.al;
import input.core.SwitchableInputTarget;
import al.al2d.Widget2D;
import ec.CtxBinder;
import input.ec.binders.ClickInputBinder;
import input.ec.binders.SwitchableInputBinder;
import input.core.ClicksInputSystem;
import input.al.WidgetHitTester;

class ButtonPanel {
    public static function make(w:Widget2D) {
        var input = new ClicksInputSystem(new Point());
        w.entity.addComponent(new ClickInputBinder(input));
        var outside = new Point();
        outside.x = -9999999;
        outside.y = -9999999;
        w.entity.addComponentByType(SwitchableInputTarget, new SwitchableInputAdapter(input, new WidgetHitTester(w),new Point(), outside));
        new CtxBinder(SwitchableInputBinder, w.entity);
        return w;
    }
}
