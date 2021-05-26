%skeleton "lalr1.cc"
%debug
%locations
%define parse.error verbose

%{

#include "tests/gen.lexer.h"

%}
%define api.prefix {bazel_test_parser}
%param {bazel_test_paser_scan_t scanner}

%token HELLO;

%% /* Grammar rules and actions follow */

%start input;

input : HELLO;