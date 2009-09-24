(module spc-lex scheme
  (require parser-tools/lex
           (prefix-in : parser-tools/lex-sre))
  
  (define-tokens data (INT FLOAT STRING ID))
  (define-tokens delim (LP RP LB RB ASSIGN EQ GT LT GEQ LEQ CARET DOT DDOT AST PLUS MINUS SLASH COMMA COLON SC NOTEQ))
  (define-tokens keywords (AND ARRAY BEGIN CASE CONST DIV DO DOWNTO ELSE END FILE FOR FUNCTION GOTO IF IN LABEL MOD NIL NOT OF OR PACKED PROCEDURE PROGRAM RECORD REPEAT SET THEN TO TYPE UNTIL VAR WHILE WITH))
  (define-tokens eoftk (EOF))
  
  (define-struct tk (lexeme val))
  
  (define spc-lexer
    (lexer-src-pos
     ;; Comments
     ((:or whitesp comment) (return-without-pos (spc-lexer input-port)))
     
     ;; EOF
     ((eof) (make-kw-tk token-EOF "EOF"))
     
     ;; Symbols
     ((:: #\: #\=) (make-kw-tk token-ASSIGN lexeme))
     ((:: #\> #\=) (make-kw-tk token-GEQ lexeme))
     ((:: #\< #\=) (make-kw-tk token-LEQ lexeme))
     ((:: #\. #\.) (make-kw-tk token-DDOT lexeme))
     ((:: #\< #\>) (make-kw-tk token-NOTEQ lexeme))
     (#\> (make-kw-tk token-GT lexeme))
     (#\= (make-kw-tk token-EQ lexeme))
     (#\; (make-kw-tk token-SC lexeme))
     (#\: (make-kw-tk token-COLON lexeme))
     (#\, (make-kw-tk token-COMMA lexeme))
     (#\/ (make-kw-tk token-SLASH lexeme))
     (#\- (make-kw-tk token-MINUS lexeme))
     (#\+ (make-kw-tk token-PLUS lexeme))
     (#\* (make-kw-tk token-AST lexeme))
     (#\. (make-kw-tk token-DOT lexeme))
     (#\^ (make-kw-tk token-CARET lexeme))
     (#\< (make-kw-tk token-LT lexeme))
     (#\( (make-kw-tk token-LP lexeme))
     (#\) (make-kw-tk token-RP lexeme))
     (#\[ (make-kw-tk token-LB lexeme))
     (#\] (make-kw-tk token-RB lexeme))
     
     ;; Keywords
     ((:: a n d) (make-kw-tk token-AND lexeme))
     ((:: a r r a y) (make-kw-tk token-ARRAY lexeme))
     ((:: b e g i n) (make-kw-tk token-BEGIN lexeme))
     ((:: c a s e) (make-kw-tk token-CASE lexeme))
     ((:: c o n s t) (make-kw-tk token-CONST lexeme))
     ((:: d i v) (make-kw-tk token-DIV lexeme))
     ((:: d o) (make-kw-tk token-DO lexeme))
     ((:: d o w n t o) (make-kw-tk token-DOWNTO lexeme))
     ((:: e l s e) (make-kw-tk token-ELSE lexeme))
     ((:: e n d) (make-kw-tk token-END lexeme))
     ((:: f i l e) (make-kw-tk token-FILE lexeme))
     ((:: f o r) (make-kw-tk token-FOR lexeme))
     ((:: f u n c t i o n) (make-kw-tk token-FUNCTION lexeme))
     ((:: g o t o) (make-kw-tk token-GOTO lexeme))
     ((:: i f) (make-kw-tk token-IF lexeme))
     ((:: i n) (make-kw-tk token-IN lexeme))
     ((:: l a b e l) (make-kw-tk token-LABEL lexeme))
     ((:: m o d) (make-kw-tk token-MOD lexeme))
     ((:: n i l) (make-kw-tk token-NIL lexeme))
     ((:: n o t) (make-kw-tk token-NOT lexeme))
     ((:: o f) (make-kw-tk token-OF lexeme))
     ((:: o r) (make-kw-tk token-OR lexeme))
     ((:: p a c k e d) (make-kw-tk token-PACKED lexeme))
     ((:: p r o c e d u r e) (make-kw-tk token-PROCEDURE lexeme))
     ((:: p r o g r a m) (make-kw-tk token-PROGRAM lexeme))
     ((:: r e c o r d) (make-kw-tk token-RECORD lexeme))
     ((:: r e p e a t) (make-kw-tk token-REPEAT lexeme))
     ((:: s e t) (make-kw-tk token-SET lexeme))
     ((:: t h e n) (make-kw-tk token-THEN lexeme))
     ((:: t o) (make-kw-tk token-TO lexeme))
     ((:: t y p e) (make-kw-tk token-TYPE lexeme))
     ((:: u n t i l) (make-kw-tk token-UNTIL lexeme))
     ((:: v a r) (make-kw-tk token-VAR lexeme))
     ((:: w h i l e) (make-kw-tk token-WHILE lexeme))
     ((:: w i t h) (make-kw-tk token-WITH lexeme))
     
     ;; Id
     ((:: letter (:* (:or letter digit))) (make-kw-tk token-ID lexeme))
     
     ;; Numbers & strings
     ((:: int (:or (:: #\. digitseq (:? exp)) exp)) 
      (token-FLOAT (make-tk lexeme (string->number lexeme))))
     (int 
      (token-INT (make-tk lexeme (string->number lexeme))))
     ((:: #\' (:* (:or (:~ #\') (:: #\' #\'))) #\') 
      (token-STRING (make-tk lexeme (clean-string lexeme))))))
  
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
    (exp (:: (:or #\e #\E) (:? sign) int))
    
    (a (:or #\a #\A))    (b (:or #\b #\B))    (c (:or #\c #\C))
    (d (:or #\d #\D))    (e (:or #\e #\E))    (f (:or #\f #\F))
    (g (:or #\g #\G))    (h (:or #\h #\H))    (i (:or #\i #\I))
    (j (:or #\j #\J))    (k (:or #\k #\K))    (l (:or #\l #\L))
    (m (:or #\m #\M))    (n (:or #\n #\N))    (o (:or #\o #\O))
    (p (:or #\p #\P))    (q (:or #\q #\Q))    (r (:or #\r #\R))
    (s (:or #\s #\S))    (t (:or #\t #\T))    (u (:or #\u #\U))
    (v (:or #\v #\V))    (w (:or #\w #\W))    (x (:or #\x #\X))
    (y (:or #\y #\Y))    (z (:or #\z #\Z)))
  
  (define (gen-tokens lst)
    (define (spl str)
      (map (λ (x) (string->symbol (string (char-downcase x)))) (string->list str)))
    (let loop ([l lst])
      (if (null? l)
          null
          (let ([s (symbol->string (car l))])
            (cons (list (cons ':: (spl s)) (list 'make-kw-tk (string->symbol (string-append "token-" (string-upcase s))) 'lexeme)) (loop (cdr l)))))))
  
  (define (genn)
    (let loop ([c #\a])
      (if (char=? c (integer->char (+ 1 (char->integer #\z))))
          null
          (cons (list (string->symbol (string c)) (list ':or c (char-upcase c))) (loop (integer->char (+ 1 (char->integer c))))))))
   
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
            (cons (list 'token name 'lexeme lex 'value val 'position pos) (loop))))))
  
    (provide run-lexer spc-lexer data delim keywords eoftk (struct-out position) tk-lexeme tk-val))