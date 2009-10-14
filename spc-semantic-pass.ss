(module spc-semantic-pass scheme
  (require "spc-structures.ss")
  
  (provide semantic-pass)
  
  (define (raise-error tk msg)
    (raise-user-error (string-append (pos-token->position-string tk) ": " msg)))
  
  (define *blocks* '())
  
  (define (get-constant name (blocks *blocks*))
    (if (null? blocks)
        #f
        (let loop ([rest (block-constants (car blocks))])
          (if (null? rest)
              (get-constant name (cdr blocks))
              (if (eq? name (constant-id (car rest)))
                  (car rest)
                  (loop (cdr rest)))))))
  
  (define (semantic-pass ast)
    (check-block ast))
  
  (define (check-block block)
    (set! *blocks* (cons block *blocks*))
    (check-constants (block-constants block)))
  
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
                      (loop (cdr rest) (cons (make-constant id ((if (eq? sign '-) - +) (constant-value rhs))) checked))))))))))
  