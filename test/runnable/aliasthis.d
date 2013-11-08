
extern (C) int printf(const(char*) fmt, ...);
import core.vararg;

struct Tup(T...)
{
    T field;
    alias field this;

    bool opEquals(const Tup rhs) const
    {
        foreach (i, _; T)
            if (field[i] != rhs.field[i])
                return false;
        return true;
    }
}

Tup!T tup(T...)(T fields)
{
    return typeof(return)(fields);
}

template Seq(T...)
{
    alias T Seq;
}

/**********************************************/

struct S
{
    int x;
    alias x this;
}

int foo(int i)
{
    return i * 2;
}

void test1()
{
    S s;
    s.x = 7;
    int i = -s;
    assert(i == -7);

    i = s + 8;
    assert(i == 15);

    i = s + s;
    assert(i == 14);

    i = 9 + s;
    assert(i == 16);

    i = foo(s);
    assert(i == 14);
}

/**********************************************/

class C
{
    int x;
    alias x this;
}

void test2()
{
    C s = new C();
    s.x = 7;
    int i = -s;
    assert(i == -7);

    i = s + 8;
    assert(i == 15);

    i = s + s;
    assert(i == 14);

    i = 9 + s;
    assert(i == 16);

    i = foo(s);
    assert(i == 14);
}

/**********************************************/

void test3()
{
    Tup!(int, double) t;
    t[0] = 1;
    t[1] = 1.1;
    assert(t[0] == 1);
    assert(t[1] == 1.1);
    printf("%d %g\n", t[0], t[1]);
}

/**********************************************/

struct Iter
{
    bool empty() { return true; }
    void popFront() { }
    ref Tup!(int, int) front() { return *new Tup!(int, int); }
    ref Iter opSlice() { return this; }
}

void test4()
{
    foreach (a; Iter()) { }
}

/**********************************************/

void test5()
{
    static struct Double1 {
        double val = 1;
        alias val this;
    }
    static Double1 x() { return Double1(); }
    x()++;
}

/**********************************************/
// 4617

struct S4617
{
    struct F
    {
        int  square(int  n) { return n*n; }
        real square(real n) { return n*n; }
    }
    F forward;

    alias forward this;

    alias forward.square sqr;    // okay

    int field;
    void mfunc();
    template Templ(){}
    void tfunc()(){}
}

template Id4617(alias k) { alias k Id4617; }

void test4617a()
{
    alias Id4617!(S4617.square) test1;            //NG
    alias Id4617!(S4617.forward.square) test2;    //OK

    alias Id4617!(S4617.sqr) test3;               //okay

    static assert(__traits(isSame, S4617.square, S4617.forward.square));
}

void test4617b()
{
    static struct Sub(T)
    {
        T value;
        @property ref inout(T) payload() inout { return value; }
        alias payload this;
    }

    alias Id4617!(S4617.field) S_field;
    alias Id4617!(S4617.mfunc) S_mfunc;
    alias Id4617!(S4617.Templ) S_Templ;
    alias Id4617!(S4617.tfunc) S_tfunc;

    alias Sub!S4617 T4617;
    alias Id4617!(T4617.field) R_field;
    alias Id4617!(T4617.mfunc) R_mfunc;
    alias Id4617!(T4617.Templ) R_Templ;
    alias Id4617!(T4617.tfunc) R_tfunc;
    static assert(__traits(isSame, R_field, S_field));
    static assert(__traits(isSame, R_mfunc, S_mfunc));
    static assert(__traits(isSame, R_Templ, S_Templ));
    static assert(__traits(isSame, R_tfunc, S_tfunc));

    alias Id4617!(T4617.square) R_sqr;
    static assert(__traits(isSame, R_sqr, S4617.forward.square));
}

/**********************************************/
// 4773

void test4773()
{
    struct Rebindable
    {
        Object obj;
        @property const(Object) get(){ return obj; }
        alias get this;
    }

    Rebindable r;
    if (r) assert(0);
    r.obj = new Object;
    if (!r) assert(0);
}

/**********************************************/
// 5188

