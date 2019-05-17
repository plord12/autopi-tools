# autopi-tools

This repository contains a number of tools and custom code for use with the autopi dongle ( see https://www.autopi.io/ ).

## Charge status

This custom code monitors charging of Hyundai Kona Electric ( and compatible ) cars and sends alerts to a telegram account.

![Charge status](/images/charge_status.png)

To use with autopi :

1. If you don't already have a telegram token and chat id, follow instructions at https://www.mariansauter.de/2018/01/send-telegram-notifications-to-your-mobile-from-python-opensesame/
1. Navigate to https://raw.githubusercontent.com/plord12/autopi-tools/master/my_charge_status.py
   1. select all the text
   1. copy to clipboard
1. Navigate to https://my.autopi.io/#/custom-code
   1. click on **Create**
   1. change the name to **my_charge_status**
   1. delete existing code
   1. paste the code copied from step 2 above
   1. add your telegram bot_token and bot_chatId from step 1 above
   1. Click on **Create**.
1. Navigate to https://my.autopi.io/#/jobs
   1. click on **Create**
   1. change the name to **Charge status**
   1. tick **Enabled**
   1. set **Cron Schedule** to * * * * *
   1. set **Function** to **my_charge_status.poll**
   1. set **Returner** to **cloud**
1. Test by charging your car

## Forward SMS

This custom code forwards SMS messages from the autopi dongle to a telegram account.  SMS's are deleted.  This is helpful when the operator sends you top-up messages and keeps the list of SMS's low.

1. If you don't already have a telegram token and chat id, follow instructions at https://www.mariansauter.de/2018/01/send-telegram-notifications-to-your-mobile-from-python-opensesame/
1. Navigate to https://raw.githubusercontent.com/plord12/autopi-tools/master/my_forward_sms.py
   1. select all the text
   1. copy to clipboard
1. Navigate to https://my.autopi.io/#/custom-code
   1. click on **Create**
   1. change the name to **my_forward_sms**
   1. delete existing code
   1. paste the code copied from step 2 above
   1. add your telegram bot_token and bot_chatId from step 1 above
   1. Click on **Create**.
1. Navigate to https://my.autopi.io/#/jobs
   1. click on **Create**
   1. change the name to **Check SMS**
   1. tick **Enabled**
   1. set **Cron Schedule** to 0 * * * *
   1. set **Function** to **my_forward_sms.forward**
   1. set **Returner** to **cloud**
1. Test by sending an SMS to autopi 

## A better route planner

This custom code reports telemetry data from Hyundai Kona Electric ( and compatible ) cars to a better route planner ( https://abetterrouteplanner.com/ ).

![abrp](/images/abrp.png)

1. Note your ABRP token ( ie email address )
   1. Navigate to https://abetterrouteplanner.com/
   1. Show Settings
   1. Show More Settings
   1. Live Car Connection Setup
   1. Next until User Email Address is shown - copy that here 
1. Navigate to https://raw.githubusercontent.com/plord12/autopi-tools/master/my_abrp.py
   1. select all the text
   1. copy to clipboard
1. Navigate to https://my.autopi.io/#/custom-code
   1. click on **Create**
   1. change the name to **my_abrp**
   1. delete existing code
   1. paste the code copied from step 3 above
   1. add your abrp_token from step 1 above
   1. Click on **Create**.
1. Navigate to https://my.autopi.io/#/jobs
   1. click on **Create**
   1. change the name to **ABRP Telemetry**
   1. tick **Enabled**
   1. set **Cron Schedule** to 2,12,22,32,42,52 * * * *
   1. set **Function** to **my_abrp.telemetry**
   1. set **Returner** to **cloud**
1. Test by driving and try the **View Live Data** in https://abetterrouteplanner.com/
