(module spc-structures scheme
  
  (provide (all-defined-out))
  (define-struct pos-token (val lex col line) 
    #:property prop:custom-write 
    (λ (pt p w?)
      ((if w? write display) (pos-token-val pt) p)))
  
  ;; AST structures
  (define-struct block (labels constants types vars procs css) #:transparent)
  (define-struct constant (id value) #:transparent)
  
  (define-struct type-def (id type) #:transparent)
  (define-struct enum-type (elems) #:transparent)
  (define-struct range-type (start end) #:transparent)
  
  (define-struct packable-type ((packed? #:auto #:mutable)) #:transparent)
  (define-struct (array-type packable-type) (range type) #:transparent)
  (define-struct (record-type packable-type) (fixed variant) #:transparent)
  (define-struct record-section (ids type) #:transparent)
  (define-struct variant-part (selector variants) #:transparent)
  (define-struct variant-selector (id type) #:transparent)
  
  
  )