void test5188()
{
    struct S
    {
        int v = 10;
        alias v this;
    }

    S s;
    assert(s <= 20);
    assert(s != 14);
}

/***********************************************/

struct Foo {
  void opIndexAssign(int x, size_t i) {
    val = x;
  }
  void opSliceAssign(int x, size_t a, size_t b) {
    val = x;
  }
  int val;
}

struct Bar {
   Foo foo;
   alias foo this;
}

void test6() {
   Bar b;
   b[0] = 1;
   assert(b.val == 1);
   b[0 .. 1] = 2;
   assert(b.val == 2);
}

/**********************************************/
// recursive alias this detection

class C0 {}

class C1 { C2 c; alias c this; }
class C2 { C1 c; alias c this; }

class C3 { C2 c; alias c this; }

struct S0 {}

struct S1 { S2* ps; @property ref get(){return *ps;} alias get this; }
struct S2 { S1* ps; @property ref get(){return *ps;} alias get this; }

struct S3 { S2* ps; @property ref get(){return *ps;} alias get this; }

struct S4 { S5* ps; @property ref get(){return *ps;} alias get this; }
struct S5 { S4* ps; @property ref get(){return *ps;} alias get this; }

struct S6 { S5* ps; @property ref get(){return *ps;} alias get this; }

