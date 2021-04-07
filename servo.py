#!/usr/bin/env python3
#-- coding: utf-8 --
import RPi.GPIO as GPIO
import time
from picamera import PiCamera
import numpy as np
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("-x", "--xpos", default=0, type=int, help="x position")
parser.add_argument("-y", "--ypos", default=0, type=int, help="y position")
parser.add_argument("-c", "--center", default=90, type=int, help="center position")
parser.add_argument("-s", "--span", default=20, type=int, help="span of the scan")
parser.add_argument("-n", "--steps", default=3, type=int, help="span of the scan")
args = parser.parse_args()

cli_x=args.xpos
cli_y=args.ypos

center=args.center
span=args.span
steps=args.steps

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

if ((cli_x==0) and (cli_y==0)):
	cli_position=False
else:
	cli_position=True

if cli_position:
	x_s=[cli_x]
	y_s=[cli_y]
else:
	# now scan the x,y positions
	if span==0:
		x_s=[0,90,180]
		y_s=[90,120,150]
	else:
		x_s=np.linspace(center-span,center+span,num=steps,endpoint=True)
		y_s=np.linspace(center-span,center+span,num=steps,endpoint=True)

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
