/*
TEST_OUTPUT:
---
fail_compilation/diag7050c.d(7): Error: safe function 'diag7050c.B.~this' cannot call system function 'diag7050c.A.~this'
---
*/

#line 1
struct A
{
    ~this(){}
}

@safe struct B
{
    A a;
}

@safe void f()
{
    auto x = B.init;
}
