package input.ec.binders;

import input.core.SwitchableInputTargets;
import input.core.SwitchableInputTarget;
import input.core.IPos;
import ec.CtxBinder.CtxBindable;
import ec.Entity;
class SwitchableInputBinder<T:IPos<T>> implements CtxBindable {
    var system:SwitchableInputTargets<T>;

    public function new(s) {
        this.system = s;
    }

    public function bind(e:Entity):Void {
        var clicks = e.getComponent(SwitchableInputTarget);
        if (clicks != null) {
            system.addChild(clicks);
        }
    }

    public function unbind(e:Entity):Void {
        var clicks = e.getComponent(SwitchableInputTarget);
        if (clicks != null) {
            system.removeChild(clicks);
        }
    }
}
