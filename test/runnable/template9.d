// PERMUTE_ARGS:

module breaker;

import core.stdc.stdio, core.vararg;

/**********************************/

U foo(T, U)(U i)
{
    return i + 1;
}

int foo(T)(int i)
{
    return i + 2;
}

void test1()
{
    auto i = foo!(int)(2L);
//    assert(i == 4);    // now returns 3
}

/**********************************/

U foo2(T, U)(U i)
{
    return i + 1;
}

void test2()
{
    auto i = foo2!(int)(2L);
    assert(i == 3);
}

/**********************************/

class Foo3
{
    T bar(T,U)(U u)
    {
        return cast(T)u;
    }
}

void test3()
{
  Foo3 foo = new Foo3;
  int i = foo.bar!(int)(1.0);
  assert(i == 1);
}


/**********************************/

T* begin4(T)(T[] a) { return a.ptr; }

void copy4(string pred = "", Ranges...)(Ranges rs)
{
    alias rs[$ - 1] target;
    pragma(msg, typeof(target).stringof);
    auto tb = begin4(target);//, te = end(target);
}

void test4()
{
    int[] a, b, c;
    copy4(a, b, c);
    // comment the following line to prevent compiler from crashing
    copy4!("a > 1")(a, b, c);
}

/**********************************/

import std.stdio:writefln;

template foo5(T,S)
{
    void foo5(T t, S s) {
        writefln("typeof(T)=",typeid(T)," typeof(S)=",typeid(S));
    }
}

template bar5(T,S)
{
    void bar5(S s) {
        writefln("typeof(T)=",typeid(T),"typeof(S)=",typeid(S));
    }
}


void test5()
{
    foo5(1.0,33);
    bar5!(double,int)(33);
    bar5!(float)(33);
}

/**********************************/

int foo6(T...)(auto ref T x)
{   int result;

    foreach (i, v; x)
    {
        if (v == 10)
            assert(__traits(isRef, x[i]));
        else
            assert(!__traits(isRef, x[i]));
        result += v;
    }
    return result;
}

void test6()
{   int y = 10;
    int r;
    r = foo6(8);
    assert(r == 8);
    r = foo6(y);
    assert(r == 10);
    r = foo6(3, 4, y);
    assert(r == 17);
    r = foo6(4, 5, y);
    assert(r == 19);
    r = foo6(y, 6, y);
    assert(r == 26);
}

/**********************************/

auto ref min(T, U)(auto ref T lhs, auto ref U rhs)
{
    return lhs > rhs ? rhs : lhs;
}

void test7()
{   int x = 7, y = 8;
    int i;

    i = min(4, 3);
    assert(i == 3);
    i = min(x, y);
    assert(i == 7);
    min(x, y) = 10;
    assert(x == 10);
    static assert(!__traits(compiles, min(3, y) = 10));
    static assert(!__traits(compiles, min(y, 3) = 10));
}

/**********************************/
// 5946

template TTest8()
{
    int call(){ return this.g(); }
}
class CTest8
{
    int f() { mixin TTest8!(); return call(); }
    int g() { return 10; }
}
void test8()
{
    assert((new CTest8()).f() == 10);
}

/**********************************/
// 693

template TTest9(alias sym)
{
    int call(){ return sym.g(); }
}
class CTest9
{
    int f1() { mixin TTest9!(this); return call(); }
    int f2() { mixin TTest9!this; return call(); }
    int g() { return 10; }
}
void test9()
{
    assert((new CTest9()).f1() == 10);
    assert((new CTest9()).f2() == 10);
}

/**********************************/
// 1780

template Tuple1780(Ts ...) { alias Ts Tuple1780; }

template Decode1780( T )                            { alias Tuple1780!() Types; }
template Decode1780( T : TT!(Us), alias TT, Us... ) { alias Us Types; }

void test1780()
{
    struct S1780(T1, T2) {}

    // should extract tuple (bool,short) but matches the first specialisation
    alias Decode1780!( S1780!(bool,short) ).Types SQ1780;  // --> SQ2 is empty tuple!
    static assert(is(SQ1780 == Tuple1780!(bool, short)));
}

/**********************************/
// 3608

template foo3608(T, U){}

template BaseTemplate3608(alias TTT : U!V, alias U, V...)
{
    alias U BaseTemplate3608;
}
template TemplateParams3608(alias T : U!V, alias U, V...)
{
    alias V TemplateParams3608;
}

template TyueTuple3608(T...) { alias T TyueTuple3608; }

void test3608()
{
    alias foo3608!(int, long) Foo3608;

    static assert(__traits(isSame, BaseTemplate3608!Foo3608, foo3608));
    static assert(is(TemplateParams3608!Foo3608 == TyueTuple3608!(int, long)));
}

/**********************************/
// 5015

import breaker;

static if (is(ElemType!(int))){}

template ElemType(T) {
  alias _ElemType!(T).type ElemType;
}

template _ElemType(T) {
    alias r type;
}

/**********************************/
// 5893

class C5893
{
    int concatAssign(C5893 other) { return 1; }
    int concatAssign(int other) { return 2; } // to demonstrate overloading

    template opOpAssign(string op) if (op == "~")
    { alias concatAssign opOpAssign; }

    int opOpAssign(string op)(int other) if (op == "+") { return 3; }
}

void test5893()
{
    auto c = new C5893;
    assert(c.opOpAssign!"~"(c) == 1); // works
    assert(c.opOpAssign!"~"(1) == 2); // works
    assert((c ~= 1) == 2);
    assert((c += 1) == 3);  // overload
}

/**********************************/
// 6404

// receive only rvalue
void rvalue(T)(auto ref T x) if (!__traits(isRef, x)) {}
void rvalueVargs(T...)(auto ref T x) if (!__traits(isRef, x[0])) {}

// receive only lvalue
void lvalue(T)(auto ref T x) if ( __traits(isRef, x)) {}
void lvalueVargs(T...)(auto ref T x) if ( __traits(isRef, x[0])) {}

void test6404()
{
    int n;

    static assert(!__traits(compiles, rvalue(n)));
    static assert( __traits(compiles, rvalue(0)));

    static assert( __traits(compiles, lvalue(n)));
    static assert(!__traits(compiles, lvalue(0)));

    static assert(!__traits(compiles, rvalueVargs(n)));
    static assert( __traits(compiles, rvalueVargs(0)));

    static assert( __traits(compiles, lvalueVargs(n)));
    static assert(!__traits(compiles, lvalueVargs(0)));
}

/**********************************/
// 2246

class A2246(T,d){
    T p;
}

class B2246(int rk){
    int[rk] p;
}

class C2246(T,int rk){
    T[rk] p;
}

template f2246(T:A2246!(U,d),U,d){
    void f2246(){ }
}

template f2246(T:B2246!(rank),int rank){
    void f2246(){ }
}

template f2246(T:C2246!(U,rank),U,int rank){
    void f2246(){ }
}

void test2246(){
    A2246!(int,long) a;
    B2246!(2) b;
    C2246!(int,2) c;
    f2246!(A2246!(int,long))();
    f2246!(B2246!(2))();
    f2246!(C2246!(int,2))();
}

/**********************************/
// 2296

void foo2296(uint D)(int[D] i...){}
void test2296()
{
    foo2296(1, 2, 3);
}

