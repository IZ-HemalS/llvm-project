#pragma once
#include <stdio.h>

#undef assert
#define assert(expression) do { if (!(expression)) { printf("FAIL: "); printf(#expression); printf("\n"); exit(1); }; } while (0)