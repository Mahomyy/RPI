#lang racket

(require "raspi-gpio.rkt")

(gpio-setup)
(gpio-mcp23017-setup 100 #x21) 


(define col1 (+ 100 3))
(define col2 (+ 100 4))
(define col3 (+ 100 1))
(define row1 (+ 100 15))
(define row2 (+ 100 14))
(define row3 (+ 100 0))

(define column-pins (list (+ 100 3) (+ 100 4) (+ 100 1)))
(define row-pins (list (+ 100 15) (+ 100 14) (+ 100 0)))

(define (init)
 (begin
   (gpio-set-pin-mode col1 'output)
   (gpio-set-pin-mode col2 'output)
   (gpio-set-pin-mode col3 'output)
   (gpio-set-pin-mode row1 'output)
   (gpio-set-pin-mode row2 'output)
   (gpio-set-pin-mode row3 'output)

   (gpio-digital-write col1 0)
   (gpio-digital-write col2 0)
   (gpio-digital-write col3 0)
   (gpio-digital-write row1 1)
   (gpio-digital-write row2 1)
   (gpio-digital-write row3 1)))  ;initieel waarde is wanneer er geen lampen branden

(init)


(define pattern (list (list 1 1 1)
                      (list 1 1 0)
                      (list 1 0 0)))

(define pattern2 (list (list 1 0 0)
                      (list 1 1 1)
                      (list 1 1 1)))

(define pattern3 (list (list 0 1 1)
                       (list 1 0 1)
                       (list 0 0 1)))


                    

(define (draw pattern delay)
  (define (write-column column pin value)
    (gpio-set-pin-mode pin 'output)
    (gpio-digital-write pin value))

  (define (turn-on-row row pin)
    (gpio-set-pin-mode pin 'output)
    (gpio-digital-write pin 0))

  (define (turn-off-row row pin)
    (gpio-set-pin-mode pin 'output)
    (gpio-digital-write pin 1))

  (let loop ((row 0))
    (if (< row 3)
        (begin
          (for-each (lambda (column pin)
                      (write-column column pin (list-ref (list-ref pattern row) column)))
                    '(0 1 2)
                    column-pins)
          (turn-on-row row (list-ref row-pins row))
          (gpio-delay-ms delay)
          (turn-off-row row (list-ref row-pins row))
          (loop (+ row 1)))
     (init))))


(define (main pattern)
  (init)
  
 (let* ((start-time (current-seconds))
         (duration 5))
   
    (let loop ()
      (draw pattern 1)
      (let ((timer (- (current-seconds) start-time)))
        (if (< timer duration)
            (loop)
           (init)))))

  0)

(main pattern1)