/**********************************/
// 1684

template Test1684( uint memberOffset ){}

class MyClass1684 {
    int flags2;
    mixin Test1684!(cast(uint)flags2.offsetof) t1; // compiles ok
    mixin Test1684!(cast(int)flags2.offsetof)  t2; // compiles ok
    mixin Test1684!(flags2.offsetof)           t3; // Error: no property 'offsetof' for type 'int'
}

/**********************************/

void bug4984a(int n)() if (n > 0 && is(typeof(bug4984a!(n-1) ()))) {
}

void bug4984a(int n : 0)() {
}

void bug4984b(U...)(U args) if ( is(typeof( bug4984b(args[1..$]) )) ) {
}

void bug4984b(U)(U u) {
}

void bug4984() {
  // Note: compiling this overflows the stack if dmd is build with DEBUG
  //bug4984a!400();
    bug4984a!200();
    bug4984b(0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19);
}

/***************************************/
// 2579

void foo2579(T)(T delegate(in Object) dlg)
{
}

void test2579()
{
    foo2579( (in Object o) { return 15; } );
}

/**********************************/
// 4953

void bug4953(T = void)(short x) {}
static assert(is(typeof(bug4953(3))));

/**********************************/
// 5886 & 5393

struct K5886
{
    void get1(this T)() const
    {
        pragma(msg, T);
    }
    void get2(int N=4, this T)() const
    {
        pragma(msg, N, " ; ", T);
    }
    void test() const
    {
        get1;       // OK
        get2;       // OK
        get2!8;     // NG
    }
}

void test5886()
{
    K5886 km;
    const(K5886) kc;
    immutable(K5886) ki;

    km.get1;        // OK
    kc.get1;        // OK
    ki.get1;        // OK
    km.get2;        // OK
    kc.get2;        // OK
    ki.get2;        // OK
    km.get2!(1, K5886);             // Ugly
    kc.get2!(2, const(K5886));      // Ugly
    ki.get2!(3, immutable(K5886));  // Ugly
    km.get2!8;      // Error
    kc.get2!9;      // Error
    ki.get2!10;     // Error
}

// --------

void test5393()
{
    class A
    {
        void opDispatch (string name, this T) () { }
    }

    class B : A {}

    auto b = new B;
    b.foobar();
}

/**********************************/
// 5896

struct X5896
{
                 T opCast(T)(){ return 1; }
           const T opCast(T)(){ return 2; }
       immutable T opCast(T)(){ return 3; }
          shared T opCast(T)(){ return 4; }
    const shared T opCast(T)(){ return 5; }
}
void test5896()
{
    auto xm =              X5896  ();
    auto xc =        const(X5896) ();
    auto xi =    immutable(X5896) ();
    auto xs =       shared(X5896) ();
    auto xcs= const(shared(X5896))();
    assert(cast(int)xm == 1);
    assert(cast(int)xc == 2);
    assert(cast(int)xi == 3);
    assert(cast(int)xs == 4);
    assert(cast(int)xcs== 5);
}

/**********************************/
// 6312

void h6312() {}

class Bla6312
{
    mixin wrap6312!h6312;
}

mixin template wrap6312(alias f)
{
    void blub(alias g = f)()
    {
        g();
    }
}

void test6312()
{
    Bla6312 b = new Bla6312();
    b.blub();
}

/**********************************/
// 6825

void test6825()
{
    struct File
    {
        void write(S...)(S args) {}
    }

    void dump(void delegate(string) d) {}

    auto o = File();
    dump(&o.write!string);
}

/**********************************/
// 6789

template isStaticArray6789(T)
{
    static if (is(T U : U[N], size_t N))    // doesn't match
    {
        pragma(msg, "> U = ", U, ", N:", typeof(N), " = ", N);
        enum isStaticArray6789 = true;
    }
    else
        enum isStaticArray6789 = false;
}

void test6789()
{
    alias int[3] T;
    static assert(isStaticArray6789!T);
}

/**********************************/
// 2778

struct ArrayWrapper2778(T)
{
    T[] data;
    alias data this;
}

void doStuffFunc2778(int[] data) {}

void doStuffTempl2778(T)(T[] data) {}

int doStuffTemplOver2778(T)(void* data) { return 1; }
int doStuffTemplOver2778(T)(ArrayWrapper2778!T w) { return 2; }

void test2778()
{
    ArrayWrapper2778!(int) foo;

    doStuffFunc2778(foo);  // Works.

    doStuffTempl2778!(int)(foo);  // Works.

    doStuffTempl2778(foo);  // Error

    assert(doStuffTemplOver2778(foo) == 2);
}

// ----

void test2778aa()
{
    void foo(K, V)(V[K] aa){ pragma(msg, "K=", K, ", V=", V); }

    int[string] aa1;
    foo(aa1);   // OK

    struct SubTypeOf(T)
    {
        T val;
        alias val this;
    }
    SubTypeOf!(string[char]) aa2;
    foo(aa2);   // NG
}

// ----

void test2778get()
{
    void foo(ubyte[]){}

    static struct S
    {
        ubyte[] val = [1,2,3];
        @property ref ubyte[] get(){ return val; }
        alias get this;
    }
    S s;
    foo(s);
}

/**********************************/
// 6208

int getRefNonref(T)(ref T s){ return 1; }
int getRefNonref(T)(    T s){ return 2; }

int getAutoRef(T)(auto ref T s){ return __traits(isRef, s) ? 1 : 2; }

void getOut(T)(out T s){ ; }

void getLazy1(T=int)(lazy void s){ s(), s(); }
void getLazy2(T)(lazy T s){  s(), s(); }

void test6208a()
{
    int lvalue;
    int rvalue(){ int t; return t; }

    assert(getRefNonref(lvalue  ) == 1);
    assert(getRefNonref(rvalue()) == 2);

    assert(getAutoRef(lvalue  ) == 1);
    assert(getAutoRef(rvalue()) == 2);

    static assert( __traits(compiles, getOut(lvalue  )));
    static assert(!__traits(compiles, getOut(rvalue())));

    int n1; getLazy1(++n1); assert(n1 == 2);
    int n2; getLazy2(++n2); assert(n2 == 2);

    struct X
    {
        int f(T)(auto ref T t){ return 1; }
        int f(T)(auto ref T t, ...){ return -1; }
    }
    auto xm =       X ();
    auto xc = const(X)();
    int n;
    assert(xm.f!int(n) == 1);   // resolved 'auto ref'
    assert(xm.f!int(0) == 1);   // ditto
}

void test6208b()
{
    void foo(T)(const T value) if (!is(T == int)) {}

    int mn;
    const int cn;
    static assert(!__traits(compiles, foo(mn)));    // OK -> OK
    static assert(!__traits(compiles, foo(cn)));    // NG -> OK
}

