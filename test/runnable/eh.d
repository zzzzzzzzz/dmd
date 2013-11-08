// PERMUTE_ARGS: -O -fPIC

extern(C) int printf(const char*, ...);

/****************************************************/

class Abc : Exception
{
    this()
    {
        super("");
    }
    int i;
}

int y;

alias int boo;

void foo(int x)
{
    y = cast(boo)1;
L6:
    try
    {
	printf("try 1\n");
	y += 4;
	if (y == 5)
	    goto L6;
	y += 3;
    }
    finally
    {
	y += 5;
	printf("finally 1\n");
    }
    try
    {
	printf("try 2\n");
	y = 1;
	if (y == 4)
	    goto L6;
	y++;
    }
    catch (Abc c)
    {
	printf("catch 2\n");
	y = 2 + c.i;
    }
    y++;
    printf("done\n");
}

/****************************************************/


class IntException : Exception
{
    this(int i)
    {
	m_i = i;
    super("");
    }

    int getValue()
    {
	return m_i;
    }

    int m_i;
}


void test2()
{
    int	cIterations	=	10;

    int	i;
    long	total_x		=	0;
    long	total_nox	=	0;

    for(int WARMUPS = 2; WARMUPS-- > 0; )
    {
	for(total_x = 0, i = 0; i < cIterations; ++i)
	{
	    total_nox += fn2_nox();
	}
printf("foo\n");

	for(total_nox = 0, i = 0; i < cIterations; ++i)
	{
printf("i = %d\n", i);
	    try
	    {
		int z = 1;

		throw new IntException(z);
	    }
	    catch(IntException x)
	    {
printf("catch, i = %d\n", i);
		total_x += x.getValue();
	    }
	}
    }

    printf("iterations %d totals: %ld, %ld\n", cIterations, total_x, total_nox);
}

int fn2_nox()
{
    return 47;
}


/****************************************************/

void test3()
{
    static int x;
    try
    {
    }
    finally
    {
	printf("a\n");
	assert(x == 0);
	x++;
    }
    printf("--\n");
    assert(x == 1);
    try
    {
	printf("tb\n");
	assert(x == 1);
    }
    finally
    {
	printf("b\n");
	assert(x == 1);
	x++;
    }
    assert(x == 2);
}

/****************************************************/

class Tester
{
	this(void delegate() dg_) { dg = dg_; }
	void delegate() dg;
	void stuff() { dg(); }
}

void test4()
{
	printf("Starting test\n");

	int a = 0;
	int b = 0;
	int c = 0;
	int d = 0;

	try
	{
		a++;
		throw new Exception("test1");
		a++;
	}
	catch(Exception e)
	{
		auto es = e.toString();
                printf("%.*s\n", es.length, es.ptr);
		b++;
	}
	finally
	{
		c++;
	}

	printf("initial test.\n");

	assert(a == 1);
	assert(b == 1);
	assert(c == 1);

	printf("pass\n");

	Tester t = new Tester(
	delegate void()
	{
		try
		{
			a++;
			throw new Exception("test2");
			a++;
		}
		catch(Exception e)
		{
			b++;
			throw e;
			b++;
		}
	});

	try
	{
		c++;
		t.stuff();
		c++;
	}
	catch(Exception e)
	{
		d++;
		string es = e.toString;
		printf("%.*s\n", es.length, es.ptr);
	}

	assert(a == 2);
	assert(b == 2);
	assert(c == 2);
	assert(d == 1);


	int q0 = 0;
	int q1 = 0;
	int q2 = 0;
	int q3 = 0;
	
	Tester t2 = new Tester(
	delegate void()
	{
		try
		{
			q0++;
			throw new Exception("test3");
			q0++;
		}
		catch(Exception e)
		{
			printf("Never called.\n");
			q1++;
			throw e;
			q1++;
		}
	});

	try
	{
		q2++;
		t2.stuff();
		q2++;
	}
	catch(Exception e)
	{
		q3++;
                string es = e.toString;
		printf("%.*s\n", es.length, es.ptr);
	}

	assert(q0 == 1);
	assert(q1 == 1);
	assert(q2 == 1);
	assert(q3 == 1);

	printf("Passed!\n");
}

/****************************************************/

void test5()
{
    char[] result;
    int i = 3;
    while(i--)
    {
	try
	{
	    printf("i: %d\n", i);
	    result ~= 't';
	    if (i == 1)
		continue;
	}
	finally
	{
	    printf("finally\n");
	    result ~= cast(char)('a' + i);
	}
    }
    printf("--- %.*s", result.length, result.ptr);
    if (result != "tctbta")
	assert(0);
}

/****************************************************/

void test6()
{   char[] result;

    while (true)
    {
        try
        {
            printf("one\n");
	    result ~= 'a';
            break;
        }
        finally
        {
            printf("two\n");
	    result ~= 'b';
        }
    }
    printf("three\n");
    result ~= 'c';
    if (result != "abc")
	assert(0);
}

