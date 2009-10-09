(module hovedlinje 
        scheme
  (require "spc-lex.ss" 
           "spc-parser.ss" 
           "spc-structures.ss"
           "spc-semantic-pass.ss")

  (define lex-out (make-parameter #f))
  (define ast-out (make-parameter #f))
  (define sem-out (make-parameter #f))

  (define input-file
    (command-line
      #:once-each
      (("-l" "--lexer") "Output lexing results"
                        (lex-out #t))
      (("-a" "--ast") "Output AST"
                      (ast-out #t))
      (("-s" "--semantic-pass") "Give results of semantic pass"
                                (sem-out #t))
      #:args (filename)
      filename))
  
  (define ast #f)
  (define (get-ast)
    (if ast
        ast
        (begin 
          (set! ast (run-parser (open-input-file input-file)))
          ast)))
  
  (when (lex-out)
    (pretty-print (run-lexer (open-input-file input-file))))

  (when (ast-out)
    (pretty-print (get-ast)))
  
  (when (sem-out)
    (pretty-print (semantic-pass (get-ast)))))