void test7()
{
    // Able to check a type is implicitly convertible within a finite time.
    static assert(!is(C1 : C0));
    static assert( is(C2 : C1));
    static assert( is(C1 : C2));
    static assert(!is(C3 : C0));
    static assert( is(C3 : C1));
    static assert( is(C3 : C2));

    static assert(!is(S1 : S0));
    static assert( is(S2 : S1));
    static assert( is(S1 : S2));
    static assert(!is(S3 : S0));
    static assert( is(S3 : S1));
    static assert( is(S3 : S2));

    C0 c0;  C1 c1;  C3 c3;
    S0 s0;  S1 s1;  S3 s3;  S4 s4;  S6 s6;

    // Allow merging types that contains alias this recursion.
    static assert( __traits(compiles, c0 is c1));   // typeMerge(c || c) e2->implicitConvTo(t1);
    static assert( __traits(compiles, c0 is c3));   // typeMerge(c || c) e2->implicitConvTo(t1);
    static assert( __traits(compiles, c1 is c0));   // typeMerge(c || c) e1->implicitConvTo(t2);
    static assert( __traits(compiles, c3 is c0));   // typeMerge(c || c) e1->implicitConvTo(t2);
    static assert(!__traits(compiles, s1 is c0));   // typeMerge(c || c) e1
    static assert(!__traits(compiles, s3 is c0));   // typeMerge(c || c) e1
    static assert(!__traits(compiles, c0 is s1));   // typeMerge(c || c) e2
    static assert(!__traits(compiles, c0 is s3));   // typeMerge(c || c) e2

    static assert(!__traits(compiles, s1 is s0));   // typeMerge(s && s) e1
    static assert(!__traits(compiles, s3 is s0));   // typeMerge(s && s) e1
    static assert(!__traits(compiles, s0 is s1));   // typeMerge(s && s) e2
    static assert(!__traits(compiles, s0 is s3));   // typeMerge(s && s) e2
    static assert(!__traits(compiles, s1 is s4));   // typeMerge(s && s) e1 + e2
    static assert(!__traits(compiles, s3 is s6));   // typeMerge(s && s) e1 + e2

    static assert(!__traits(compiles, s1 is 10));   // typeMerge(s || s) e1
    static assert(!__traits(compiles, s3 is 10));   // typeMerge(s || s) e1
    static assert(!__traits(compiles, 10 is s1));   // typeMerge(s || s) e2
    static assert(!__traits(compiles, 10 is s3));   // typeMerge(s || s) e2

    // SliceExp::semantic
    static assert(!__traits(compiles, c1[]));
    static assert(!__traits(compiles, c3[]));
    static assert(!__traits(compiles, s1[]));
    static assert(!__traits(compiles, s3[]));

    // CallExp::semantic
//  static assert(!__traits(compiles, c1()));
//  static assert(!__traits(compiles, c3()));
    static assert(!__traits(compiles, s1()));
    static assert(!__traits(compiles, s3()));

    // AssignExp::semantic
    static assert(!__traits(compiles, { c1[1] = 0; }));
    static assert(!__traits(compiles, { c3[1] = 0; }));
    static assert(!__traits(compiles, { s1[1] = 0; }));
    static assert(!__traits(compiles, { s3[1] = 0; }));
    static assert(!__traits(compiles, { c1[ ] = 0; }));
    static assert(!__traits(compiles, { c3[ ] = 0; }));
    static assert(!__traits(compiles, { s1[ ] = 0; }));
    static assert(!__traits(compiles, { s3[ ] = 0; }));

    // UnaExp::op_overload
    static assert(!__traits(compiles, +c1[1]));
    static assert(!__traits(compiles, +c3[1]));
    static assert(!__traits(compiles, +s1[1]));
    static assert(!__traits(compiles, +s3[1]));
    static assert(!__traits(compiles, +c1[ ]));
    static assert(!__traits(compiles, +c3[ ]));
    static assert(!__traits(compiles, +s1[ ]));
    static assert(!__traits(compiles, +s3[ ]));
    static assert(!__traits(compiles, +c1));
    static assert(!__traits(compiles, +c3));
    static assert(!__traits(compiles, +s1));
    static assert(!__traits(compiles, +s3));

    // ArrayExp::op_overload
    static assert(!__traits(compiles, c1[1]));
    static assert(!__traits(compiles, c3[1]));
    static assert(!__traits(compiles, s1[1]));
    static assert(!__traits(compiles, s3[1]));

    // BinExp::op_overload
    static assert(!__traits(compiles, c1 + 10));    // e1
    static assert(!__traits(compiles, c3 + 10));    // e1
    static assert(!__traits(compiles, 10 + c1));    // e2
    static assert(!__traits(compiles, 10 + c3));    // e2
    static assert(!__traits(compiles, s1 + 10));    // e1
    static assert(!__traits(compiles, s3 + 10));    // e1
    static assert(!__traits(compiles, 10 + s1));    // e2
    static assert(!__traits(compiles, 10 + s3));    // e2

    // BinExp::compare_overload
    static assert(!__traits(compiles, c1 < 10));    // (Object.opCmp(int) is invalid)
    static assert(!__traits(compiles, c3 < 10));    // (Object.opCmp(int) is invalid)
    static assert(!__traits(compiles, 10 < c1));    // (Object.opCmp(int) is invalid)
    static assert(!__traits(compiles, 10 < c3));    // (Object.opCmp(int) is invalid)
    static assert(!__traits(compiles, s1 < 10));    // e1
    static assert(!__traits(compiles, s3 < 10));    // e1
    static assert(!__traits(compiles, 10 < s1));    // e2
    static assert(!__traits(compiles, 10 < s3));    // e2

    // BinAssignExp::op_overload
    static assert(!__traits(compiles, c1[1] += 1));
    static assert(!__traits(compiles, c3[1] += 1));
    static assert(!__traits(compiles, s1[1] += 1));
    static assert(!__traits(compiles, s3[1] += 1));
    static assert(!__traits(compiles, c1[ ] += 1));
    static assert(!__traits(compiles, c3[ ] += 1));
    static assert(!__traits(compiles, s1[ ] += 1));
    static assert(!__traits(compiles, s3[ ] += 1));
    static assert(!__traits(compiles, c1 += c0));   // e1
    static assert(!__traits(compiles, c3 += c0));   // e1
    static assert(!__traits(compiles, s1 += s0));   // e1
    static assert(!__traits(compiles, s3 += s0));   // e1
    static assert(!__traits(compiles, c0 += c1));   // e2
    static assert(!__traits(compiles, c0 += c3));   // e2
    static assert(!__traits(compiles, s0 += s1));   // e2
    static assert(!__traits(compiles, s0 += s3));   // e2
    static assert(!__traits(compiles, c1 += s1));   // e1 + e2
    static assert(!__traits(compiles, c3 += s3));   // e1 + e2

    // ForeachStatement::inferAggregate
    static assert(!__traits(compiles, { foreach (e; s1){} }));
    static assert(!__traits(compiles, { foreach (e; s3){} }));
    static assert(!__traits(compiles, { foreach (e; c1){} }));
    static assert(!__traits(compiles, { foreach (e; c3){} }));

    // Expression::checkToBoolean
    static assert(!__traits(compiles, { if (s1){} }));
    static assert(!__traits(compiles, { if (s3){} }));
}

