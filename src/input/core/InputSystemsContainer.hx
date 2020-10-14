package input.core;

import input.core.SwitchableInputTarget;
import fsm.FSM;
import fsm.State;
import input.core.IPos;
import input.core.SwitchableInputTargets;
import input.core.HitTester;

@:enum abstract InputSystemsContainerStates(String) to String {
	var open = "open";
	var pressed = "pressed";
	var pressed_outside = "pressed_outside";
	var disabled = "disabled";
}

class ISCState<TPos:IPos<TPos>> extends State<InputSystemsContainerStates, InputSystemsContainer<TPos>> {
	public function new() {}

	public function hover(target:SwitchableInputTarget<TPos>) {}
}

class ISCOpenState<T:IPos<T>> extends ISCState<T> {
	override public function onEnter():Void {
		super.onEnter();
		fsm.changeTarget(fsm.hovered);
	}

	override public function hover(target:SwitchableInputTarget<T>) {
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

class InputSystemsContainer<TPos:IPos<TPos>> extends FSM<InputSystemsContainerStates, InputSystemsContainer<TPos>> implements SwitchableInputTarget<TPos>
		implements SwitchableInputTargets<TPos> {
	var targets:Array<SwitchableInputTarget<TPos>> = [];

	public var movingTargets = false;
	public var hovered:SwitchableInputTarget<TPos>;
	public var pressed:SwitchableInputTarget<TPos>;
	public var active(default, null):SwitchableInputTarget<TPos>;

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

	public function changeTarget(t:SwitchableInputTarget<TPos>) {
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

	public function addChild(target:SwitchableInputTarget<TPos>):Void {
		if (verbose)
			trace("add");
        targets.unshift(target);
        processPosition();
	}

	public function removeChild(target:SwitchableInputTarget<TPos>):Void {
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