void test6208c()
{
    struct S
    {
        // Original test case.
        int foo(V)(in V v)                         { return 1; }
        int foo(Args...)(auto ref const Args args) { return 2; }

        // Reduced test cases

        int hoo(V)(const V v)             { return 1; }  // typeof(10) : const V       -> MATCHconst
        int hoo(Args...)(const Args args) { return 2; }  // typeof(10) : const Args[0] -> MATCHconst
        // If deduction matching level is same, tuple parameter is less specialized than others.

        int bar(V)(V v)                   { return 1; }  // typeof(10) : V             -> MATCHexact
        int bar(Args...)(const Args args) { return 2; }  // typeof(10) : const Args[0] -> MATCHconst

        int baz(V)(const V v)             { return 1; }  // typeof(10) : const V -> MATCHconst
        int baz(Args...)(Args args)       { return 2; }  // typeof(10) : Args[0] -> MATCHexact

        inout(int) war(V)(inout V v)            { return 1; }
        inout(int) war(Args...)(inout Args args){ return 2; }

        inout(int) waz(Args...)(inout Args args){ return 0; }   // wild deduction test
    }

    S s;

    int nm = 10;
    assert(s.foo(nm) == 1);
    assert(s.hoo(nm) == 1);
    assert(s.bar(nm) == 1);
    assert(s.baz(nm) == 2);
    assert(s.war(nm) == 1);
    static assert(is(typeof(s.waz(nm)) == int));

    const int nc = 10;
    assert(s.foo(nc) == 1);
    assert(s.hoo(nc) == 1);
    assert(s.bar(nc) == 1);
    assert(s.baz(nc) == 1);
    assert(s.war(nc) == 1);
    static assert(is(typeof(s.waz(nc)) == const(int)));

    immutable int ni = 10;
    assert(s.foo(ni) == 1);
    assert(s.hoo(ni) == 1);
    assert(s.bar(ni) == 1);
    assert(s.baz(ni) == 2);
    assert(s.war(ni) == 1);
    static assert(is(typeof(s.waz(ni)) == immutable(int)));

    static assert(is(typeof(s.waz(nm, nm)) == int));
    static assert(is(typeof(s.waz(nm, nc)) == const(int)));
    static assert(is(typeof(s.waz(nm, ni)) == const(int)));
    static assert(is(typeof(s.waz(nc, nm)) == const(int)));
    static assert(is(typeof(s.waz(nc, nc)) == const(int)));
    static assert(is(typeof(s.waz(nc, ni)) == const(int)));
    static assert(is(typeof(s.waz(ni, nm)) == const(int)));
    static assert(is(typeof(s.waz(ni, nc)) == const(int)));
    static assert(is(typeof(s.waz(ni, ni)) == immutable(int)));
}

/**********************************/
// 6805

struct T6805
{
    template opDispatch(string name)
    {
        alias int Type;
    }
}
static assert(is(T6805.xxx.Type == int));

/**********************************/
// 6738

struct Foo6738
{
    int _val = 10;

    @property int val()() { return _val; }
    int get() { return val; }  // fail
}

void test6738()
{
    Foo6738 foo;
    auto x = foo.val;  // ok
    assert(x == 10);
    assert(foo.get() == 10);
}

/**********************************/
// 7498

template IndexMixin(){
    void insert(T)(T value){  }
}

class MultiIndexContainer{
    mixin IndexMixin!() index0;
    class Index0{
        void baburk(){
            this.outer.index0.insert(1);
        }
    }
}

/**********************************/
// 6780

@property int foo6780()(){ return 10; }

int g6780;
@property void bar6780()(int n){ g6780 = n; }

void test6780()
{
    auto n = foo6780;
    assert(n == 10);

    bar6780 = 10;
    assert(g6780 == 10);
}

/**********************************/
// 6891

struct S6891(int N, T)
{
    void f(U)(S6891!(N, U) u) { }
}

void test6891()
{
    alias S6891!(1, void) A;
    A().f(A());
}

/**********************************/
// 6994

struct Foo6994
{
    T get(T)(){ return T.init; }

    T func1(T)()
    if (__traits(compiles, get!T()))
    { return get!T; }

    T func2(T)()
    if (__traits(compiles, this.get!T()))   // add explicit 'this'
    { return get!T; }
}
void test6994()
{
    Foo6994 foo;
    foo.get!int();      // OK
    foo.func1!int();    // OK
    foo.func2!int();    // NG
}

/**********************************/
// 6764

enum N6764 = 1; //use const for D1

alias size_t[N6764] T6764; //workaround
void f6764()(T6764 arr...) { }

void g6764()(size_t[1] arr...) { }

void h6764()(size_t[N6764] arr...) { }

void test6764()
{
    f6764(0);    //good
    g6764(0);    //good
    h6764!()(0); //good
    h6764(0);    //Error: template main.f() does not match any function template declaration
}

/**********************************/
// 3467 & 6806

struct Foo3467( uint n )
{
    Foo3467!( n ) bar( ) {
        typeof( return ) result;
        return result;
    }
}
struct Vec3467(size_t N)
{
    void opBinary(string op:"~", size_t M)(Vec3467!M) {}
}
void test3467()
{
    Foo3467!( 4 ) baz;
    baz = baz.bar;// FAIL

    Vec3467!2 a1;
    Vec3467!3 a2;
    a1 ~ a2; // line 7, Error
}

struct TS6806(size_t n) { pragma(msg, typeof(n)); }
static assert(is(TS6806!(1u) == TS6806!(1)));

/**********************************/
// 4413

struct Foo4413
{
    alias typeof(this) typeof_this;
    void bar1(typeof_this other) {}
    void bar2()(typeof_this other) {}
    void bar3(typeof(this) other) {}
    void bar4()(typeof(this) other) {}
}

void test4413()
{
    Foo4413 f;
    f.bar1(f); // OK
    f.bar2(f); // OK
    f.bar3(f); // OK
    f.bar4(f); // ERR
}

/**********************************/
// 4675

template isNumeric(T)
{
    enum bool test1 = is(T : long);     // should be hidden
    enum bool test2 = is(T : real);     // should be hidden
    enum bool isNumeric = test1 || test2;
}
void test4675()
{
    static assert( isNumeric!int);
    static assert(!isNumeric!string);
    static assert(!__traits(compiles, isNumeric!int.test1));   // should be an error
    static assert(!__traits(compiles, isNumeric!int.test2));   // should be an error
    static assert(!__traits(compiles, isNumeric!int.isNumeric));
}

/**********************************/
// 5525

template foo5525(T)
{
    T foo5525(T t)      { return t; }
    T foo5525(T t, T u) { return t + u; }
}

void test5525()
{
    alias foo5525!int f;
    assert(f(1) == 1);
    assert(f(1, 2) == 3);
}

/**********************************/
// 5801

int a5801;
void bar5801(T = double)(typeof(a5801) i) {}
void baz5801(T)(typeof(a5801) i, T t) {}
void test5801()
{
    bar5801(2);  // Does not compile.
    baz5801(3, "baz"); // Does not compile.
}

/**********************************/
// 5832

struct Bar5832(alias v) {}

template isBar5832a(T)
{
    static if (is(T _ : Bar5832!(v), alias v))
        enum isBar5832a = true;
    else
        enum isBar5832a = false;
}
template isBar5832b(T)
{
    static if (is(T _ : Bar5832!(v), alias int v))
        enum isBar5832b = true;
    else
        enum isBar5832b = false;
}
template isBar5832c(T)
{
    static if (is(T _ : Bar5832!(v), alias string v))
        enum isBar5832c = true;
    else
        enum isBar5832c = false;
}
static assert( isBar5832a!(Bar5832!1234));
static assert( isBar5832b!(Bar5832!1234));
static assert(!isBar5832c!(Bar5832!1234));

