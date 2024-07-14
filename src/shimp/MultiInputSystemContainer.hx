package shimp;

import shimp.IPos;
import shimp.InputSystem;

typedef ChildSys<T:IPos<T>> = MultiHoverChildSystem<T>;

// typedef ChildSys<T:IPos<T>> = MultiInpChildSystem<T>;

class MultiInputSystemContainer<TPos:IPos<TPos>> implements InputSystem<TPos> implements SharedTargets<TPos> implements MultiInputTarget<TPos> {
    public var targets:Array<InputSystemTarget<TPos>> = [];

    var systems:Array<ChildSys<TPos>> = [];
    var posFac:Void->TPos;
    var hitTester:HitTester<TPos>;
    var taken:Map<InputSystemTarget<TPos>, Bool> = new Map();

    public function new(posFac:Void->TPos, hits) {
        this.posFac = posFac;
        this.hitTester = hits;
    }

    public function setPos(id:Int, pos:TPos) {
        getSlot(id).setPos(pos);
    }

    public function press(id:Int):Void {
        getSlot(id).press();
    }

    public function release(id:Int):Void {
        getSlot(id).release();
    }

    inline function getSlot(id) {
        while (systems.length < id + 1) {
            systems.push(initSlot());
        }
        return systems[id];
    }

    function initSlot() {
        var point = posFac();
        var sys = new ChildSys(point, hitTester, this);
        return sys;
    }

    function invalidate() {
        for (s in systems)
            s.setPos(s.pos);
    }

    public function addChild(c:InputSystemTarget<TPos>):Void {
        targets.unshift(c);
        invalidate();
    }

    public function removeChild(c:InputSystemTarget<TPos>):Void {
        targets.remove(c);
        for (s in systems)
            s.removeChild(c);
    }

    public function take(ch:InputSystemTarget<TPos>):Void {
        taken[ch] = false;
    }

    public function free(ch:InputSystemTarget<TPos>):Void {
        taken[ch] = false;
    }

    public function isFree(ch:InputSystemTarget<TPos>):Bool {
        var val = !(taken.exists(ch) && taken.get(ch));
        return val;
    }

    public function setActive(v:Bool):Void {
        for (s in systems)
            s.setActive(v);
        taken.clear();
    }
}

interface SharedTargets<TPos:IPos<TPos>> {
    function take(ch:InputSystemTarget<TPos>):Void;
    function free(ch:InputSystemTarget<TPos>):Void;
    function isFree(ch:InputSystemTarget<TPos>):Bool;
    var targets:Array<InputSystemTarget<TPos>>;
}

class MultiHoverChildSystem<TPos:IPos<TPos>> extends HoverInputSystem<TPos> {
    public var pos(default, null):TPos;

    var shTargets:SharedTargets<TPos>;

    public function new(posContainer:TPos, hits, targets:SharedTargets<TPos>) {
        pos = posContainer;
        super(posContainer, hits);
        shTargets = targets;
        this.children = targets.targets;
    }

    override function activateChild(t:InputSystemTarget<TPos>) {
        if (active == t)
            return;
        if (t == null)
            shTargets.free(active);
        else
            shTargets.take(t);
        super.activateChild(t);
    }

    override function invalidate() {
        if (!pressed) {
            activateChild(null);
            return;
        }
        for (ch in children) {
            if (shTargets.isFree(ch) && ch.isUnder(lastPos)) {
                activateChild(ch);
                return;
            }
        }
        activateChild(null);
    }

    override public function removeChild(target:InputSystemTarget<TPos>):Void {
        if (active == target)
            activateChild(null);
        invalidate();
    }
}

class MultiInpChildSystem<TPos:IPos<TPos>> extends InputSystemsContainer<TPos> {
    public var pos(default, null):TPos;

    var shTargets:SharedTargets<TPos>;

    public function new(posContainer:TPos, hits, targets:SharedTargets<TPos>) {
        pos = posContainer;
        super(posContainer, hits);
        shTargets = targets;
        this.targets = targets.targets;
    }

    override function changeTarget(t:InputSystemTarget<TPos>) {
        if (active == t)
            return;
        if (t == null)
            shTargets.free(active);
        else
            shTargets.take(t);
        super.changeTarget(t);
    }

    override function processPosition() {
        var lastHovered = hovered;
        hovered = null;
        for (trg in targets) {
            if (shTargets.isFree(trg) && trg.isUnder(lastPos)) {
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

    override public function removeChild(target:InputSystemTarget<TPos>):Void {
        if (active == target)
            changeTarget(null);
        processPosition();
    }
}
