#lang scheme
(require "spc-lex.ss" 
         "spc-parser.ss" 
         scheme/match 
         "spc-structures.ss")
;(run-lexer (open-input-file "test.pas"))

;(let ([ast (run-parser (open-input-file "test.pas"))])
 ; (check-block ast))

(run-parser (open-input-file "test.pas"))

;(define (check-block block o-labels o-consts o-types o-vars o-fns)
;  (match block
;    [(list labels consts types vars fns cs) 
;     (check-consts consts o-consts)]))

;(define (check-consts consts o-consts)
;  (define (check-const-list cl)
;    
;  (match consts 
;    [(list 'consts const-list)
;     (check-const-list const-list)]
;    [_ #t])))
    
  
  
