(define (tagged-list? exp tag)
  (if (pair? exp)
      (eq? (car exp) tag)
      #f))

; 基于书上原来方式实现的frame
(define (make-bound! var env)
    (let (frame (first-frame env)
          (vars (frame-variables frame))
          (vals (frame-values frame)))
        (define (scan pre-vars pre-vals vars vals)
            (if (not (null? vars))
                (if (eq? (car vars) var)
                    (begin (set-cdr! pre-vars (cdr vars))
                            (set-cdr! pre-vals (cdr vals)))
                    (scan vars vals (cdr vars) (cdr vals)))
                )
          )
        (scan '() '() vars vals)
    )
)

(define (make-unbound-exp var)
  (cons 'make-unbound! var))

