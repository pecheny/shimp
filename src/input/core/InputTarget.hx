package input.core;
interface InputTarget<TPos> {
    function setPos(pos:TPos):Void;

    function press():Void;

    function release():Void;
}

