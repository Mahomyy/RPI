#lang racket

(provide (all-defined-out))

(define LSM303D_I2C_ADDR             #x1d) ; The sensor default I2C addr
(define LSM303D_PRD_ID               #x49)  ; LSM303D responds with #x49
(define LSM303D_POWER_MODE_NORMAL    #x00)  ; sensor default power mode

; sensor register address information  
(define LSM303D_TEMP_OUT_L      #x05)    ; Sensor temperature data register (read-only) LSB
(define LSM303D_TEMP_OUT_H      #x06)    ; Sensor temperature data register (read-only) MSB
(define LSM303D_STATUS_M        #x07)    ; Sensor magnetic status register (read-only)
(define LSM303D_OUT_X_L_M       #x08)    ; X-axis magnetic data register (read-only) LSB
(define LSM303D_OUT_X_H_M       #x09)    ; X-axis magnetic data register (read-only) MSB
(define LSM303D_OUT_Y_L_M       #x0A)    ; Y-axis magnetic register (read-only) LSB
(define LSM303D_OUT_Y_H_M       #x0B)    ; Y-axis magnetic data register (read-only) MSB
(define LSM303D_OUT_Z_L_M       #x0C)    ; Z-axis magnetic data register (read-only) LSB
(define LSM303D_OUT_Z_H_M       #x0D)    ; Z-axis magnetic data register (read-only) MSB
(define LSM303D_WHO_AM_I        #x0F)    ; Product ID register (read-only, aka WHO_AM_I)
(define LSM303D_CTRL0           #x1F)    ; rw
(define LSM303D_CTRL1           #x20)    ; rw
(define LSM303D_CTRL2           #x21)    ; rw
(define LSM303D_CTRL3           #x22)    ; rw
(define LSM303D_CTRL4           #x23)    ; rw
(define LSM303D_CTRL5           #x24)    ; rw
(define LSM303D_CTRL6           #x25)    ; rw
(define LSM303D_CTRL7           #x26)    ; rw
(define LSM303D_STATUS_A        #x27)    ; Sensor acceleration status register (read-only)
(define LSM303D_OUT_X_L_A       #x28)    ; X-axis acceleration data register (read-only) LSB
(define LSM303D_OUT_X_H_A       #x29)    ; X-axis acceleration data register (read-only) MSB
(define LSM303D_OUT_Y_L_A       #x2A)    ; Y-axis acceleration data register (read-only) LSB
(define LSM303D_OUT_Y_H_A       #x2B)    ; Y-axis acceleration data register (read-only) MSB
(define LSM303D_OUT_Z_L_A       #x2C)    ; Z-axis acceleration data register (read-only) LSB
(define LSM303D_OUT_Z_H_A       #x2D)    ; Z-axis acceleration data register (read-only) MSB