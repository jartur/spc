(module spc-structures scheme
  
  (provide (all-defined-out))
  (define-struct pos-token (val lex col line)
    #:property prop:custom-write
    (λ (pt p w?)
      ((if w? write display) (pos-token-val pt) p)))
  
  (define-syntax (ast-structures s)
    (syntax-case s ()
      ((_ (name fields)...)
       (syntax (begin (define-struct name fields #:transparent) ...)))))
  
  (ast-structures
   (block (labels constants types vars procs css))
   (constant (id value))
   
   (type-def (id type))
   (enum-type (elems))
   (range-type (start end))
   
   (packable-type ((packed? #:auto #:mutable)))
   ((array-type packable-type) (range type))
   ((record-type packable-type) (fixed variant))
   (record-section (ids type))
   (variant-part (selector variants))
   (variant-selector (id type))
   (variant (constants fields))
   ((set-type packable-type) (of))
   ((file-type packable-type) (of))
   
   (pointer-type (to))
   
   (var-decl (ids type))
   (var-access (id accessors))
   (var-accessor-index (expressions))
   (var-accessor-dot (id))
   (var-accessor-pointer ())
   
   (proc-decl (heading body))
   (proc-heading (id params))
   (value-parameters (ids type))
   (var-parameters (ids type))
   (value-array-parameters (ids schema))
   (var-array-parameters (ids schema))
   (packed-array-schema (index-type-spec type))
   (unpacked-array-schema (index-type-specs specifier))
   (index-type-spec (start end s))
   (func-decl (heading body))
   (func-heading (id params type))
   
   (unary-op (op expr))
   (binary-op (op lexpr rexpr))
   (factor-access (id accessor))
   (factor-call (id exprs))
   (set-constructor (members))
   (member-designator (lexpr rexpr))
   
   (assignment (var expr))
   (goto (label))
   
   (proc-arg (expr opt1 opt2))
   (proc-statement (id args))
   )