/**********************************/
// 2550

template pow10_2550(long n)
{
    const long pow10_2550 = 0;
    static if (n < 0)
        const long pow10_2550 = 0;
    else
        const long pow10_2550 = 10 * pow10_2550!(n - 1);
}
template pow10_2550(long n:0)
{
    const long pow10_2550 = 1;
}
static assert(pow10_2550!(0) == 1);

/**********************************/
// [2.057] Remove top const in IFTI, 9198

void foo10a(T   )(T)            { static assert(is(T    == const(int)[])); }
void foo10b(T...)(T)            { static assert(is(T[0] == const(int)[])); }

// ref paramter doesn't remove top const
void boo10a(T   )(ref T)        { static assert(is(T    == const(int[]))); }
void boo10b(T...)(ref T)        { static assert(is(T[0] == const(int[]))); }

// auto ref with lvalue doesn't
void goo10a(T   )(auto ref T)   { static assert(is(T    == const(int[]))); }
void goo10b(T...)(auto ref T)   { static assert(is(T[0] == const(int[]))); }

// auto ref with rvalue does
void hoo10a(T   )(auto ref T)   { static assert(is(T    == const(int)[])); }
void hoo10b(T...)(auto ref T)   { static assert(is(T[0] == const(int)[])); }

void bar10a(T   )(T)            { static assert(is(T    == const(int)*)); }
void bar10b(T...)(T)            { static assert(is(T[0] == const(int)*)); }

void test10()
{
    const a = [1,2,3];
    static assert(is(typeof(a) == const(int[])));
    foo10a(a);
    foo10b(a);
    boo10a(a);
    boo10b(a);
    goo10a(a);
    goo10b(a);
    hoo10a(cast(const)[1,2,3]);
    hoo10b(cast(const)[1,2,3]);

    int n;
    const p = &n;
    static assert(is(typeof(p) == const(int*)));
    bar10a(p);
    bar10b(p);
}

/**********************************/
// 3092

template Foo3092(A...)
{
    alias A[0] Foo3092;
}
static assert(is(Foo3092!(int, "foo") == int));

/**********************************/
// 7037

struct Foo7037 {}
struct Bar7037 { Foo7037 f; alias f this; }
void works7037( T )( T value ) if ( is( T : Foo7037 ) ) {}
void doesnotwork7037( T : Foo7037 )( T value ) {}

void test7037()
{
   Bar7037 b;
   works7037( b );
   doesnotwork7037( b );
}

/**********************************/
// 7110

struct S7110
{
    int opSlice(int, int) const { return 0; }
    int opSlice()         const { return 0; }
    int opIndex(int, int) const { return 0; }
    int opIndex(int)      const { return 0; }
}

enum e7110 = S7110();

template T7110(alias a) { } // or T7110(a...)

alias T7110!( S7110 ) T71100; // passes
alias T7110!((S7110)) T71101; // passes

alias T7110!( S7110()[0..0]  )  A0; // passes
alias T7110!(  (e7110[0..0]) )  A1; // passes
alias T7110!(   e7110[0..0]  )  A2; // passes

alias T7110!( S7110()[0, 0]  ) B0; // passes
alias T7110!(  (e7110[0, 0]) ) B1; // passes
alias T7110!(   e7110[0, 0]  ) B2; // passes

alias T7110!( S7110()[]  ) C0; // passes
alias T7110!(  (e7110[]) ) C1; // passes
alias T7110!(   e7110[]  ) C2; // fails: e7110 is used as a type

alias T7110!( S7110()[0]  ) D0; // passes
alias T7110!(  (e7110[0]) ) D1; // passes
alias T7110!(   e7110[0]  ) D2; // fails: e7110 must be an array or pointer type, not S7110

/**********************************/
// 7124

template StaticArrayOf(T : E[dim], E, size_t dim)
{
    pragma(msg, "T = ", T, ", E = ", E, ", dim = ", dim);
    alias E[dim] StaticArrayOf;
}

template DynamicArrayOf(T : E[], E)
{
    pragma(msg, "T = ", T, ", E = ", E);
    alias E[] DynamicArrayOf;
}

template AssocArrayOf(T : V[K], K, V)
{
    pragma(msg, "T = ", T, ", K = ", K, ", V = ", V);
    alias V[K] AssocArrayOf;
}
void test7124()
{
    struct SA { int[5] sa; alias sa this; }
    static assert(is(StaticArrayOf!SA == int[5]));

    struct DA { int[] da; alias da this; }
    static assert(is(DynamicArrayOf!DA == int[]));

    struct AA { int[string] aa; alias aa this; }
    static assert(is(AssocArrayOf!AA == int[string]));
}

/**********************************/
// 7359

bool foo7359(T)(T[] a ...)
{
    return true;
}

void test7359()
{
    assert(foo7359(1,1,1,1,1,1));               // OK
    assert(foo7359("abc","abc","abc","abc"));   // NG
}

/**********************************/
// 7363

template t7363()
{
   enum e = 0;
   static if (true)
       enum t7363 = 0;
}
static assert(!__traits(compiles, t7363!().t7363 == 0)); // Assertion fails
static assert(t7363!() == 0); // Error: void has no value

template u7363()
{
   static if (true)
   {
       enum e = 0;
       enum u73631 = 0;
   }
   alias u73631 u7363;
}
static assert(!__traits(compiles, u7363!().u7363 == 0)); // Assertion fails
static assert(u7363!() == 0); // Error: void has no value

/**********************************/

struct S4371(T ...) { }

alias S4371!("hi!") t;

static if (is(t U == S4371!(U))) { }

/**********************************/
// 7416

void t7416(alias a)() if(is(typeof(a())))
{}

void test7416() {
    void f() {}
    alias t7416!f x;
}

/**********************************/
// 7563

class Test7563
{
    void test(T, bool a = true)(T t)
    {

    }
}

void test7563()
{
    auto test = new Test7563;
    pragma(msg, typeof(test.test!(int, true)).stringof);
    pragma(msg, typeof(test.test!(int)).stringof); // Error: expression (test.test!(int)) has no type
}

/**********************************/
// 7572

class F7572
{
    Tr fn7572(Tr, T...)(T t) { return 1; }
}
Tr Fn7572(Tr, T...)(T t) { return 2; }

void test7572()
{
    F7572 f = new F7572();
    int delegate() dg = &f.fn7572!int;
    assert(dg() == 1);

    int function() fn = &Fn7572!int;
    assert(fn() == 2);
}

/**********************************/
// 7580

struct S7580(T)
{
    void opAssign()(T value) {}
}
struct X7580(T)
{
    private T val;
    @property ref inout(T) get()() inout { return val; }    // template
    alias get this;
}
struct Y7580(T)
{
    private T val;
    @property ref auto get()() inout { return val; }        // template + auto return
    alias get this;
}

void test7580()
{
    S7580!(int) s;
    X7580!int x;
    Y7580!int y;
    s = x;
    s = y;

    shared(X7580!int) sx;
    static assert(!__traits(compiles, s = sx));
}

/**********************************/
// 7585

extern(C) alias void function() Callback;

template W7585a(alias dg)
{
    //pragma(msg, typeof(dg));
    extern(C) void W7585a() { dg(); }
}

