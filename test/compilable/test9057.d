// PERMUTE_ARGS:
// REQUIRED_ARGS: -c -Icompilable/extra-files

struct Bug9057(T)
{
    T x;
}

void test9507() {
    import imp9057;
    Bug9057!(BugInt) xxx;
}

void test9507_2() {
    import imp9057_2;
    Bug9057!(BugInt) xxx;
}


