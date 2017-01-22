


(define (variable? x)
  (symbol? x))

(define (same-variable? v1 v2)
  (and (variable? v1) (variable? v2) (eq? v1 v2)))

;(define (make-sum a1 a2)
;  (list '+ a1 a2))

;(define (make-product m1 m2)
;  (list '* m1 m2))

(define (sum? x)
  (and (pair? x) (eq? (car x) '+)))

(define (addend s)
  (cadr s))

(define (augend s)
  (caddr s))

(define (product? x)
  (and (pair? x) (eq? (car x) '*)))

(define (multiplier p)
  (cadr p))

(define (mutiplicand p)
  (caddr p))

(define (=number? exp num)
    (and (number? exp) (= exp num)))

(define (make-sum a1 a2)
    (cond ((=number? a1 0) a2)
          ((=number? a2 0) a1)
          ((and (number? a1) (number? a2))
            (+ a1 a2))
          (else 
                (list '+ a1 a2))
    )
)

(define (make-product m1 m2) 
    (cond ((or (=number? m1 0) (=number? m2 0)) 0)
          ((=number? m1 1) m2)
          ((=number? m2 1) m1)
          ((and (number? m1) (number? m2)) 
                (* m1 m2)
          )
          (else
                (list '* m1 m2))
    )
)


(define (deriv exp var)
    (cond ((number? exp) 0)
          ((variable? exp) 
            (if (same-variable? exp var)
              1
              0))
          ((sum? exp)
                (make-sum (deriv (addend exp) var)
                          (deriv (augend exp) var))
          )
          ((product? exp)
                (make-sum (make-product (multiplier exp) 
                                        (deriv (mutiplicand exp) var))
                          (make-product (deriv (multiplier exp) var)
                                        (mutiplicand exp))
                )
          )
          ((exponentiation? exp)
                (let ((n (exponent exp))
                     (u (base exp)))
                    (make-product n
                        (make-product (make-exponentiation u (- n 1))
                                (deriv u var)
                        )
                    )

                )
          )
          (else 
                (error "unknow expression type --DERIV" exp))
    )
)

(define (make-exponentiation base exponent)
    (cond ((= exponent 0) 1)
          ((= exponent 1) base)
          (else 
                (list '** base exponent))
      )    
)

(define (exponentiation? exp)
    (and (pair? exp) (eq? (car exp) '**)))

(define (base exp)
    (cadr exp)) 

(define (exponent exp)
    (caddr exp))