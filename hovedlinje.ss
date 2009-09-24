#lang scheme
(require "spc-lex.ss" "spc-parser.ss")
(run-parser (open-input-file "test.pas"))
(run-lexer (open-input-file "test.pas"))
  