/***************************************************/
// 2781

struct Tuple2781a(T...) {
    T data;
    alias data this;
}

struct Tuple2781b(T) {
    T data;
    alias data this;
}

void test2781()
{
    Tuple2781a!(uint, float) foo;
    foreach(elem; foo) {}

    {
        Tuple2781b!(int[]) bar1;
        foreach(elem; bar1) {}

        Tuple2781b!(int[int]) bar2;
        foreach(key, elem; bar2) {}

        Tuple2781b!(string) bar3;
        foreach(dchar elem; bar3) {}
    }

    {
        Tuple2781b!(int[]) bar1;
        foreach(elem; bar1) goto L1;

        Tuple2781b!(int[int]) bar2;
        foreach(key, elem; bar2) goto L1;

        Tuple2781b!(string) bar3;
        foreach(dchar elem; bar3) goto L1;
    L1:
        ;
    }


    int eval;

    auto t1 = tup(10, "str");
    auto i1 = 0;
    foreach (e; t1)
    {
        pragma(msg, "[] = ", typeof(e));
        static if (is(typeof(e) == int   )) assert(i1 == 0 && e == 10);
        static if (is(typeof(e) == string)) assert(i1 == 1 && e == "str");
        ++i1;
    }

    auto t2 = tup(10, "str");
    foreach (i2, e; t2)
    {
        pragma(msg, "[", cast(int)i2, "] = ", typeof(e));
        static if (is(typeof(e) == int   )) { static assert(i2 == 0); assert(e == 10); }
        static if (is(typeof(e) == string)) { static assert(i2 == 1); assert(e == "str"); }
    }

    auto t3 = tup(10, "str");
    auto i3 = 2;
    foreach_reverse (e; t3)
    {
        --i3;
        pragma(msg, "[] = ", typeof(e));
        static if (is(typeof(e) == int   )) assert(i3 == 0 && e == 10);
        static if (is(typeof(e) == string)) assert(i3 == 1 && e == "str");
    }

    auto t4 = tup(10, "str");
    foreach_reverse (i4, e; t4)
    {
        pragma(msg, "[", cast(int)i4, "] = ", typeof(e));
        static if (is(typeof(e) == int   )) { static assert(i4 == 0); assert(e == 10); }
        static if (is(typeof(e) == string)) { static assert(i4 == 1); assert(e == "str"); }
    }

    eval = 0;
    foreach (i, e; tup(tup((eval++, 10), 3.14), tup("str", [1,2])))
    {
        static if (i == 0) assert(e == tup(10, 3.14));
        static if (i == 1) assert(e == tup("str", [1,2]));
    }
    assert(eval == 1);

    eval = 0;
    foreach (i, e; tup((eval++,10), tup(3.14, tup("str", tup([1,2])))))
    {
        static if (i == 0) assert(e == 10);
        static if (i == 1) assert(e == tup(3.14, tup("str", tup([1,2]))));
    }
    assert(eval == 1);
}

/**********************************************/
// 6546

