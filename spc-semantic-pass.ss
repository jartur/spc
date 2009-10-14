(module spc-semantic-pass scheme
  (require "spc-structures.ss"
           srfi/1)
  
;  (require "spc-parser.ss")
  
  (provide semantic-pass)
  
  (define (raise-error tk msg)
    (raise-user-error (string-append (pos-token->position-string tk) ": " msg)))
  
  (define *blocks* (list (make-block '() 
                                     '() 
                                     (list (make-type-def 'integer 'integer)
                                           (make-type-def 'string 'string)
                                           (make-type-def 'real 'real)
                                           (make-type-def 'boolean 'boolean))
                                     '()
                                     '()
                                     '())))
  
  (define (get-constant name (blocks *blocks*))
    (if (null? blocks)
        #f
        (let loop ([rest (block-constants (car blocks))])
          (if (null? rest)
              (get-constant name (cdr blocks))
              (if (eq? name (constant-id (car rest)))
                  (car rest)
                  (loop (cdr rest)))))))
  
  (define (get-type name type-pred (blocks *blocks*))
    (if (null? blocks)
        #f
        (let loop ([rest (block-types (car blocks))])
          (if (null? rest)
              (get-type name type-pred (cdr blocks))
              (if (eq? name (type-def-id (car rest)))
                  (if (type-pred (type-def-type (car rest)))
                      (car rest)
                      #f)
                  (loop (cdr rest)))))))
  
  (define (semantic-pass ast)
    (check-block ast))
  
  (define (check-block block)
    (set! *blocks* (cons block *blocks*))
    (check-constants (block-constants block))
    (check-types (block-types block)))
 
  (define (check-types types)
    (define (check-types-loop types checked)
      (define (find-in-checked pred name)
        (let ([r (find (λ (td) 
                         (and (eq? name (type-def-id td))
                              (pred (type-def-type td))))
                       checked)])
          (if r (type-def-type r) #f)))
      
      (define ord-type? (λ (x) (or (enum-type? x) (range-type? x))))
      
      (define (check-range-type type)
        (if (range-type? type)
            (let ([s (pos-token-val (range-type-start type))]
                  [e (pos-token-val (range-type-end type))])
              (if (and (ordinal-type-value? s)
                       (ordinal-type-value? e))
                  (make-range-type s e)
                  #f))
            #f)) 
      
      (define (ordinal-type-value? v)
        (or (string? v)
            (number? v)
            (enum-member? v)
            (let ([c (get-constant v)])
              (if (constant? c)
                  (or (string? (constant-value c))
                      (integer? (constant-value c)))
                  #f))))
      
      (define (check-enum-type type)
        (if (enum-type? type)
            #t
            #f))
      
      (define (enum-member? v)
        #f)
      
      (define (check-type-def typedef)
        (let ([id (pos-token-val (type-def-id typedef))]
              [type (type-def-type typedef)])
          (cond [(pos-token? type) #f]
                [(enum-type? type) #f]
                [(range-type? type) (make-type-def id (check-range-type type))]
                
                [(array-type? type)
                 (make-type-def 
                  id
                  (make-array-type
                   ; Check all array range fields
                   (map (λ (t) 
                          (or (check-range-type t)
                              (check-enum-type t)
                              (find-in-checked ord-type? (pos-token-val t))
                              (get-type ord-type? (pos-token-val t) (cdr *blocks*))
                              (raise-error t
                                           "Array range specifier must be an ordinal type")))
                        (array-type-range type))
                   ; Check array type
                   'type-here))]
                
                [(record-type? type) (make-type-def id 'record)]
                [(set-type? type) #f]
                [(file-type? type) #f]
                [(pointer-type? type) #f])))
      (if (null? types)
          checked
          (check-types-loop (cdr types) (cons (check-type-def (car types)) checked))))
    (check-types-loop types '()))
  
  (define (check-constants constants)
    (define (find-in-checked name list)
      (if (null? list)
          #f
          (if (eq? name (constant-id (car list)))
              (car list)
              (find-in-checked name (cdr list)))))
    (let loop ([rest constants]
               [checked null])
      (if (null? rest)
          checked
          (let* ([const (car rest)]
                 [id (pos-token-val (constant-id const))]
                 [value (constant-value const)]
                 [sign (if (list? value) (car value) '+)]
                 [valtk (if (list? value) (cadr value) value)]
                 [val (pos-token-val valtk)])
            (if (or (number? val)
                    (string? val))
                (loop (cdr rest) (cons (make-constant id val) checked))
                ; Look if right hand symbol is known
                (let* ([rhs (find-in-checked val checked)]
                       [rhs (if rhs rhs (get-constant val (cdr *blocks*)))])
                  (if (not rhs)
                      (raise-error valtk 
                                   "Only literal or declared constant may be on the right side of constant declaration")
                      ; Replace right hand symbol with its value
                      (loop (cdr rest) (cons (make-constant id ((if (eq? sign '-) - +) (constant-value rhs))) checked)))))))))
  
 ;  (semantic-pass (run-parser (open-input-file "test.pas")))
  )
  