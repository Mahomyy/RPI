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
   (gpio-digital-write row3 1)))  ;initieel waarde wanneer er geen lampen branden

(init)

(define current-row row2)
(define current-column col2)

(list current-row current-column)


(define (one-pin-on-row row)
  (cond ((eq? row row1)  (gpio-digital-write row1 0))
        ((eq? row row2)  (gpio-digital-write row2 0))
        ((eq? row row3)  (gpio-digital-write row3 0))
        (else (error "Invalid row: " row))))

(define (one-pin-on-column column)
  (cond ((eq? column col1)  (gpio-digital-write col1 1))
        ((eq? column col2)  (gpio-digital-write col2 1))
        ((eq? column col3)  (gpio-digital-write col3 1))
        (else (error "Invalid column: " column))))

(one-pin-on-row current-row)
(one-pin-on-column current-column)



(define(make-accelerometer)
  (let((X_CH 0)
       (Y_CH 1)
       (Z_CH 2))

    (define spi-channel 0)
    (define channel-config-single 8)
    (define channel-config-diff 0)
    (define channel-config channel-config-single)
    (gpio-mcp3008-setup spi-channel)

    (define sample-size 10)

    (define (read-axis ch) 
      (let ((reading 0)
            (channel (select-channel ch)))
        (gpio-mcp3008-analog-read spi-channel channel-config channel)
        (gpio-delay-ms 1)
        (for ([i sample-size]) 
          (set! reading
                (+ reading (gpio-mcp3008-analog-read spi-channel channel-config channel))))
        (/ reading (exact->inexact sample-size))))

    (define(select-channel channel)
      (case channel
        ((X)
         X_CH)
        ((Y)
         Y_CH)
        ((Z)
         Z_CH)))

    (define(dispatch m)
      (cond
        ((eq? m 'read-axis) read-axis)
        (else "Message not understood")))

    dispatch))
  



(define (calculate-new-row direction current-row)
  (cond
    ((and (eq? direction 'up) (= current-row row1)) current-row)
    ((and (eq? direction 'down) (= current-row row3)) current-row)
    ((and (eq? direction 'up) (eq? current-row row2)) row1)
    ((and (eq? direction 'up) (eq? current-row row3)) row2)
    ((and (eq? direction 'down) (eq? current-row row2)) row3)
    ((and (eq? direction 'down) (eq? current-row row1)) row2)
    (else current-row)))

(define (calculate-new-column direction current-column)
  (cond
    ((and (eq? direction 'left) (= current-column col1)) current-column)
    ((and (eq? direction 'right) (= current-column col3)) current-column)
    ((and (eq? direction 'left) (eq? current-column col2))  col1)
    ((and (eq? direction 'left) (eq? current-column col3))  col2)
    ((and (eq? direction 'right) (eq? current-column col1))  col2)
    ((and (eq? direction 'right) (eq? current-column col2)) col3)
    (else current-column)))

(define (pin-can-move?)
  (and (not (= current-row row1))
       (not (= current-row row3))
       (not (= current-column col1))
       (not (= current-column col3))))

(define accelerometer (make-accelerometer))


(define x-value 512)
(define y-value 512)


(define (accelerometer-move)
    (if pin-can-move?
        (let* ((current-x ((accelerometer 'read-axis) 'X))
               (current-y ((accelerometer 'read-axis) 'Y))
               (left-sensivity (- current-x 16))
               (right-sensivity (+ current-x 16))   ; ik doe dit zodat het niet direct wanneer ik de breadboard maar een beetje beweeg tot gang schiet.
               (up-sensivity (- current-y 16))
               (down-sensivity (+ current-y 16))
               (directions '()))
          (when (< x-value left-sensivity)
            (set! directions (cons 'left directions)))
          (when (> x-value right-sensivity)
            (set! directions (cons 'right directions)))
          (when (< y-value up-sensivity)
            (set! directions (cons 'down directions)))
          (when (> y-value down-sensivity)
            (set! directions (cons 'up directions)))

          (for-each (lambda (direction)
                      (cond
                        ((eq? direction 'left)
                         (begin
                           (set! current-column (calculate-new-column 'left current-column))
                           (init)
                           (one-pin-on-row current-row)
                           (one-pin-on-column current-column)))

                        ((eq? direction 'right)
                         (begin
                           (set! current-column (calculate-new-column 'right current-column))
                           (init)
                           (one-pin-on-row current-row)
                           (one-pin-on-column current-column)))

                        ((eq? direction 'up)
                         (begin
                           (set! current-row (calculate-new-row 'up current-row))
                           (init)
                           (one-pin-on-row current-row)
                           (one-pin-on-column current-column)))

                        ((eq? direction 'down)
                         (begin
                           (set! current-row (calculate-new-row 'down current-row))
                           (init)
                           (one-pin-on-row current-row)
                           (one-pin-on-column current-column)))))
                    directions)

          (cons current-row current-column)) 
      (cons current-row current-column)))


(define (non-stop-loop)

  
 (let* ((start-time (current-seconds))
         (duration 10))
   
    (let loop ()
       (accelerometer-move)
      (let ((timer (- (current-seconds) start-time)))
        (if (< timer duration)
           (loop)
           (init)))))

  0)

 

(non-stop-loop) 