void test6546()
{
    class C {}
    class D : C {}

    struct S { C c; alias c this; } // S : C
    struct T { S s; alias s this; } // T : S
    struct U { T t; alias t this; } // U : T

    C c;
    D d;
    S s;
    T t;
    U u;

    assert(c is c);  // OK
    assert(c is d);  // OK
    assert(c is s);  // OK
    assert(c is t);  // OK
    assert(c is u);  // OK

    assert(d is c);  // OK
    assert(d is d);  // OK
    assert(d is s);  // doesn't work
    assert(d is t);  // doesn't work
    assert(d is u);  // doesn't work

    assert(s is c);  // OK
    assert(s is d);  // doesn't work
    assert(s is s);  // OK
    assert(s is t);  // doesn't work
    assert(s is u);  // doesn't work

    assert(t is c);  // OK
    assert(t is d);  // doesn't work
    assert(t is s);  // doesn't work
    assert(t is t);  // OK
    assert(t is u);  // doesn't work

    assert(u is c);  // OK
    assert(u is d);  // doesn't work
    assert(u is s);  // doesn't work
    assert(u is t);  // doesn't work
    assert(u is u);  // OK
}

/**********************************************/
// 6736

void test6736()
{
    static struct S1
    {
        struct S2 // must be 8 bytes in size
        {
            uint a, b;
        }
        S2 s2;
        alias s2 this;
    }
    S1 c;
    static assert(!is(typeof(c + c)));
}

/**********************************************/
// 2777

struct ArrayWrapper(T) {
    T[] array;
    alias array this;
}

// alias array this
void test2777a()
{
    ArrayWrapper!(uint) foo;
    foo.length = 5;  // Works
    foo[0] = 1;      // Works
    auto e0 = foo[0];  // Works
    auto e4 = foo[$ - 1];  // Error:  undefined identifier __dollar
    auto s01 = foo[0..2];  // Error:  ArrayWrapper!(uint) cannot be sliced with[]
}

// alias tuple this
void test2777b()
{
    auto t = tup(10, 3.14, "str", [1,2]);

    assert(t[$ - 1] == [1,2]);

    auto f1 = t[];
    assert(f1[0] == 10);
    assert(f1[1] == 3.14);
    assert(f1[2] == "str");
    assert(f1[3] == [1,2]);

    auto f2 = t[1..3];
    assert(f2[0] == 3.14);
    assert(f2[1] == "str");
}

/****************************************/
// 2787

struct Base2787
{
    int x;
    void foo() { auto _ = x; }
}

struct Derived2787
{
    Base2787 _base;
    alias _base this;
    int y;
    void bar() { auto _ = x; }
}

/***********************************/
// 5679

void test5679()
{
    class Foo {}

    class Base
    {
        @property Foo getFoo() { return null; }
    }
    class Derived : Base
    {
        alias getFoo this;
    }

    Derived[] dl;
    Derived d = new Derived();
    dl ~= d; // Error: cannot append type alias_test.Base to type Derived[]
}

/***********************************/
// 6508

void test6508()
{
    int x, y;
    Seq!(x, y) = tup(10, 20);
    assert(x == 10);
    assert(y == 20);
}

/***********************************/
// 6369

void test6369a()
{
    alias Seq!(int, string) Field;

    auto t1 = Tup!(int, string)(10, "str");
    Field field1 = t1;           // NG -> OK
    assert(field1[0] == 10);
    assert(field1[1] == "str");

    auto t2 = Tup!(int, string)(10, "str");
    Field field2 = t2.field;     // NG -> OK
    assert(field2[0] == 10);
    assert(field2[1] == "str");

    auto t3 = Tup!(int, string)(10, "str");
    Field field3;
    field3 = t3.field;
    assert(field3[0] == 10);
    assert(field3[1] == "str");
}

void test6369b()
{
    auto t = Tup!(Tup!(int, double), string)(tup(10, 3.14), "str");

    Seq!(int, double, string) fs1 = t;
    assert(fs1[0] == 10);
    assert(fs1[1] == 3.14);
    assert(fs1[2] == "str");

    Seq!(Tup!(int, double), string) fs2 = t;
    assert(fs2[0][0] == 10);
    assert(fs2[0][1] == 3.14);
    assert(fs2[0] == tup(10, 3.14));
    assert(fs2[1] == "str");

    Tup!(Tup!(int, double), string) fs3 = t;
    assert(fs3[0][0] == 10);
    assert(fs3[0][1] == 3.14);
    assert(fs3[0] == tup(10, 3.14));
    assert(fs3[1] == "str");
}

