(module spc-semantic-pass scheme
  (require "spc-structures.ss")
  
  (provide semantic-pass)
  
  (define (raise-error tk msg)
    (raise-user-error (string-append (pos-token->position-string tk) ": " msg)))
  
  (define blocks '())
  
  (define (semantic-pass ast)
    (check-block ast))
  
  (define (check-block block)
    (set! blocks (cons block blocks))
    (check-constants (block-constants block)))
  
  (define (check-constants constants)
    (let loop ([rest constants]
               [checked null])
      (if (null? rest)
          checked
          (let* ([const (car rest)]
                 [id (constant-id const)]
                 [value (constant-value const)])
            (if (list? value) (set! value (cadr value)) null)
            (if (number? (pos-token-val value))
                (loop (cdr rest) (cons const checked))
                (raise-error value 
                             "Only literal or declared constant may be on the right side of constant declaration")))))))
  