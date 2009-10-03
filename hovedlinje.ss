(module hovedlinje 
        scheme
  (require "spc-lex.ss" 
           "spc-parser.ss" 
           scheme/match 
           "spc-structures.ss")

  (define lex-out (make-parameter #f))
  (define ast-out (make-parameter #f))

  (define input-file
    (command-line
      #:once-each
      (("-l" "--lexer") "Output lexing results"
                        (lex-out #t))
      (("-a" "--ast") "Output AST"
                      (ast-out #t))
      #:args (filename)
      filename))
  
  (when (lex-out)
    (pretty-print (run-lexer (open-input-file input-file))))

  (when (ast-out)
    (pretty-print (run-parser (open-input-file input-file)))))
 
