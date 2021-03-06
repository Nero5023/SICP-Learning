(define (list-walk setps list)
    (cond ((null? list) '())
          ((= setps 0) list)
          (else 
                (list-walk (- setps 1) (cdr list)))
    )
)

(define (loop? list)
    (define (iter x y)
        (let ((x-walk (list-walk 1 x))
              (y-walk (list-walk 2 y)))
            (cond ((or (null? x-walk) (null? y-walk)) #f)
                  ((eq? x-walk y-walk) #t)
                  (else (iter x-walk y-walk))
            )
        )
    )
    (iter list list)
)