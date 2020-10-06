package input.core;
interface HitTester<TPos> {
    function isUnder(pos:TPos):Bool;
}
