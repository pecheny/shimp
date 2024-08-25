package shimp;
interface IPos<T> {
    public function equals(other:T):Bool;
    public function setValue(other:T):Void;
}
#if taxis
interface PosAccess<TAxis:Axis<TAxis>> {
    function getValue(key:TAxis):Float;
}
#end

