import logging
import requests
import os
import re

log = logging.getLogger(__name__)

# Telegram tokens - see https://www.mariansauter.de/2018/01/send-telegram-notifications-to-your-mobile-from-python-opensesame/
#
bot_token = 'my token'
bot_chatID = 'my id'

def forward():
    """
    Poll for sms and forward to telegram

    Once sent, delete from autopi
    """

    __salt__['ec2x.query']('AT+CMGF=1')

    args = ['AT+CMGL="ALL"']
    res = __salt__['ec2x.query']('AT+CMGL="ALL"')
    if 'data' in res:
        allmessages = parse(res['data'])
        for message in allmessages:
            log.info ("SMS: "+message['message'])
            bot_sendtext('SMS From: '+message['from']+'\nDate: '+message['date']+'\n\n'+message['message'])
            __salt__['ec2x.query']('AT+CMGD='+message['index'])
            
    return {"msg": "Forward finished"}

# parse output to an array of dictionary
#
def parse(x):
    res = []
    i = 0
    while i < len(x):
        m = re.match('\+CMGL: (\d+),\"(.+)\",\"(.+)\",(.*),\"(.+)\"', x[i])
        if m:
            res.append({'index':m.group(1),'from':m.group(3),'date':m.group(5),'message':x[i+1]})
        else:
            log.info ("SMS: No match "+x[i])
        i += 2
        
    return res

# send message to telegram
#
def bot_sendtext(bot_message):
	send_text = 'https://api.telegram.org/bot' + bot_token + '/sendMessage?chat_id=' + bot_chatID + '&parse_mode=Markdown&text=' + bot_message
	requests.get(send_text)
