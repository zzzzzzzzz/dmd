
import std.stdio;
import std.math;
import core.bitop;

/*******************************************/

void test1()
{
    writefln("%a", sin(6.8));
    auto f = 6.8L;
    writefln("%a", sin(f));
    assert(sin(f) == sin(6.8));
    static assert(sin(6.8) == 0x1.f9f8d9aea10fdf1cp-2);

    writefln("%a", cos(6.8));
    f = 6.8L;
    writefln("%a", cos(f));
    assert(cos(f) == cos(6.8));
    static assert(cos(6.8) == 0x1.bd21aaf88dcfa13ap-1);

    writefln("%a", tan(6.8));
    f = 6.8L;
    writefln("%a", tan(f));
    version (Win64)
    { }
    else
	assert(tan(f) == tan(6.8));
    static assert(tan(6.8) == 0x1.22fd752af75cd08cp-1);
}

/*******************************************/

void test2()
{
    float i = 3;
    i = i ^^ 2;
    assert(i == 9);

    int j = 2;
    j = j ^^ 1;
    assert(j == 2);

    i = 4;
    i = i ^^ .5;
    assert(i == 2);
}

/**** Bug 5703 *****************************/

static assert({
    int a = 0x80;
    int f = bsf(a);
    int r = bsr(a);
    a = 0x22;
    assert(bsf(a)==1);
    assert(bsr(a)==5);
    a = 0x8000000;
    assert(bsf(a)==27);
    assert(bsr(a)==27);
    a = 0x13f562c0;
    assert(bsf(a) == 6);
    assert(bsr(a) == 28);
    assert(bswap(0xAABBCCDD) == 0xDDCCBBAA);
    return true;
}());

/*******************************************/

int main()
{
    test1();
    test2();

    printf("Success\n");
    return 0;
}