void test7585()
{
    static void f7585a(){}
    Callback cb1 = &W7585a!(f7585a);      // OK
    static assert(!__traits(compiles,
    {
        void f7585b(){}
        Callback cb2 = &W7585a!(f7585b);  // NG
    }));

    Callback cb3 = &W7585a!((){});              // NG -> OK
    Callback cb4 = &W7585a!(function(){});      // OK
    static assert(!__traits(compiles,
    {
        Callback cb5 = &W7585a!(delegate(){});  // NG
    }));

    static int global;  // global data
    Callback cb6 = &W7585a!((){return global;});    // NG -> OK
    static assert(!__traits(compiles,
    {
        int n;
        Callback cb7 = &W7585a!((){return n;});     // NG
    }));
}

/**********************************/
// 7643

template T7643(A...){ alias A T7643; }

alias T7643!(long, "x", string, "y") Specs7643;

alias T7643!( Specs7643[] ) U7643;  // Error: tuple A is used as a type

/**********************************/
// 7671

       inout(int)[3]  id7671n1             ( inout(int)[3] );
       inout( U )[n]  id7671x1(U, size_t n)( inout( U )[n] );

shared(inout int)[3]  id7671n2             ( shared(inout int)[3] );
shared(inout  U )[n]  id7671x2(U, size_t n)( shared(inout  U )[n] );

void test7671()
{
    static assert(is( typeof( id7671n1( (immutable(int)[3]).init ) ) == immutable(int[3]) ));
    static assert(is( typeof( id7671x1( (immutable(int)[3]).init ) ) == immutable(int[3]) ));

    static assert(is( typeof( id7671n2( (immutable(int)[3]).init ) ) == immutable(int[3]) ));
    static assert(is( typeof( id7671x2( (immutable(int)[3]).init ) ) == immutable(int[3]) ));
}

/************************************/
// 7672

T foo7672(T)(T a){ return a; }

void test7672(inout(int[]) a = null, inout(int*) p = null)
{
    static assert(is( typeof(        a ) == inout(int[]) ));
    static assert(is( typeof(foo7672(a)) == inout(int)[] ));

    static assert(is( typeof(        p ) == inout(int*) ));
    static assert(is( typeof(foo7672(p)) == inout(int)* ));
}

/**********************************/
// 7684

       U[]  id7684(U)(        U[]  );
shared(U[]) id7684(U)( shared(U[]) );

void test7684()
{
    shared(int)[] x;
    static assert(is( typeof(id7684(x)) == shared(int)[] ));
}

/**********************************/
// 7694

void match7694(alias m)()
{
    m.foo();    //removing this line supresses ice in both cases
}

struct T7694
{
    void foo(){}
    void bootstrap()
    {
    //next line causes ice
        match7694!(this)();
    //while this works:
        alias this p;
        match7694!(p)();
    }
}

/**********************************/
// 7755

template to7755(T)
{
    T to7755(A...)(A args)
    {
        return toImpl7755!T(args);
    }
}

T toImpl7755(T, S)(S value)
{
    return T.init;
}

template Foo7755(T){}

struct Bar7755
{
    void qux()
    {
        if (is(typeof(to7755!string(Foo7755!int)))){};
    }
}

/**********************************/

       inout(U)[]  id11a(U)(        inout(U)[]  );
       inout(U[])  id11a(U)(        inout(U[])  );
inout(shared(U[])) id11a(U)( inout(shared(U[])) );

void test11a(inout int _ = 0)
{
    shared(const(int))[] x;
    static assert(is( typeof(id11a(x)) == shared(const(int))[] ));

    shared(int)[] y;
    static assert(is( typeof(id11a(y)) == shared(int)[] ));

    inout(U)[n] idz(U, size_t n)( inout(U)[n] );

    inout(shared(bool[1])) z;
    static assert(is( typeof(idz(z)) == inout(shared(bool[1])) ));
}

inout(U[]) id11b(U)( inout(U[]) );

void test11b()
{
    alias const(shared(int)[]) T;
    static assert(is(typeof(id11b(T.init)) == const(shared(int)[])));
}

/**********************************/
// 7769

void f7769(K)(inout(K) value){}
void test7769()
{
    f7769("abc");
}

/**********************************/
// 7812

template A7812(T...) {}

template B7812(alias C) if (C) {}

template D7812()
{
    alias B7812!(A7812!(NonExistent!())) D7812;
}

static assert(!__traits(compiles, D7812!()));

/**********************************/
// 7873

inout(T)* foo(T)(inout(T)* t)
{
    static assert(is(T == int*));
    return t;
}

inout(T)* bar(T)(inout(T)* t)
{
    return foo(t);
}

void test7873()
{
    int *i;
    bar(&i);
}

/**********************************/
// 7933

struct Boo7933(size_t dim){int a;}
struct Baa7933(size_t dim)
{
    Boo7933!dim a;
    //Boo7933!1 a; //(1) This version causes no errors
}

auto foo7933()(Boo7933!1 b){return b;}
//auto fuu7933(Boo7933!1 b){return b;} //(2) This line neutralizes the error

void test7933()
{
    Baa7933!1 a; //(3) This line causes the error message
    auto b = foo7933(Boo7933!1(1));
}

/**********************************/
// 8094

struct Tuple8094(T...) {}

template getParameters8094(T, alias P)
{
    static if (is(T t == P!U, U...))
        alias U getParameters8094;
    else
        static assert(false);
}

void test8094()
{
    alias getParameters8094!(Tuple8094!(int, string), Tuple8094) args;
}

/**********************************/

struct Tuple12(T...)
{
    void foo(alias P)()
    {
        alias Tuple12 X;
        static if (is(typeof(this) t == X!U, U...))
            alias U getParameters;
        else
            static assert(false);
    }
}

void test12()
{
    Tuple12!(int, string) t;
    t.foo!Tuple12();
}

/**********************************/
// 8125

void foo8125(){}

struct X8125(alias a) {}

template Y8125a(T : A!f, alias A, alias f) {}  //OK
template Y8125b(T : A!foo8125, alias A) {}     //NG

void test8125()
{
    alias Y8125a!(X8125!foo8125) y1;
    alias Y8125b!(X8125!foo8125) y2;
}

/**********************************/

struct A13() {}
struct B13(TT...) {}
struct C13(T1) {}
struct D13(T1, TT...) {}
struct E13(T1, T2) {}
struct F13(T1, T2, TT...) {}

template Test13(alias X)
{
    static if (is(X x : P!U, alias P, U...))
        enum Test13 = true;
    else
        enum Test13 = false;
}

void test13()
{
    static assert(Test13!( A13!() ));
    static assert(Test13!( B13!(int) ));
    static assert(Test13!( B13!(int, double) ));
    static assert(Test13!( B13!(int, double, string) ));
    static assert(Test13!( C13!(int) ));
    static assert(Test13!( D13!(int) ));
    static assert(Test13!( D13!(int, double) ));
    static assert(Test13!( D13!(int, double, string) ));
    static assert(Test13!( E13!(int, double) ));
    static assert(Test13!( F13!(int, double) ));
    static assert(Test13!( F13!(int, double, string) ));
    static assert(Test13!( F13!(int, double, string, bool) ));
}

/**********************************/

struct A14(T, U, int n = 1)
{
}

