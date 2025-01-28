
#define EXPECT_EQ(l,r) do{assert((l) == (r));}while(0)

#include "dut_tb.cpp"

int main(int argc, char *argv[]) {
    TB tb(argc, argv);
    return 0;
}
