// REQUIRED_ARGS: -d
// PERMUTE_ARGS: -dw

import std.stdio;
import std.c.stdlib;

enum
{
    T_char,
    T_wchar,
    T_dchar,
    T_bit,
    T_byte,
    T_ubyte,
    T_short,
    T_ushort,
    T_int,
    T_uint,
    T_long,
    T_ulong,
}

int dotype(char x) { return T_char; }
int dotype(bool x) { return T_bit; }
int dotype(byte x) { return T_byte; }
int dotype(ubyte x) { return T_ubyte; }
int dotype(wchar x) { return T_wchar; }
int dotype(short x) { return T_short; }
int dotype(ushort x) { return T_ushort; }
int dotype(int x) { return T_int; }
int dotype(uint x) { return T_uint; }
int dotype(long x) { return T_long; }
int dotype(ulong x) { return T_ulong; }

void test1()
{
    /*
     * 0x7FFF             077777                  32767
     * 0x8000             0100000                 32768
     * 0xFFFF             0177777                 65535
     * 0x10000            0200000                 65536
     * 0x7FFFFFFF         017777777777            2147483647
     * 0x80000000         020000000000            2147483648
     * 0xFFFFFFFF         037777777777            4294967295
     * 0x100000000        040000000000            4294967296
     * 0x7FFFFFFFFFFFFFFF 0777777777777777777777  9223372036854775807
     * 0x8000000000000000 01000000000000000000000 9223372036854775808
     * 0xFFFFFFFFFFFFFFFF 01777777777777777777777 18446744073709551615
     */

    assert(dotype(1) == T_int);

    /***************** Hexadecimal ***********************/

    assert(dotype(0) == T_int);
    assert(dotype(0x7FFF) == T_int);
    assert(dotype(0x8000) == T_int);
    assert(dotype(0xFFFF) == T_int);
    assert(dotype(0x10000) == T_int);
    assert(dotype(0x7FFFFFFF) == T_int);
    assert(dotype(0x80000000) == T_uint);
    assert(dotype(0xFFFFFFFF) == T_uint);
    assert(dotype(0x100000000) == T_long);
    assert(dotype(0x7FFFFFFFFFFFFFFF) == T_long);
    assert(dotype(0x8000000000000000) == T_ulong);
    assert(dotype(0xFFFFFFFFFFFFFFFF) == T_ulong);

    assert(dotype(0u) == T_uint);
    assert(dotype(0x7FFFu) == T_uint);
    assert(dotype(0x8000u) == T_uint);
    assert(dotype(0xFFFFu) == T_uint);
    assert(dotype(0x10000u) == T_uint);
    assert(dotype(0x7FFFFFFFu) == T_uint);
    assert(dotype(0x80000000u) == T_uint);
    assert(dotype(0xFFFFFFFFu) == T_uint);
    assert(dotype(0x100000000u) == T_ulong);
    assert(dotype(0x7FFFFFFFFFFFFFFFu) == T_ulong);
    assert(dotype(0x8000000000000000u) == T_ulong);
    assert(dotype(0xFFFFFFFFFFFFFFFFu) == T_ulong);

    assert(dotype(0L) == T_long);
    assert(dotype(0x7FFFL) == T_long);
    assert(dotype(0x8000L) == T_long);
    assert(dotype(0xFFFFL) == T_long);
    assert(dotype(0x10000L) == T_long);
    assert(dotype(0x7FFFFFFFL) == T_long);
    assert(dotype(0x80000000L) == T_long);
    assert(dotype(0xFFFFFFFFL) == T_long);
    assert(dotype(0x100000000L) == T_long);
    assert(dotype(0x7FFFFFFFFFFFFFFFL) == T_long);
    assert(dotype(0x8000000000000000L) == T_ulong);
    assert(dotype(0xFFFFFFFFFFFFFFFFL) == T_ulong);

    assert(dotype(0uL) == T_ulong);
    assert(dotype(0x7FFFuL) == T_ulong);
    assert(dotype(0x8000uL) == T_ulong);
    assert(dotype(0xFFFFuL) == T_ulong);
    assert(dotype(0x10000uL) == T_ulong);
    assert(dotype(0x7FFFFFFFuL) == T_ulong);
    assert(dotype(0x80000000uL) == T_ulong);
    assert(dotype(0xFFFFFFFFuL) == T_ulong);
    assert(dotype(0x100000000uL) == T_ulong);
    assert(dotype(0x7FFFFFFFFFFFFFFFuL) == T_ulong);
    assert(dotype(0x8000000000000000uL) == T_ulong);
    assert(dotype(0xFFFFFFFFFFFFFFFFuL) == T_ulong);

    /***************** Octal ***********************/

    assert(dotype(0) == T_int);
    assert(dotype(077777) == T_int);
    assert(dotype(0100000) == T_int);
    assert(dotype(0177777) == T_int);
    assert(dotype(0200000) == T_int);
    assert(dotype(017777777777) == T_int);
    assert(dotype(020000000000) == T_uint);
    assert(dotype(037777777777) == T_uint);
    assert(dotype(040000000000) == T_long);
    assert(dotype(0777777777777777777777) == T_long);
    assert(dotype(01000000000000000000000) == T_ulong);
    assert(dotype(01777777777777777777777) == T_ulong);

    assert(dotype(0u) == T_uint);
    assert(dotype(077777u) == T_uint);
    assert(dotype(0100000u) == T_uint);
    assert(dotype(0177777u) == T_uint);
    assert(dotype(0200000u) == T_uint);
    assert(dotype(017777777777u) == T_uint);
    assert(dotype(020000000000u) == T_uint);
    assert(dotype(037777777777u) == T_uint);
    assert(dotype(040000000000u) == T_ulong);
    assert(dotype(0777777777777777777777u) == T_ulong);
    assert(dotype(01000000000000000000000u) == T_ulong);
    assert(dotype(01777777777777777777777u) == T_ulong);

    assert(dotype(0L) == T_long);
    assert(dotype(077777L) == T_long);
    assert(dotype(0100000L) == T_long);
    assert(dotype(0177777L) == T_long);
    assert(dotype(0200000L) == T_long);
    assert(dotype(017777777777L) == T_long);
    assert(dotype(020000000000L) == T_long);
    assert(dotype(037777777777L) == T_long);
    assert(dotype(040000000000L) == T_long);
    assert(dotype(0777777777777777777777L) == T_long);
    assert(dotype(01000000000000000000000L) == T_ulong);
    assert(dotype(01777777777777777777777L) == T_ulong);

    assert(dotype(0uL) == T_ulong);
    assert(dotype(077777uL) == T_ulong);
    assert(dotype(0100000uL) == T_ulong);
    assert(dotype(0177777uL) == T_ulong);
    assert(dotype(0200000uL) == T_ulong);
    assert(dotype(017777777777uL) == T_ulong);
    assert(dotype(020000000000uL) == T_ulong);
    assert(dotype(037777777777uL) == T_ulong);
    assert(dotype(040000000000uL) == T_ulong);
    assert(dotype(0777777777777777777777uL) == T_ulong);
    assert(dotype(01000000000000000000000uL) == T_ulong);
    assert(dotype(01777777777777777777777uL) == T_ulong);

    /***************** Decimal ***********************/

    assert(dotype(0) == T_int);
    assert(dotype(32767) == T_int);
    assert(dotype(32768) == T_int);
    assert(dotype(65535) == T_int);
    assert(dotype(65536) == T_int);
    assert(dotype(2147483647) == T_int);
    assert(dotype(2147483648) == T_long);
    assert(dotype(4294967295) == T_long);
    assert(dotype(4294967296) == T_long);
    assert(dotype(9223372036854775807) == T_long);
    //assert(dotype(9223372036854775808) == T_long);
    //assert(dotype(18446744073709551615) == T_ulong);

    assert(dotype(0u) == T_uint);
    assert(dotype(32767u) == T_uint);
    assert(dotype(32768u) == T_uint);
    assert(dotype(65535u) == T_uint);
    assert(dotype(65536u) == T_uint);
    assert(dotype(2147483647u) == T_uint);
    assert(dotype(2147483648u) == T_uint);
    assert(dotype(4294967295u) == T_uint);
    assert(dotype(4294967296u) == T_ulong);
    assert(dotype(9223372036854775807u) == T_ulong);
    assert(dotype(9223372036854775808u) == T_ulong);
    assert(dotype(18446744073709551615u) == T_ulong);

    assert(dotype(0L) == T_long);
    assert(dotype(32767L) == T_long);
    assert(dotype(32768L) == T_long);
    assert(dotype(65535L) == T_long);
    assert(dotype(65536L) == T_long);
    assert(dotype(2147483647L) == T_long);
    assert(dotype(2147483648L) == T_long);
    assert(dotype(4294967295L) == T_long);
    assert(dotype(4294967296L) == T_long);
    assert(dotype(9223372036854775807L) == T_long);
    //assert(dotype(9223372036854775808L) == T_ulong);
    //assert(dotype(18446744073709551615L) == T_ulong);

    assert(dotype(0uL) == T_ulong);
    assert(dotype(32767uL) == T_ulong);
    assert(dotype(32768uL) == T_ulong);
    assert(dotype(65535uL) == T_ulong);
    assert(dotype(65536uL) == T_ulong);
    assert(dotype(2147483647uL) == T_ulong);
    assert(dotype(2147483648uL) == T_ulong);
    assert(dotype(4294967295uL) == T_ulong);
    assert(dotype(4294967296uL) == T_ulong);
    assert(dotype(9223372036854775807uL) == T_ulong);
    assert(dotype(9223372036854775808uL) == T_ulong);
    assert(dotype(18446744073709551615uL) == T_ulong);
}

void test2()
{
    ulong[] a = [ 2_463_534_242UL ];

    foreach(e; a)
        assert(e == 2_463_534_242UL);
}

int main()
{
    test1();
    test2();

    printf("Success\n");
    return 0;
}