void test6369c()
{
    auto t = Tup!(Tup!(int, double), Tup!(string, int[]))(tup(10, 3.14), tup("str", [1,2]));

    Seq!(int, double, string, int[]) fs1 = t;
    assert(fs1[0] == 10);
    assert(fs1[1] == 3.14);
    assert(fs1[2] == "str");
    assert(fs1[3] == [1,2]);

    Seq!(int, double, Tup!(string, int[])) fs2 = t;
    assert(fs2[0] == 10);
    assert(fs2[1] == 3.14);
    assert(fs2[2] == tup("str", [1,2]));

    Seq!(Tup!(int, double), string, int[]) fs3 = t;
    assert(fs3[0] == tup(10, 3.14));
    assert(fs3[0][0] == 10);
    assert(fs3[0][1] == 3.14);
    assert(fs3[1] == "str");
    assert(fs3[2] == [1,2]);
}

void test6369d()
{
    int eval = 0;
    Seq!(int, string) t = tup((++eval, 10), "str");
    assert(eval == 1);
    assert(t[0] == 10);
    assert(t[1] == "str");
}

/**********************************************/
// 6434

struct Variant6434{}

struct A6434
{
   Variant6434 i;
   alias i this;

   void opDispatch(string name)()
   {
   }
}

void test6434()
{
   A6434 a;
   a.weird; // no property 'weird' for type 'VariantN!(maxSize)'
}

/**************************************/
// 6366

void test6366()
{
    struct Zip
    {
        string str;
        size_t i;
        this(string s)
        {
            str = s;
        }
        @property const bool empty()
        {
            return i == str.length;
        }
        @property Tup!(size_t, char) front()
        {
            return typeof(return)(i, str[i]);
        }
        void popFront()
        {
            ++i;
        }
    }

    foreach (i, c; Zip("hello"))
    {
        switch (i)
        {
            case 0: assert(c == 'h');   break;
            case 1: assert(c == 'e');   break;
            case 2: assert(c == 'l');   break;
            case 3: assert(c == 'l');   break;
            case 4: assert(c == 'o');   break;
            default:assert(0);
        }
    }

    auto range(F...)(F field)
    {
        static struct Range {
            F field;
            bool empty = false;
            Tup!F front() { return typeof(return)(field); }
            void popFront(){ empty = true; }
        }
        return Range(field);
    }

    foreach (i, t; range(10, tup("str", [1,2]))){
        static assert(is(typeof(i) == int));
        static assert(is(typeof(t) == Tup!(string, int[])));
        assert(i == 10);
        assert(t == tup("str", [1,2]));
    }
    auto r1 = range(10, "str", [1,2]);
    auto r2 = range(tup(10, "str"), [1,2]);
    auto r3 = range(10, tup("str", [1,2]));
    auto r4 = range(tup(10, "str", [1,2]));
    alias Seq!(r1, r2, r3, r4) ranges;
    foreach (n, _; ranges)
    {
        foreach (i, s, a; ranges[n]){
            static assert(is(typeof(i) == int));
            static assert(is(typeof(s) == string));
            static assert(is(typeof(a) == int[]));
            assert(i == 10);
            assert(s == "str");
            assert(a == [1,2]);
        }
    }
}

/**********************************************/
// Bugzill 6759

struct Range
{
    size_t front() { return 0; }
    void popFront() { empty = true; }
    bool empty;
}

struct ARange
{
    Range range;
    alias range this;
}

void test6759()
{
    ARange arange;
    assert(arange.front == 0);
    foreach(e; arange)
    {
        assert(e == 0);
    }
}

/**********************************************/
// 6479

struct Memory6479
{
    mixin Wrapper6479!();
}
struct Image6479
{
    Memory6479 sup;
    alias sup this;
}
mixin template Wrapper6479()
{
}

/**********************************************/
// 6832

