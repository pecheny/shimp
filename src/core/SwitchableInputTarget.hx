package input.core;


interface SwitchableInputTarget<TPos> extends InputTarget<TPos> extends HitTester<TPos>{
    public function setActive(val:Bool):Void;
}
