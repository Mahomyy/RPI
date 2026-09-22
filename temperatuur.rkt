
#lang racket

(require racket/base)
(require "raspi-gpio-taak.rkt")
(require "lsm303d.rkt")

(define (lsm303d-temperature)
  (begin
   
    (define dev-id #x1d)
  
    (define fd (gpio-i2c-setup dev-id))
  
    (lsm303d-setup fd) ;Registers initialiseren
  
    (define TEMP-OUT-L #x05)
    (define TEMP-OUT-H #x06)
  
    (define temp-l (gpio-i2c-read-reg8 fd TEMP-OUT-L))
    (define temp-h (gpio-i2c-read-reg8 fd TEMP-OUT-H))
  
  
 (define temperature-value (bitwise-ior (*(*(*(*(bitwise-and temp-h #x0F)2)2)2)2) temp-l))


  (define (twos-complement n)
  (if (bitwise-bit-set? n 11)  
      (+ (bitwise-xor #xFFF n) 1)  
      n))  

    (define temperature (twos-complement temperature-value))


    (define temperature2 (/ temperature 8.0))
    
    (define rounded-number (* (inexact->exact (round (* 100 temperature2))) 0.01))
    
      rounded-number))
   

(displayln (lsm303d-temperature))
