#from apscheduler.scheduler import Scheduler
from apscheduler.schedulers.background import BackgroundScheduler
import logging
logging.basicConfig()
logging.getLogger('apscheduler').setLevel(logging.DEBUG)
import requests

# Start the scheduler
#sched = Scheduler()
#sched.start()

def job_function():
	subnet=1
	host=215
	n=1
	print("Hello World")
	url='http://192.168.'+str(subnet)+'.'+str(host)+'/cm?cmnd=Power'+str(n)+'%20Off'
	print(url)
	response = requests.get(url).text

# Schedules job_function to be run on the third Friday
# of June, July, August, November and December at 00:00, 01:00, 02:00 and 03:00
#sched.add_cron_job(job_function, month='6-8,11-12', day='3rd fri', hour='0-3')
#sched.add_cron_job(job_function, month='*', day='*', hour='21',minute='14')


scheduler = BackgroundScheduler()
scheduler.start()
scheduler.add_job(job_function, trigger='cron', second=18)
print('here is the schedule')
scheduler.print_jobs() 

input("Press CTLR+C to exit \n\n") 
