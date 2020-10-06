package input.core;
interface SwitchableInputTargets<TPos> {
    function addChild(c:SwitchableInputTarget<TPos>):Void;
    function removeChild(c:SwitchableInputTarget<TPos>):Void;
}


