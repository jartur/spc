(module spc-structures scheme
  
  (provide (all-defined-out))
  (define-struct pos-token (token col line) 
    #:property prop:custom-write 
    (λ (pt p w?)
      ((if w? write display) (pos-token-token pt) p)))
  (define-struct block (labels constants types vars procs css) #:transparent)
  (define-struct constant (id value) #:transparent)
  
  
  )