void test6832()
{
    static class Foo { }
    static struct Bar { Foo foo; alias foo this; }
    Bar bar;
    bar = new Foo;          // ok
    assert(bar !is null);   // ng

    struct Int { int n; alias n this; }
    Int a;
    int b;
    auto c = (true ? a : b);    // TODO
    assert(c == a);
}

/**********************************************/
// 6928

void test6928()
{
    struct T { int* p; } // p is necessary.
    T tx;

    struct S {
        T get() const { return tx; }
        alias get this;
    }

    immutable(S) s;
    immutable(T) t;
    static assert(is(typeof(1? s:t))); // ok.
    static assert(is(typeof(1? t:s))); // ok.
    static assert(is(typeof(1? s:t)==typeof(1? t:s))); // fail.

    auto x = 1? t:s; // ok.
    auto y = 1? s:t; // compile error.
}

/**********************************************/
// 6929

struct S6929
{
    T6929 get() const { return T6929.init; }
    alias get this;
}
struct T6929
{
    S6929 get() const { return S6929.init; }
    alias get this;
}
void test6929()
{
    T6929 t;
    S6929 s;
    static assert(!is(typeof(1? t:s)));
}

/***************************************************/
// 7136

void test7136()
{
    struct X
    {
        Object get() immutable { return null; }
        alias get this;
    }
    immutable(X) x;
    Object y;
    static assert( is(typeof(1?x:y) == Object));        // fails
    static assert(!is(typeof(1?x:y) == const(Object))); // fails

    struct A
    {
        int[] get() immutable { return null; }
        alias get this;
    }
    immutable(A) a;
    int[] b;
    static assert( is(typeof(1?a:b) == int[]));         // fails
    static assert(!is(typeof(1?a:b) == const(int[])));  // fails
}

/***************************************************/
// 7731

struct A7731
{
    int a;
}
template Inherit7731(alias X)
{
    X __super;
    alias __super this;
}
struct B7731
{
    mixin Inherit7731!A7731;
    int b;
}

struct PolyPtr7731(X)
{
    X* _payload;
    static if (is(typeof(X.init.__super)))
    {
        alias typeof(X.init.__super) Super;
        @property auto getSuper(){ return PolyPtr7731!Super(&_payload.__super); }
        alias getSuper this;
    }
}
template create7731(X)
{
    PolyPtr7731!X create7731(T...)(T args){
        return PolyPtr7731!X(args);
    }
}

void f7731a(PolyPtr7731!A7731 a) {/*...*/}
void f7731b(PolyPtr7731!B7731 b) {f7731a(b);/*...*/}

void test7731()
{
    auto b = create7731!B7731();
}

/***************************************************/
// 7808

struct Nullable7808(T)
{
    private T _value;

    this()(T value)
    {
        _value = value;
    }

    @property ref inout(T) get() inout pure @safe
    {
        return _value;
    }
    alias get this;
}

class C7808 {}
struct S7808 { C7808 c; }

void func7808(S7808 s) {}

void test7808()
{
    auto s = Nullable7808!S7808(S7808(new C7808));
    func7808(s);
}

/***************************************************/
// 7945

struct S7945
{
    int v;
    alias v this;
}
void foo7945(ref int n){}

void test7945()
{
    auto s = S7945(1);
    foo7945(s);         // 1.NG -> OK
    s.foo7945();        // 2.OK, ufcs
    foo7945(s.v);       // 3.OK
    s.v.foo7945();      // 4.OK, ufcs
}

/***************************************************/
// 7992

struct S7992
{
    int[] arr;
    alias arr this;
}
S7992 func7992(...)
{
    S7992 ret;
    ret.arr.length = _arguments.length;
    return ret;
}
void test7992()
{
    int[] arr;
    assert(arr.length == 0);
    arr ~= func7992(1, 2);  //NG
    //arr = func7992(1, 2); //OK
    assert(arr.length == 2);
}

/***************************************************/
// 8169

