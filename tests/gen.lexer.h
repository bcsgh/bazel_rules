#ifndef TEST_GEN_LEXER_H_
#define TEST_GEN_LEXER_H_

typedef void* bazel_test_paser_scan_t;

#include "tests/parser.tab.h"

typedef int YYSTYPE;
typedef bazel_test_parser::location YYLTYPE;

int bazel_test_parserlex(YYSTYPE* yylval_param, YYLTYPE* yylloc_param,
                         bazel_test_paser_scan_t yyscanner);

#include "tests/lexer.yy.h"

#endif  // TEST_GEN_LEXER_H_