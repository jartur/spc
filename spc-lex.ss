(module spc-lex scheme
  (require parser-tools/lex
           (prefix-in : parser-tools/lex-sre))
  
  (provide run-lexer spc-lexer 
           data delim keywords eoftk 
           (struct-out position) (struct-out tk))
  
  (define-tokens data (INT FLOAT STRING ID))
  (define-tokens delim (LP RP LB RB ASSIGN 
                        EQ GT LT GEQ LEQ 
                        CARET DOT DDOT AST 
                        PLUS MINUS SLASH 
                        COMMA COLON SC NOTEQ))
  
  (define-tokens keywords (AND ARRAY BEGIN CASE CONST DIV DO 
                           DOWNTO ELSE END FILE FOR FUNCTION 
                           GOTO IF IN LABEL MOD NIL NOT OF OR
                           PACKED PROCEDURE PROGRAM RECORD REPEAT
                           SET THEN TO TYPE UNTIL VAR WHILE WITH))
  
  (define-tokens eoftk (EOF))
  
  (define-struct tk (lexeme val) 
    #:property prop:custom-write 
    (λ (token port write?)
      ((if write? write display) (tk-val token) port)))

  (define spc-lexer
    (lexer-src-pos-kw
     ;; Keywords
     (AND ARRAY BEGIN CASE CONST DIV DO DOWNTO 
      ELSE END FILE FOR FUNCTION GOTO IF IN LABEL
      MOD NIL NOT OF OR PACKED PROCEDURE PROGRAM 
      RECORD REPEAT SET THEN TO TYPE UNTIL VAR WHILE WITH)
     
     ;; Symbols
     (((:: #\: #\=) ASSIGN) ((:: #\> #\=) GEQ) 
      ((:: #\< #\=) LEQ) ((:: #\. #\.) DDOT) ((:: #\< #\>) NOTEQ) 
      (#\= EQ) (#\; SC) (#\: COLON) (#\, COMMA) (#\/ SLASH) (#\- MINUS) 
      (#\+ PLUS) (#\* AST) (#\. DOT) ((:or #\^ #\@) CARET) (#\< LT) (#\( LP) (#\) RP) 
      ((:or #\[ (:: #\( #\.)) LB) ((:or #\] (:: #\. #\))) RB) (#\> GT))
     
     ;; Comments
     ((:or whitesp comment) (return-without-pos (spc-lexer input-port)))
     
     ;; EOF
     ((eof) (make-kw-tk token-EOF "EOF"))
         
     ;; Id
     ((:: letter (:* (:or letter digit))) (token-ID (make-tk lexeme (string->symbol lexeme))))
     
     ;; Numbers & strings
     ((:: int (:or (:: #\. digitseq (:? exp)) exp)) 
      (token-FLOAT (make-tk lexeme (string->number lexeme))))
     (int 
      (token-INT (make-tk lexeme (string->number lexeme))))
     ((:: #\' (:* (:or (:~ #\') (:: #\' #\'))) #\') 
      (token-STRING (make-tk lexeme (clean-string lexeme))))))
  
  (define-syntax (lexer-src-pos-kw s)
    (define (char->ci-pattern c)
      (list ':or (char-downcase c) (char-upcase c)))
    
    (define (string->ci-pattern s)
      (if (symbol? s)
          (string->ci-pattern (symbol->string s))
          (cons ':: (map char->ci-pattern (string->list s)))))
    
    (define (token-name s)
      (if (symbol? s)
          (token-name (symbol->string s))
          (string-append "token-" (string-upcase s))))
    
    (define (token-names l)
      (map (λ (s) (string->symbol (token-name s))) (syntax->datum l)))
    
    (syntax-case s ()
      ((_ (kw ...) ((sm n) ...) forms ...)
       (with-syntax ([(seq ...) (map string->ci-pattern 
                                     (syntax->datum (syntax (kw ...))))]
                     [(token-x ...) (token-names (syntax (kw ...)))]
                     [(token-n ...) (token-names (syntax (n ...)))])
         (syntax (lexer-src-pos 
                  (seq (make-kw-tk token-x lexeme))...
                  (sm (make-kw-tk token-n lexeme))...
                  forms ...))))))
  
  (define (make-kw-tk tok lex)
    (tok (make-tk lex (string-upcase lex))))
  
  (define (clean-string str)
    (list->string
     (let loop ([l (cdr (string->list str))])
       (if (null? (cdr l))
           null
           (if (and (char=? (cadr l) #\') (char=? (car l) #\'))
               (loop (cdr l))
               (cons (car l) (loop (cdr l))))))))
  
  (define-lex-abbrevs
    (digit (:/ #\0 #\9))
    (letter (:or (:/ #\a #\z) (:/ #\A #\Z)))
    (whitesp (:or #\newline #\return #\tab #\space #\vtab))
    (comment-end (:or #\} "*)"))
    (comment (:: (:or #\{ "(*") (complement (:: any-string comment-end any-string)) comment-end))
    (digitseq (:+ digit))
    (sign (:or #\+ #\-))
    (int (:: digitseq))
    (exp (:: (:or #\e #\E) (:? sign) int)))
  
  (define (run-lexer ip)
    (port-count-lines! ip)
    (let loop ()
      (let* ([res (spc-lexer ip)]
             [st-pos (position-token-start-pos res)]
             [pos (list (position-line st-pos) (position-col st-pos))]
             [token (position-token-token res)]
             [name (token-name token)]
             [tk (token-value token)]
             [lex (tk-lexeme tk)]
             [val (tk-val tk)])
        (if (string=? lex "EOF")
            null
            (cons (list 'token name 'lexeme lex 'value val 'position pos) (loop)))))))