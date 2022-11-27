package input.ec.binders;

import ec.CtxWatcher.CtxBinder;
import ec.Entity;
import input.core.IPos;
import input.core.SwitchableInputTarget;
import input.core.SwitchableInputTargets;
class SwitchableInputBinder<T:IPos<T>> implements CtxBinder {
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