void test8169()
{
    static struct ValueImpl
    {
       static immutable(int) getValue()
       {
           return 42;
       }
    }

    static struct ValueUser
    {
       ValueImpl m_valueImpl;
       alias m_valueImpl this;
    }

    static assert(ValueImpl.getValue() == 42); // #0, OK
    static assert(ValueUser.getValue() == 42); // #1, NG -> OK
    static assert(       ValueUser.m_valueImpl .getValue() == 42); // #2, NG -> OK
    static assert(typeof(ValueUser.m_valueImpl).getValue() == 42); // #3, OK
}

/***************************************************/
// 9174

void test9174()
{
    static struct Foo
    {
        char x;
        alias x this;
    }
    static assert(is(typeof(true ? 'A' : Foo()) == char));
    static assert(is(typeof(true ? Foo() : 100) == int));
}

/***************************************************/
// 9177

struct S9177
{
    int foo(int){ return 0; }
    alias foo this;
}
pragma(msg, is(S9177 : int));

/***************************************************/
// 9858

struct S9858()
{
    @property int get() const
    {
        return 42;
    }
    alias get this;
    void opAssign(int) {}
}
void test9858()
{
    const S9858!() s;
    int i = s;
}

/***************************************************/
// 9873

void test9873()
{
    struct Tup(T...) { T field; alias field this; }

    auto seq1 = Seq!(1, "hi");
    assert(Seq!(1, "hi") == Seq!(1, "hi"));
    assert(seq1          == Seq!(1, "hi"));
    assert(Seq!(1, "hi") == seq1);
    assert(seq1          == seq1);

    auto seq2 = Seq!(2, "hi");
    assert(Seq!(1, "hi") != Seq!(2, "hi"));
    assert(seq2          != Seq!(1, "hi"));
    assert(Seq!(1, "hi") != seq2);
    assert(seq2          != seq1);

    auto tup1 = Tup!(int, string)(1, "hi");
    assert(Seq!(1, "hi") == tup1);
    assert(seq1          == tup1);
    assert(tup1          == Seq!(1, "hi"));
    assert(tup1          == seq1);

    auto tup2 = Tup!(int, string)(2, "hi");
    assert(Seq!(1, "hi") != tup2);
    assert(seq1          != tup2);
    assert(tup2          != Seq!(1, "hi"));
    assert(tup2          != seq1);

    static assert(!__traits(compiles, seq1 == Seq!(1, "hi", [1,2])));
    static assert(!__traits(compiles, tup1 == Seq!(1, "hi", [1,2])));
}

/***************************************************/
// 10178

void test10178()
{
    struct S { static int count; }
    S s;
    assert((s.tupleof == s.tupleof) == true);
    assert((s.tupleof != s.tupleof) == false);

    S getS()
    {
        S s;
        ++S.count;
        return s;
    }
    assert(getS().tupleof == getS().tupleof);
    assert(S.count == 2);
}

/***************************************************/
// 9890

void test9890()
{
    struct RefCounted(T)
    {
        T _payload;

        ref T refCountedPayload() 
        {
            return _payload;
        }

        alias refCountedPayload this;
    }

    struct S(int x_) 
    {
        alias x_ x;
    }

    alias RefCounted!(S!1) Rs;
    static assert(Rs.x == 1);
}

/***************************************************/
// 10004

void test10004()
{
    static int count = 0;

    static S make(S)()
    {
        ++count;    // necessary to make this function impure
        S s;
        return s;
    }

    struct SX(T...) {
        T field; alias field this;
    }
    alias S = SX!(int, long);
    assert(make!S.field == make!S.field);
    assert(count == 2);
}

/***************************************************/

int main()
{
    test1();
    test2();
    test3();
    test4();
    test5();
    test4617a();
    test4617b();
    test4773();
    test5188();
    test6();
    test7();
    test2781();
    test6546();
    test6736();
    test2777a();
    test2777b();
    test5679();
    test6508();
    test6369a();
    test6369b();
    test6369c();
    test6369d();
    test6434();
    test6366();
    test6759();
    test6832();
    test6928();
    test6929();
    test7136();
    test7731();
    test7808();
    test7945();
    test7992();
    test8169();
    test9174();
    test9858();
    test9873();
    test10178();
    test9890();
    test10004();

    printf("Success\n");
    return 0;
}
