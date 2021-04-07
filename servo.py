#!/usr/bin/env python3
#-- coding: utf-8 --
import RPi.GPIO as GPIO
import time
from picamera import PiCamera
import numpy as np

#Set function to calculate percent from angle
def angle_to_percent (angle) :
    if angle > 180 or angle < 0 :
        return False

    start = 4
    end = 12.5
    ratio = (end - start)/180 #Calcul ratio from angle to percent

    angle_as_percent = angle * ratio

    return start + angle_as_percent


GPIO.setmode(GPIO.BOARD) #Use Board numerotation mode
GPIO.setwarnings(False) #Disable warnings

#Use pin 12 for PWM signal
pwm_gpio_s = [12,33] 
frequence = 50
# now scan the x,y positions
x_s=[0,90,180]
y_s=[90,120,150]

center=90
span=20
x_s=np.linspace(center-span,center+span,num=5,endpoint=True)
y_s=np.linspace(center-span,center+span,num=5,endpoint=True)

GPIO.setup(pwm_gpio_s[0], GPIO.OUT)
GPIO.setup(pwm_gpio_s[1], GPIO.OUT)


camera = PiCamera() 
camera.rotation = 180
pwm_x = GPIO.PWM(pwm_gpio_s[0], frequence)
pwm_y = GPIO.PWM(pwm_gpio_s[1], frequence)
pwm_x.start(angle_to_percent(90))
pwm_y.start(angle_to_percent(90))


try:
	for x in x_s:
		for y in y_s:
			print(x,y)
			time.sleep(1)
			pwm_x.ChangeDutyCycle(angle_to_percent(x))
			pwm_y.ChangeDutyCycle(angle_to_percent(y))

			camera.start_preview()
			time.sleep(1)
			camera.capture('/home/pi/servo_images/image_'+str(x)+'_'+str(y)+'.jpg')
			camera.stop_preview()
except KeyboardInterrupt:
    pass
pwm_x.stop()
pwm_y.stop()
#Close GPIO & cleanup
GPIO.cleanup()
