
(define (self-evaluating? exp)
  (cond ((number? exp) true)
        ((string? exp) true)
        (else false)))

(define (variable? exp) (symbol? exp))

;;(quote <text-of-quotation>
(define (quoted? exp)
  (tagged-list? exp 'quote))
(define (text-of-quotation exp) (cadr exp))
(define (tagged-list? exp tag)
  (if (pair? exp)
      (eq? (car exp) tag)
      false))

;;(set! <var> <value>)
(define (assignment? exp)
  (tagged-list? exp 'set!))
(define (assignment-variable exp) (cadr exp))
(define (assignment-value exp) (caddr exp))

;;(define <var> <value>) or
;;(define (<var> <parameter1> ... <parameterN>) <body>), which is equal to
;;(define <var> (lambda (<parameter1> ... <parameterN>) <body>))
(define (definition? exp)
  (tagged-list? exp 'define))
(define (definition-variable exp)
  (if (symbol? (cadr exp))
      (cadr exp)
      (caadr exp)))
(define (definition-value exp)
  (if (symbol? (cadr exp))
      (caddr exp)
      (make-lambda (cdadr exp)     ;formal parameters
                   (cddr exp))))   ;body

;;lambda
(define (lambda? exp)
  (tagged-list? exp 'lambda))
(define (lambda-parameters exp)
  (cadr exp))
(define (lambda-body exp)
  (cddr exp))
(define (make-lambda parameters body)
  (cons 'lambda (cons parameters body)))

;;if
(define (if? exp)
  (tagged-list? exp 'if))
(define (if-predicate exp) (cadr exp))
(define (if-consequent exp) (caddr exp))
(define (if-alternative exp)
  (if (not (null? (cdddr exp)))
      (cadddr exp)
      'false)) ;;why false
(define (make-if predicate consequent alternative)
  (list 'if predicate consequent alternative))

;;begin
(define (begin? exp) (tagged-list? exp 'begin))
(define (begin-actions exp) (cdr exp))
(define (last-exp? seq) (null? (cdr seq)))
(define (first-exp seq) (car seq))
(define (rest-exps seq) (cdr seq))
(define (sequence->exp seq)
  (cond ((null? seq) seq)
        ((last-exp? seq) (first-exp seq))
        (else (make-begin seq))))
(define (make-begin seq)
  (cons 'begin seq))

;;procedure application
(define (application? exp) (pair? exp))
(define (operator exp) (car exp))
(define (operands exp) (cdr exp))
(define (no-operands? ops) (null? ops))
(define (first-operand ops) (car ops))
(define (rest-operand ops) (cdr ops))

;;cond
(define (cond? exp) (tagged-list? exp 'cond))
(define (cond-clauses exp) (cdr exp))
(define (cond-else-clause? clause)
  (eq? (cond-predicate clause) 'else))
(define (cond-predicate clause) (car clause))
(define (cond-actions clause) (cdr clause))
(define (cond->if exp)
  (expand-clauses (cond-clauses exp)))
(define (expand-clauses clauses)
  (if (null? clauses)
      'false
      (let ((first (car clauses))
            (rest (cdr clauses)))
        (if (cond-else-clause? first)
            (if (null? rest)
                (sequence->exp (cond-actions first))
                (error "ELSE clause isn't last -- COND->IF" clauses))
            (make-if (cond-predicate first)
                     (sequence->exp (cond-actions first))
                     (expand-clauses rest))))))

;scan-out-defines
;(define (scan-out-defines body)
;  (define (name-unsigned defines)
;    (map (lambda (x) (list (definition-variable x) '*unassigned*)) defines))
;  (define (set-values defines)
;    (map (lambda (x) (list 'set! (definition-variable x) (definition-value x))) defines))
;  (define (defines->let exprs defines not-defines)
;    (cond ((null? exprs) (if (null? defines)
;                                body
                                
;                                (list (list 'let (name-unsigned defines) (make-begin (append (set-values defines) (reverse not-defines)))) )
;                            ))
;          ((definition? (car exprs)) (defines->let (cdr exprs) (cons (car exprs) defines) not-defines))
;          (else 
;              (defines->let (cdr exprs) defines (cons (car exprs) not-defines)))
;      )
;    )
;  (defines->let body '() '())
;)

 (define (scan-out-defines body) 
         (define (name-unassigned defines) 
                 (map (lambda (x) (list (definition-variable x) '*unassigned*)) defines)) 
         (define (set-values defines) 
                 (map (lambda (x)  
                                         (list 'set! (definition-variable x) (definition-value x)))  
                          defines)) 
         (define (defines->let exprs defines not-defines) 
                 (cond ((null? exprs)  
                            (if (null? defines) 
                                    body 
                                    (list (list 'let (name-unassigned defines)  
                                                                 (make-begin (append (set-values defines)  
                                                                                                 (reverse not-defines))))))) 
                       ((definition?(car exprs)) 
                            (defines->let (cdr exprs) (cons (car exprs) defines) not-defines)) 
                           (else (defines->let (cdr exprs) defines (cons (car exprs) not-defines))))) 
         (defines->let body '() '())) 

;make-procedure-ex4.16 新的 make-procedure
(define (make-procedure-ex4.16 parameters body env)
    (display (scan-out-defines body))
  (list 'procedure parameters (scan-out-defines body) env))
;替换掉绑定新的
(define make-procedure make-procedure-ex4.16)