/*
TEST_OUTPUT:
---
fail_compilation/ice4094.d(11): Error: circular reference to 'ice4094.Zug!(0).Zug.bahn'
fail_compilation/ice4094.d(19): Error: template instance ice4094.Zug!(0) error instantiating
---
*/

struct Zug(int Z)
{
    const bahn = Bug4094!(0).hof.bahn;
}

struct Bug4094(int Q)
{
    Zug!(0) hof;
}

const a = Zug!(0).bahn;