template Test14(alias X)
{
    static if (is(X x : P!U, alias P, U...))
        alias U Test14;
    else
        static assert(0);
}

void test14()
{
    alias A14!(int, double) Type;
    alias Test14!Type Params;
    static assert(Params.length == 3);
    static assert(is(Params[0] == int));
    static assert(is(Params[1] == double));
    static assert(   Params[2] == 1);
}

/**********************************/
// 8129

class X8129 {}
class A8129 {}
class B8129 : A8129 {}

int foo8129(T : A8129)(X8129 x) { return 1; }
int foo8129(T : A8129)(X8129 x, void function (T) block) { return 2; }

int bar8129(T, R)(R range, T value) { return 1; }

int baz8129(T, R)(R range, T value) { return 1; }
int baz8129(T, R)(R range, Undefined value) { return 2; }

void test8129()
{
    auto x = new X8129;
    assert(x.foo8129!B8129()      == 1);
    assert(x.foo8129!B8129((a){}) == 2);
    assert(foo8129!B8129(x)        == 1);
    assert(foo8129!B8129(x, (a){}) == 2);
    assert(foo8129!B8129(x)              == 1);
    assert(foo8129!B8129(x, (B8129 b){}) == 2);

    ubyte[] buffer = [0, 1, 2];
    assert(bar8129!ushort(buffer, 915) == 1);

    // While deduction, parameter type 'Undefined' shows semantic error.
    static assert(!__traits(compiles, {
        baz8129!ushort(buffer, 915);
    }));
}

/**********************************/
// 8238

void test8238()
{
    static struct S { template t(){ int t; } }

    S s1, s2;
    assert(cast(void*)&s1      != cast(void*)&s2     );
    assert(cast(void*)&s1      != cast(void*)&s1.t!());
    assert(cast(void*)&s2      != cast(void*)&s2.t!());
    assert(cast(void*)&s1.t!() == cast(void*)&s2.t!());
    s1.t!() = 256;
    assert(s2.t!() == 256);
}

/**********************************/
// 8669

struct X8669
{
    void mfoo(this T)()
    {
        static assert(is(typeof(this) == T));
    }
    void cfoo(this T)() const
    {
        static assert(is(typeof(this) == const(T)));
    }
    void sfoo(this T)() shared
    {
        static assert(is(typeof(this) == shared(T)));
    }
    void scfoo(this T)() shared const
    {
        static assert(is(typeof(this) == shared(const(T))));
    }
    void ifoo(this T)() immutable
    {
        static assert(is(typeof(this) == immutable(T)));
    }
}

void test8669()
{
                 X8669 mx;
           const X8669 cx;
      immutable  X8669 ix;
          shared X8669 sx;
    shared const X8669 scx;

     mx.mfoo();
     cx.mfoo();
     ix.mfoo();
     sx.mfoo();
    scx.mfoo();

     mx.cfoo();
     cx.cfoo();
     ix.cfoo();
     sx.cfoo();
    scx.cfoo();

    static assert(!is(typeof(  mx.sfoo() )));
    static assert(!is(typeof(  cx.sfoo() )));
     ix.sfoo();
     sx.sfoo();
    scx.sfoo();

    static assert(!is(typeof(  mx.scfoo() )));
    static assert(!is(typeof(  cx.scfoo() )));
     ix.scfoo();
     sx.scfoo();
    scx.scfoo();

    static assert(!is(typeof(  mx.ifoo() )));
    static assert(!is(typeof(  cx.ifoo() )));
     ix.ifoo();
    static assert(!is(typeof(  sx.ifoo() )));
    static assert(!is(typeof( scx.ifoo() )));
}

/**********************************/
// 8833

template TypeTuple8833(T...) { alias TypeTuple = T; }

void func8833(alias arg)() { }

void test8833()
{
    int x, y;

    alias TypeTuple8833!(
        func8833!(x),
        func8833!(y),
    ) Map;
}

/**********************************/
// 8976

void f8976(ref int) { }

void g8976()()
{
    f8976(0); // line 5
}


void h8976()()
{
    g8976!()();
}

static assert(! __traits(compiles, h8976!()() ) ); // causes error
static assert(!is(typeof(          h8976!()() )));

void test8976()
{
    static assert(! __traits(compiles, h8976!()() ) );
    static assert(!is(typeof(          h8976!()() )));
}

/****************************************/
// 8940

const int n8940; // or `immutable`
static this() { n8940 = 3; }

void f8940(T)(ref int val)
{
    assert(val == 3);
    ++val;
}

static assert(!__traits(compiles,  f8940!void(n8940))); // fails
void test8940()
{
    assert(n8940 == 3);
    static assert(!__traits(compiles, f8940!void(n8940)));
    //assert(n8940 == 3); // may pass as compiler caches comparison result
    //assert(n8940 != 4); // may pass but likely will fail
}

/**********************************/
// 6969 + 8990

class A6969() { alias C6969!() C1; }
class B6969   { alias A6969!() A1; }
class C6969() : B6969 {}

struct A8990(T) { T t; }
struct B8990(T) { A8990!T* a; }
struct C8990    { B8990!C8990* b; }

/**********************************/
// 9018

template Inst9018(alias Template, T)
{
    alias Template!T Inst;
}

template Template9018(T)
{
    enum Template9018 = T;
}

static assert(!__traits(compiles, Inst9018!(Template9018, int))); // Assert passes
static assert(!__traits(compiles, Inst9018!(Template9018, int))); // Assert fails

/**********************************/
// 9026

mixin template node9026()
{
    static if (is(this == struct))
        alias typeof(this)* E;
    else
        alias typeof(this) E;
    E prev, next;
}

struct list9026(alias N)
{
    N.E head;
    N.E tail;
}

class A9026
{
    mixin node9026 L1;
    mixin node9026 L2;
}

list9026!(A9026.L1) g9026_l1;
list9026!(A9026.L2) g9026_l2;

void test9026()
{
    list9026!(A9026.L1) l9026_l1;
    list9026!(A9026.L2) l9026_l2;
}

/**********************************/
// 9038

mixin template Foo9038()
{
    string data = "default";
}

class Bar9038
{
    string data;
    mixin Foo9038 f;
}

void check_data9038(alias M, T)(T obj)
{
    //writeln(M.stringof);
    assert(obj.data == "Bar");
    assert(obj.f.data == "F");
}

void test9038()
{
    auto bar = new Bar9038;
    bar.data = "Bar";
    bar.f.data = "F";

    assert(bar.data == "Bar");
    assert(bar.f.data == "F");

    check_data9038!(Bar9038)(bar);
    check_data9038!(Bar9038.f)(bar);
    check_data9038!(bar.f)(bar);
}

/**********************************/
// 9076

template forward9076(args...)
{
    @property forward9076()(){ return args[0]; }
}

void test9076()
{
    int a = 1;
    int b = 1;
    assert(a == forward9076!b);
}

/**********************************/
// 9083

template isFunction9083(X...) if (X.length == 1)
{
    enum isFunction9083 = true;
}

struct S9083
{
    static string func(alias Class)()
    {
        foreach (m; __traits(allMembers, Class))
        {
            pragma(msg, m);  // prints "func"
            enum x1 = isFunction9083!(mixin(m));  //NG
            enum x2 = isFunction9083!(func);      //OK
        }
        return "";
    }
}
enum nothing9083 = S9083.func!S9083();

