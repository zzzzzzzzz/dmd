/*
TEST_OUTPUT:
---
fail_compilation/diag5385.d(3): Error: class imports.fail5385.C member privX is not accessible
fail_compilation/diag5385.d(4): Error: class imports.fail5385.C member packX is not accessible
fail_compilation/diag5385.d(5): Error: class imports.fail5385.C member privX2 is not accessible
fail_compilation/diag5385.d(6): Error: class imports.fail5385.C member packX2 is not accessible
fail_compilation/diag5385.d(7): Error: struct imports.fail5385.S member privX is not accessible
fail_compilation/diag5385.d(8): Error: struct imports.fail5385.S member packX is not accessible
fail_compilation/diag5385.d(9): Error: struct imports.fail5385.S member privX2 is not accessible
fail_compilation/diag5385.d(10): Error: struct imports.fail5385.S member packX2 is not accessible
---
*/

import imports.fail5385;

#line 1
void main()
{
    C.privX = 1;
    C.packX = 1;
    C.privX2 = 1;
    C.packX2 = 1;
    S.privX = 1;
    S.packX = 1;
    S.privX2 = 1;
    S.packX2 = 1;
}
