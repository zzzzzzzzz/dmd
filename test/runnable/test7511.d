extern(C) int printf(const char*, ...);

/**********************************/
// 7511

struct S7511(T)
{
    // this is a pure function for T==int
    T foo(T x)
    {
        return 2 * x;
    }
}

void test7511a() pure
{
    S7511!int s;
    s.foo(2); // error -> OK
}

/**********************************/
// certain case - wrapper range

//import std.range;
@property bool empty(T)(in T[] a) { return !a.length; }
@property ref T front(T)(T[] a) { return a[0]; }
void popFront(T)(ref T[] a) { a = a[1 .. $]; }

struct S(T)
{
    int foo()
    {
        auto t = T();
        return t.bar();
    }
}

struct Wrap(R)
{
    R original;
    this(T : R)(T t) { original = t; }
    this(A...)(A args) { original = R(args); }
    @property auto empty() { return original.empty; }
    @property auto front() { return original.front; }
    void popFront() { original.popFront(); }
}

void test7511b() pure @safe
{
    static struct Iota
    {
        size_t curr;
        size_t max;
        @property bool empty() pure @safe { return curr == max; }
        @property size_t front() pure @safe { return curr; }
        void popFront() pure @safe { ++curr; }
    }
    {
        auto a = Iota(0, 3);
        size_t i = 0;
        foreach (e; a) { assert(e == i++); } // OK
    }
    {
        auto a = Wrap!(int[])([0,1,2]);
        size_t i = 0;
        foreach (e; a) { assert(e == i++); } // errors!
    }
    {
        auto a = Wrap!Iota(0, 3);
        size_t i = 0;
        foreach (e; a) { assert(e == i++); } // errors!
    }
}

/**********************************/
// with attribute inheritance

struct X
{
    static int bar() pure nothrow @safe
    {
        return 1;
    }
}

class Class(T)
{
    int foo()
    {   // inferred to pure nothrow @safe
        return T.bar();
    }
}

alias Class!X C;

class D : C
{
    override int foo()
    {   // inherits attributes from Class!X.foo
        return 2;
    }
}

void test7511c() pure nothrow @safe
{
// Disabled for Bigzilla 9952
/+
    assert((new C()).foo() == 1);
    assert((new D()).foo() == 2);
    static assert(typeof(&C.init.foo).stringof == "int delegate() pure nothrow @safe");
    static assert(typeof(&D.init.foo).stringof == "int delegate() pure nothrow @safe");
+/
}

/**********************************/
// curiously recurring template pattern (CRTP)

class BX(T, bool mutual)
{
    int foo()
    {
        static if (mutual)
            return (cast(T)this).foo();
        else
            return 0;
    }
}

class D1 : BX!(D1, true)
{
    alias typeof(super) B;
    int val;
    this(int n) { val = n; }
    override int foo() { return val; }
}
class D2 : BX!(D2, false)
{
    alias typeof(super) B;
    int val;
    this(int n) { val = n; }
    override int foo() { return val; }
}
class D3 : BX!(D3, true)
{
    alias typeof(super) B;
    int val;
    this(int n) { val = n; }
    override int foo() pure nothrow { return val; }
}
class D4 : BX!(D4, false)
{
    alias typeof(super) B;
    int val;
    this(int n) { val = n; }
    override int foo() pure nothrow { return val; }
}

void test7511d()
{
// Disabled for Bigzilla 9952
/+
    // mutual dependent and attribute inference impure, un-@safe, and may throw is default.
    auto d1 = new D1(10);
    static assert(is(typeof(&d1.B.foo) == int function()));
    static assert(is(typeof(&d1.foo) == int delegate()));
    assert(d1.foo() == 10);

    // no mutual dependent.
    auto d2 = new D2(10);
    static assert(is(typeof(&d2.B.foo) == int function() pure nothrow @safe));
    static assert(is(typeof(&d2  .foo) == int delegate() pure nothrow @safe));
    assert(d2.foo() == 10);

    // mutual dependent with explicit attribute specification.
    auto d3 = new D3(10);
    static assert(is(typeof(&d3.B.foo) == int function() pure nothrow));
    static assert(is(typeof(&d3  .foo) == int delegate() pure nothrow));
    assert(d3.foo() == 10);

    // no mutual dependent with explicit attribute specification.
    auto d4 = new D4(10);
    static assert(is(typeof(&d4.B.foo) == int function() pure nothrow @safe));
    static assert(is(typeof(&d4  .foo) == int delegate() pure nothrow @safe));
    assert(d4.foo() == 10);
+/
}

/**********************************/
// 9952

@system void writeln9952(int) {}    // impure throwable

class C9952(T)
{
    T foo()
    {
        return 2;
    }
}

class D9952 : C9952!int
{
    override int foo()
    {
        writeln9952(super.foo());
        return 3;
    }
}

void test9952()
{
    static assert(typeof(&C9952!int.init.foo).stringof == "int delegate()");
    static assert(typeof(&D9952    .init.foo).stringof == "int delegate()");
}

/**********************************/

int main()
{
    test7511a();
    test7511b();
    test7511c();
    test7511d();
    test9952();

    printf("Success\n");
    return 0;
}