class C9083
{
    int x;  // some class members

    void func()
    {
        void templateFunc(T)(ref const T obj)
        {
            enum x1 = isFunction9083!(mixin("x"));  // NG
            enum x2 = isFunction9083!(x);           // NG
        }
        templateFunc(this);
    }
}

/**********************************/
// 9100

template Id(alias A) { alias Id = A; }
template ErrId(alias A) { static assert(0); }
template TypeTuple9100(TL...) { alias TypeTuple9100 = TL; }

class C9100
{
    int value;

    int fun() { return value; }
    int tfun(T)() { return value; }
    TypeTuple9100!(int, long) field;

    void test()
    {
        this.value = 1;
        auto c = new C9100();
        c.value = 2;

        alias t1a = Id!(c.fun);             // OK
        alias t1b = Id!(this.fun);          // Prints weird error, bad
        // -> internally given TOKdotvar
        assert(t1a() == this.value);
        assert(t1b() == this.value);

        alias t2a = Id!(c.tfun);            // OK
        static assert(!__traits(compiles, ErrId!(this.tfun)));
        alias t2b = Id!(this.tfun);         // No error occurs, why?
        // -> internally given TOKdottd
        assert(t2a!int() == this.value);
        assert(t2b!int() == this.value);

        alias t3a = Id!(foo9100);           // OK
        alias t3b = Id!(mixin("foo9100"));  // Prints weird error, bad
        // -> internally given TOKtemplate
        assert(t3a() == 10);
        assert(t3b() == 10);

        assert(field[0] == 0);
        alias t4a = TypeTuple9100!(field);              // NG
        alias t4b = TypeTuple9100!(GetField9100!());    // NG
        t4a[0] = 1; assert(field[0] == 1);
        t4b[0] = 2; assert(field[0] == 2);
    }
}

int foo9100()() { return 10; }
template GetField9100() { alias GetField9100 = C9100.field[0]; }

void test9100()
{
    (new C9100()).test();
}

/**********************************/
// 9101

class Node9101
{
    template ForwardCtorNoId()
    {
        this() {} // default constructor
        void foo() { 0 = 1; }    // wrong code
    }
}
enum x9101 = __traits(compiles, Node9101.ForwardCtorNoId!());

/**********************************/
// 9124

struct Foo9124a(N...)
{
    enum SIZE = N[0];
    private int _val;

    public void opAssign (T) (T other)
    if (is(T unused == Foo9124a!(_N), _N...))
    {
        _val = other._val;          // compile error
        this._val = other._val;     // explicit this make it work
    }

    public auto opUnary (string op) () if (op == "~") {
        Foo9124a!(SIZE) result = this;
        return result;
    }
}
void test9124a()
{
    Foo9124a!(28) a;
    Foo9124a!(28) b = ~a;
}

// --------

template Foo9124b(T, U, string OP)
{
    enum N = T.SIZE;
    alias Foo9124b = Foo9124b!(false, true, N);
}
struct Foo9124b(bool S, bool L, N...)
{
    enum SIZE = 5;
    long[1] _a = 0;
    void someFunction() const {
        auto data1 = _a;        // Does not compile
        auto data2 = this._a;   // <--- Compiles
    }
    auto opBinary(string op, T)(T) {
        Foo9124b!(typeof(this), T, op) test;
    }
}
void test9124b()
{
    auto p = Foo9124b!(false, false, 5)();
    auto q = Foo9124b!(false, false, 5)();
    p|q;
    p&q;
}

/**********************************/
// 9143

struct Foo9143a(bool S, bool L)
{
    auto noCall() {
        Foo9143a!(S, false) x1;         // compiles if this line commented
        static if(S) Foo9143a!(true,  false) x2;
        else         Foo9143a!(false, false) x2;
    }
    this(T)(T other)        // constructor
    if (is(T unused == Foo9143a!(P, Q), bool P, bool Q)) { }
}

struct Foo9143b(bool L, size_t N)
{
    void baaz0() {
        bar!(Foo9143b!(false, N))();    // line 7
        // -> move to before the baaz semantic
    }
    void baaz() {
        bar!(Foo9143b!(false, 2LU))();  // line 3
        bar!(Foo9143b!(true, 2LU))();   // line 4
        bar!(Foo9143b!(L, N))();        // line 5
        bar!(Foo9143b!(true, N))();     // line 6
        bar!(Foo9143b!(false, N))();    // line 7
    }
    void bar(T)()
    if (is(T unused == Foo9143b!(_L, _N), bool _L, size_t _N))
    {}
}

void test9143()
{
    Foo9143a!(false, true) k = Foo9143a!(false, false)();

    auto p = Foo9143b!(true, 2LU)();
}

/**********************************/
// 9266

template Foo9266(T...)
{
    T Foo9266;
}
struct Bar9266()
{
    alias Foo9266!int f;
}
void test9266()
{
    Bar9266!() a, b;
}

/**********************************/
// 9361

struct Unit9361(A)
{
    void butPleaseDontUseMe()()
    if (is(unitType9361!((this))))  // !
    {}

}
template isUnit9361(alias T) if ( is(T)) {}
template isUnit9361(alias T) if (!is(T)) {}

template unitType9361(alias T) if (isUnit9361!T) {}

void test9361()
{
    Unit9361!int u;
    static assert(!__traits(compiles, u.butPleaseDontUseMe())); // crashes
}

/**********************************/
// 9536

struct S9536
{
    static A foo(A)(A a)
    {
        return a * 2;
    }
    int bar() const
    {
        return foo(42);
    }
}

void test9536()
{
    S9536 s;
    assert(s.bar() == 84);
}

/******************************************/
// 9806

struct S9806a(alias x)
{
    alias S9806a!0 N;
}
enum expr9806a = 0 * 0;
alias S9806a!expr9806a T9806a;

// --------

struct S9806b(alias x)
{
    template Next()
    {
        enum expr = x + 1;
        alias S9806b!expr Next;
    }
}
alias S9806b!1 One9806b;
alias S9806b!0.Next!() OneAgain9806b;

// --------

struct S9806c(x...)
{
    template Next()
    {
        enum expr = x[0] + 1;
        alias S9806c!expr Next;
    }
}
alias S9806c!1 One9806c;
alias S9806c!0.Next!() OneAgain9806c;

/******************************************/
// 9837

void test9837()
{
    enum DA : int[] { a = [1,2,3] }
    DA da;
    int[] bda = da;
    static assert(is(DA : int[]));
    void fda1(int[] a) {}
    void fda2(T)(T[] a) {}
    fda1(da);
    fda2(da);

    enum SA : int[3] { a = [1,2,3] }
    SA sa;
    int[3] bsa = sa;
    static assert(is(SA : int[3]));
    void fsa1(int[3] a) {}
    void fsa2(T)(T[3] a) {}
    void fsa3(size_t d)(int[d] a) {}
    void fsa4(T, size_t d)(T[d] a) {}
    fsa1(sa);
    fsa2(sa);
    fsa3(sa);
    fsa4(sa);

    enum AA : int[int] { a = null }
    AA aa;
    int[int] baa = aa;
    static assert(is(AA : int[int]));
    void faa1(int[int] a) {}
    void faa2(V)(V[int] a) {}
    void faa3(K)(int[K] a) {}
    void faa4(K, V)(V[K] a) {}
    faa1(aa);
    faa2(aa);
    faa3(aa);
    faa4(aa);
}