/****************************************************/

string a7;

void doScan(int i)
{
  a7 ~= "a";
  try
  {
    try
    {
	a7 ~= "b";
        return;
    }
    finally
    {
      a7 ~= "c";
    }
  }
  finally
  {
    a7 ~= "d";
  }
}

void test7()
{
        doScan(0);
	assert(a7 == "abcd");
}


/****************************************************
 * Exception chaining tests. See also test4.d
 ****************************************************/
int result1513;

void bug1513a()
{
     throw new Exception("d");        
}

void bug1513b()
{
    try
    {
        try
        {
            bug1513a();
        }
        finally
        {
            result1513 |=4;
           throw new Exception("f");
            
        }
    }
    catch(Exception e)
    { 
        assert(e.msg == "d");
        assert(e.next.msg == "f");
        assert(!e.next.next);
    }
}

void bug1513c()
{
    try
    {
        try
        {
            throw new Exception("a");
        }
        finally
        {
            result1513 |= 1;
            throw new Exception("b");
        }
    }    
    finally
    {
        bug1513b();
        result1513 |= 2;
        throw new Exception("c");
    }
}

void bug1513()
{
    result1513 = 0;
    try
    {        
        bug1513c();        
    }
    catch(Exception e)
    {
        assert(result1513 == 7);
        assert(e.msg == "a");
        assert(e.next.msg == "b");
        assert(e.next.next.msg == "c");
    }
}

void collideone()
{
    try
    {
        throw new Exception("x");
    }
    finally
    {
        throw new Exception("y");
    }
}

void doublecollide()
{
    try
    {
        try
        {
            try
            {
                throw new Exception("p");
            }
            finally
            {
                throw new Exception("q");
            }
        }
        finally
        {
            collideone();
        }
    }
    catch(Exception e)
    {
            assert(e.msg == "p");
            assert(e.next.msg == "q");
            assert(e.next.next.msg == "x");
            assert(e.next.next.next.msg == "y");
            assert(!e.next.next.next.next);
    }        
}

void collidetwo()
{
       try
        {
            try
            {
                throw new Exception("p2");
            }
            finally
            {
                throw new Exception("q2");
            }
        }
        finally
        {
            collideone();
        }
}

void collideMixed()
{
    int works = 6;
    try
    {
        try
        {
            try
            {                
                throw new Exception("e");
            }
            finally
            {
                throw new Error("t");
            }
        }
        catch(Exception f) 
        {    // Doesn't catch, because Error is chained to it.
            works += 2;
        }
    }
    catch(Error z)
    {
        works += 4;
        assert(z.msg=="t"); // Error comes first
        assert(z.next is null);
        assert(z.bypassedException.msg == "e");
    }
    assert(works == 10);
}

class AnotherException : Exception
{
    this(string s)
    {
        super(s);
    }
}

void multicollide()
{
    try
    {
       try
        {
            try
            {
                try
                {
                    throw new Exception("m2");
                }
                finally
                {
                    throw new AnotherException("n2");
                }
            }
            catch(AnotherException s)
            {   // Not caught -- we needed to catch the root cause "m2", not
                // just the collateral "n2" (which would leave m2 uncaught).
                assert(0);
            }
        }
        finally
        {
            collidetwo();
        }
    }
    catch(Exception f)
    {
        assert(f.msg == "m2");
        assert(f.next.msg == "n2");
        Throwable e = f.next.next;
        assert(e.msg == "p2");
        assert(e.next.msg == "q2");
        assert(e.next.next.msg == "x");
        assert(e.next.next.next.msg == "y");
        assert(!e.next.next.next.next);
    }        
}

/****************************************************/

void use9568(char [] x, char [] y) {}

int bug9568()
{
    try
        return 7;
     finally
        use9568(null,null);
}

void test9568()
{
    assert( bug9568() == 7 );
}

/****************************************************/

void test8()
{
  int a;
  goto L2;    // L2 is not addressable.

  try {
      a += 2;
  }
  catch (Exception e) {
      a += 3;
L2: ;
      a += 100;
  }
  assert(a == 100);
}

/****************************************************/

uint foo9(uint i)
{
    try
    {
        ++i;
        return 3;
    }
    catch (Exception e)
    {
        debug printf("Exception happened\n");
    }
    return 4;
}

void test9()
{
    assert(foo9(7) == 3);
}

/****************************************************/

int main()
{
    printf("start\n");
    foo(3);
    test2();
    test3();
    test4();
    test5();
    test6();
    test7();
    
    bug1513();
    doublecollide();
    collideMixed();
    multicollide();
    test9568();

    test8();
    test9();

    printf("finish\n");
    return 0;
}
