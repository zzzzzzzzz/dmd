// PERMUTE_ARGS: -d -dw
// 249

module test1;

typedef foo bar;
typedef bar foo;

void main () {
        foo blah;
}
