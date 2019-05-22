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

## Scanning

To try and figure out unknown PID's, I'm trying to use custom code to periodically dump OBD results to the log
file and then later upload and analyze them.  So far I have :

1. Custom code to dump selected PID's for my Kona - https://raw.githubusercontent.com/plord12/autopi-tools/master/my_scan.py 
1. Upload todays log with scp
1. Run https://raw.githubusercontent.com/plord12/autopi-tools/master/analyse.pl on the uploaded log file

```
$ ./analyse.pl minion.2019-05-21
pid 22b00c @ 2019-05-21T00:00:10.859874
BCM 7A8 21 80 00 00 00 01 AA AA [?=128] [Heated Handle=0] [?=0] [?=0] [?=1] [PAD] [PAD]

pid 22b00e @ 2019-05-21T00:00:14.064786
BCM 7A8 21 00 00 00 00 00 AA AA [?=0] [Charge port=0] [?=0] [?=0] [?=0] [PAD] [PAD]

pid 22c002 @ 2019-05-21T00:00:17.994626
BCM 7A8 21 00 C5 BF 4C C1 C5 BF [?=0] [TPMS ID 0=3317648577]
BCM 7A8 22 4B 3C C5 BF 40 BB C5[TPMS ID 1=3305130812] [TPMS ID 2=3317645499]
BCM 7A8 23 BF 4A E2 AA AA AA AA[TPMS ID 3=3149914850] [PAD] [PAD] [PAD] [PAD]

pid 22c00b @ 2019-05-21T00:00:19.331238
BCM 7A8 21 00 B5 47 01 00 BB 49 [?=0] [Tyre Pre_FL=36.2] [Tyre Temp_FL=21] [?=1] [?=0] [Tyre Pre_FR=37.4] [Tyre Temp_FR=23]
BCM 7A8 22 01 00 B8 48 01 00 B5 [?=1] [?=0] [Tyre Pre_RR=36.8] [Tyre Temp_RR=22] [?=1] [?=0] [Tyre Pre_RL=36.2]
BCM 7A8 23 47 01 00 AA AA AA AA [Tyre Temp_RL=21] [?=1] [?=0] [?=170] [PAD] [PAD] [PAD] [PAD]

pid 220101 @ 2019-05-21T00:00:21.072729
BMS 7EC 21 FF BC 21 C6 46 50 03 [?=255] [SOCBMS=94] [MAXREGEN=86.46] [MAXPOWER=180] [BMS?=3]
BMS 7EC 22 FF 5C 0F E7 13 12 12 [BATTCURR=-16.4] [BATTVOLTS=407.1] [BATTPOWER=-6.67644] [BATTMAXT=19] [BATTMINT=18] [BATTTEMP1=18]
BMS 7EC 23 12 12 13 00 00 13 CF [BATTTEMP2=18] [BATTTEMP3=18] [BATTTEMP4=19] [BATTTEMP5=0] [?] [BATTINLETT=19] [MAXCELLV=4.14]
BMS 7EC 24 18 CF 38 00 00 92 00 [MAXCELVNO=24] [MINCELLV=4.14] [MINCELLNO=56] [BATTFANSPD=0] [BATTFANMOD=0] [AUXBATTV=14.6]
BMS 7EC 25 00 B1 CF 00 00 AE F1 [CCC=4551.9] [CDC=4478.5]
BMS 7EC 26 00 00 43 80 00 00 3F [CEC=1728]
BMS 7EC 27 FD 00 1E A9 1A 09 01 [CED=1638.1] [OPTIME=558.158333333333] [?BMSIGN=9]
BMS 7EC 28 97 00 00 00 00 03 E8 [BMSCAP=407] [RPM1=0] [RPM2=0] [SURGER=1000]

pid 220102 @ 2019-05-21T00:00:22.331906
BMS 7EC 21 FF CF CF CF CF CF CF [?=255] [CELLV01=4.14] [CELLV02=4.14] [CELLV03=4.14] [CELLV04=4.14] [CELLV05=4.14] [CELLV06=4.14]
BMS 7EC 22 CF CF CF CF CF CF CF [CELLV07=4.14] [CELLV08=4.14] [CELLV09=4.14] [CELLV10=4.14] [CELLV11=4.14] [CELLV12=4.14] [CELLV13=4.14] 
BMS 7EC 23 CF CF CF CF CF CF CF [CELLV14=4.14] [CELLV15=4.14] [CELLV16=4.14] [CELLV17=4.14] [CELLV18=4.14] [CELLV19=4.14] [CELLV20=4.14] 
BMS 7EC 24 CF CF CF CF CF CF CF [CELLV21=4.14] [CELLV22=4.14] [CELLV23=4.14] [CELLV24=4.14] [CELLV25=4.14] [CELLV26=4.14] [CELLV27=4.14] 
BMS 7EC 25 CF CF CF CF CF AA AA [CELLV28=4.14] [CELLV29=4.14] [CELLV30=4.14] [CELLV31=4.14] [CELLV32=4.14] [PAD] [PAD] 

pid 220103 @ 2019-05-21T00:00:24.615239
BMS 7EC 21 FF CF CF CF CF CF CF [?=255] [CELLV33=4.14] [CELLV34=4.14] [CELLV35=4.14] [CELLV36=4.14] [CELLV37=4.14] [CELLV38=4.14]
BMS 7EC 22 CF CF CF CF CF CF CF [CELLV39=4.14] [CELLV40=4.14] [CELLV41=4.14] [CELLV42=4.14] [CELLV43=4.14] [CELLV44=4.14] [CELLV45=4.14] 
BMS 7EC 23 CF CF CF CF CF CF CF [CELLV46=4.14] [CELLV47=4.14] [CELLV48=4.14] [CELLV49=4.14] [CELLV50=4.14] [CELLV51=4.14] [CELLV52=4.14] 
BMS 7EC 24 CF CF CF CF CF CF CF [CELLV53=4.14] [CELLV54=4.14] [CELLV55=4.14] [CELLV56=4.14] [CELLV57=4.14] [CELLV57=4.14] [CELLV59=4.14] 
BMS 7EC 25 CF CF CF CF CF AA AA [CELLV60=4.14] [CELLV61=4.14] [CELLV62=4.14] [CELLV63=4.14] [CELLV64=4.14] [PAD] [PAD] 
...
```
