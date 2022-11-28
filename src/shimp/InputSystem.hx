package shimp;

interface InputSystem<TPos> {
    function addChild(c:InputSystemTarget<TPos>):Void;
    function removeChild(c:InputSystemTarget<TPos>):Void;
}

interface InputSystemTarget<TPos> extends InputTarget<TPos> extends HitTester<TPos>{
    public function setActive(val:Bool):Void;
}

interface InputTarget<TPos> {
    function setPos(pos:TPos):Void;

    function press():Void;

    function release():Void;
}

interface HitTester<TPos> {
    function isUnder(pos:TPos):Bool;
}
