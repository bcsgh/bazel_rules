%option reentrant bison-bridge yylineno bison-locations noinput nounput
%option prefix="bazel_test_lexer_"
%{
// lexer.yy.cc can't allow include lexer.yy.h so pretend it's already happened
#define bazel_test_lexer_HEADER_H

#include "tests/gen.lexer.h"

%}

%%
hello  return 42;

.      return 0;
%%