/******************************************/
// 9874

bool foo9874() { return true; }
void bar9874(T)(T) if (foo9874()) {} // OK
void baz9874(T)(T) if (foo9874)   {} // error

void test9874()
{
    foo9874;                      // OK
    bar9874(0);
    baz9874(0);
}

/******************************************/

void test9885()
{
    void foo(int[1][]) {}
    void boo()(int[1][]){}
    struct X(T...) { static void xoo(T){} }
    struct Y(T...) { static void yoo()(T){} }
    struct Z(T...) { static void zoo(U...)(T, U){} }

    struct V(T...) { static void voo()(T, ...){} }
    struct W(T...) { static void woo()(T...){} }

    struct R(T...) { static void roo(U...)(int, U, T){} }

    // OK
    foo([[10]]);
    boo([[10]]);

    // OK
    X!(int[1][]).xoo([[10]]);

    // NG!
    Y!().yoo();
    Y!(int).yoo(1);
    Y!(int, int[]).yoo(1, [10]);
    static assert(!__traits(compiles, Y!().yoo(1)));
    static assert(!__traits(compiles, Y!(int).yoo("a")));
    static assert(!__traits(compiles, Y!().yoo!(int)()));

    // NG!
    Z!().zoo();
    Z!().zoo([1], [1:1]);
    Z!(int, string).zoo(1, "a");
    Z!(int, string).zoo(1, "a", [1], [1:1]);
    Z!().zoo!()();
    static assert(!__traits(compiles, Z!().zoo!()(1)));     // (none) <- 1
    static assert(!__traits(compiles, Z!(int).zoo!()()));   // int <- (none)
    static assert(!__traits(compiles, Z!(int).zoo!()(""))); // int <- ""
    static assert(!__traits(compiles, Z!().zoo!(int)()));   // int <- (none)
    static assert(!__traits(compiles, Z!().zoo!(int)(""))); // int <- ""

    V!().voo(1,2,3);
    V!(int).voo(1,2,3);
    V!(int, long).voo(1,2,3);
    static assert(!__traits(compiles, V!(int).voo()));          // int <- (none)
    static assert(!__traits(compiles, V!(int, long).voo(1)));       // long <- (none)
    static assert(!__traits(compiles, V!(int, string).voo(1,2,3)));     // string <- 2

    W!().woo();
    //W!().woo(1, 2, 3);    // Access Violation
    {   // this behavior is consistent with:
        //alias TL = TypeTuple!();
        //void foo(TL...) {}
        //foo(1, 2, 3);     // Access Violation
        //pragma(msg, typeof(foo));   // void(...)  -> D-style variadic function?
    }
    W!(int,int[]).woo(1,2,3);
    W!(int,int[2]).woo(1,2,3);
    static assert(!__traits(compiles, W!(int,int,int).woo(1,2,3)));	// int... <- 2
    static assert(!__traits(compiles, W!(int,int).woo(1,2)));		// int... <- 2
    static assert(!__traits(compiles, W!(int,int[2]).woo(1,2)));    // int[2]... <- 2

    R!().roo(1, "", []);
    R!(int).roo(1, "", [], 1);
    R!(int, string).roo(1, "", [], 1, "");
    R!(int, string).roo(1, 2, "");
    static assert(!__traits(compiles, R!(int).roo(1, "", []))); // int <- []
    static assert(!__traits(compiles, R!(int, int).roo(1, "", [])));    // int <- []
    static assert(!__traits(compiles, R!(int, string).roo(1, 2, 3)));   // string <- 3

    // test case
    struct Tuple(T...) { this()(T values) {} }
    alias T = Tuple!(int[1][]);
    auto t = T([[10]]);
}

/******************************************/
// 9971

void goo9971()()
{
    auto g = &goo9971;
}

struct S9971
{
    void goo()()
    {
        auto g = &goo;
        static assert(is(typeof(g) == delegate));
    }
}

void test9971()
{
    goo9971!()();

    S9971.init.goo!()();
}

/******************************************/
// 9977

void test9977()
{
    struct S1(T) { T value; }
    auto func1(T)(T value) { return value; }
    static assert(is(S1!int == struct));
    assert(func1(10) == 10);

    template S2(T) { struct S2 { T value; } }
    template func2(T) { auto func2(T value) { return value; } }
    static assert(is(S2!int == struct));
    assert(func2(10) == 10);

    template X(T) { alias X = T[3]; }
    static assert(is(X!int == int[3]));

    int a;
    template Y(T) { alias Y = T[typeof(a)]; }
    static assert(is(Y!double == double[int]));

    int v = 10;
    template Z() { alias Z = v; }
    assert(v == 10);
    Z!() = 20;
    assert(v == 20);
}

/******************************************/
// 9990

auto initS9990() { return "hi"; }

class C9990(alias init) {}

alias SC9990 = C9990!(initS9990);

/******************************************/
// 10067

struct assumeSize10067(alias F) {}

template useItemAt10067(size_t idx, T)
{
    void impl(){ }

    alias useItemAt10067 = assumeSize10067!(impl);
}

useItemAt10067!(0, char) mapS10067;

/******************************************/
// 10134

template ReturnType10134(alias func)
{
    static if (is(typeof(func) R == return))
        alias R ReturnType10134;
    else
        static assert(0);
}

struct Result10134(T) {}

template getResultType10134(alias func)
{
    static if(is(ReturnType10134!(func.exec) _ == Result10134!(T), T))
    {
        alias getResultType10134 = T;
    }
}

template f10134(alias func)
{
    Result10134!(getResultType10134!(func)) exec(int i)
    {
        return typeof(return)();
    }
}

template a10134()
{
    Result10134!(double) exec(int i)
    {
        return b10134!().exec(i);
    }
}

template b10134()
{
    Result10134!(double) exec(int i)
    {
        return f10134!(a10134!()).exec(i);
    }
}

pragma(msg, getResultType10134!(a10134!()));

/******************************************/

int main()
{
    test1();
    test2();
    test3();
    test4();
    test5();
    test6();
    test7();
    test8();
    test9();
    test1780();
    test3608();
    test5893();
    test6404();
    test2246();
    test2296();
    bug4984();
    test2579();
    test5886();
    test5393();
    test5896();
    test6825();
    test6789();
    test2778();
    test2778aa();
    test2778get();
    test6208a();
    test6208b();
    test6208c();
    test6738();
    test6780();
    test6891();
    test6994();
    test6764();
    test3467();
    test4413();
    test5525();
    test5801();
    test10();
    test7037();
    test7124();
    test7359();
    test7416();
    test7563();
    test7572();
    test7580();
    test7585();
    test7671();
    test7672();
    test7684();
    test11a();
    test11b();
    test7769();
    test7873();
    test7933();
    test8094();
    test12();
    test8125();
    test13();
    test14();
    test8129();
    test8238();
    test8669();
    test8833();
    test8976();
    test8940();
    test9026();
    test9038();
    test9076();
    test9100();
    test9124a();
    test9124b();
    test9143();
    test9266();
    test9536();
    test9837();
    test9874();
    test9885();
    test9971();
    test9977();

    printf("Success\n");
    return 0;
}
