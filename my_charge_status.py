import logging
import requests
import pickle
import os
import json
import urllib
from math import sin, cos, sqrt, atan2, radians

log = logging.getLogger(__name__)

# Telegram tokens - see https://www.mariansauter.de/2018/01/send-telegram-notifications-to-your-mobile-from-python-opensesame/
#
bot_token = 'your token'
bot_chatID = 'your chat id'

# Constants
#
# average ICE g/km
ice_emissions = 120.1 

# Average UK g/kWh
# electric_emissions = 225.0 

# Octopus g/kWh
electric_emissions = 0.0 

# max range
#
wltp = 279

# FIX THIS - add in SOH to calcs

# list of non-stanard chargers
#
chargers = [ 
        {'latitude':51.4226469833, 'longitude':-0.855934466667, 'msg':'At home, '+'5p/KWh overnight'}
     ]

"""
Poll to see if car is being charged.  If so :

1. Disable auto sleep whilst charging or driving
2. Send Telegram message when charging starts
    - Estimated miles per kWh ( based on miles travelled and delta Accumulative Charge Power )
    - Estimaed CO2 saved on fuel since last charged ( based on ICE emissions and electricity supplier )
    - Estimated total CO2 saved since purchase ( based on total milage and ICE emissions )
    - Details of nearest charger ( ie probabally what is being used to charge car )
    - Estimated range ( based on WLTP )
3. Send Telegram message when charging reaches each 10%
5. Send Telegram message when charging stops
"""
def poll():
    # enable sleep in case anything goes wrong below
    #
    enable_sleep()

    # load previous status
    #
    persistance = load()

    # check if we are driving or charging
    #
    driving = get_driving()

    # disable sleep if driving or charging
    #
    if driving == 1 or driving == 0:
        disable_sleep()

    if driving == 1 or driving == -1:
        if persistance['charging'] == True:
            if persistance['soc'] >= 99:
                persistance['soc'] = 100
            bot_sendtext('Charging *stopped*. Last known State of charge *'+format(persistance['soc'],'.1f')+'%* ('+format(wltp*persistance['soc']/100, '.1f')+' miles) charged '+format(persistance['cec']-persistance['start_cec'],'.1f')+'kWh')
            persistance['charging'] = False
            save(persistance)
        log.info('End charging poll: Not charging')
        return {'msg': 'Not charging'}

    batt_power = get_charging_power()

    # avoid fake charging
    #
    if batt_power <= 0:
        enable_sleep()
        return {'msg': 'Not charging - power less than zero'}

    # now we are charging
    #
    soc = get_soc()
    cec = get_cec()

    # alert if just started to charge
    #
    if persistance['charging'] == False:
        last_charge_odo = persistance['odo']
        last_charge_soc = persistance['soc']
        odo = get_odometer()
        persistance['odo'] = odo
        persistance['start_cec'] = cec
        if last_charge_soc != soc:
            mperkwh = (odo-last_charge_odo)/(last_charge_soc*64.0/100.0-soc*64.0/100.0)
        else:
            mperkwh = 0.0
        co2saved = (ice_emissions*(odo-last_charge_odo)*1.609) - electric_emissions*(last_charge_soc*64.0/100.0-soc*64.0/100.0)
        bot_sendtext('Estmated *'+format(mperkwh,'.2f')+'mi/kWh* since last charge')
        bot_sendtext('*'+format(co2saved/1000,'.2f')+'Kg* CO2 saved since last charge')
        bot_sendtext('*'+format(odo*ice_emissions/1000000,'.2f')+'tonnes* CO2 saved in total')  
        bot_sendtext(nearest_charger()) 
        bot_sendtext('Charging *started* at a rate of '+format(batt_power,'.2f')+'kW. State of charge now *'+format(soc,'.1f')+'%* ('+format(wltp*soc/100, '.1f')+' miles)')

    # each 10% alaert
    #
    for level in xrange(0, 100, 10):
        if soc >= level and persistance['soc'] < level:
            bot_sendtext('Charging *now* at a rate of '+format(batt_power,'.2f')+'kW. State of charge now *'+format(soc,'.1f')+'%* ('+format(wltp*soc/100, '.1f')+' miles)')
            break

    # store status for next time
    #
    persistance['charging'] = True
    persistance['soc'] = soc
    persistance['cec'] = cec
    save(persistance)

    return {'msg': 'Charging at '+format(batt_power,'.2f')+'kW, SOC now *'+format(soc,'.1f')+'%*'}

# send message to telegram
#
def bot_sendtext(bot_message):
	send_text = 'https://api.telegram.org/bot' + bot_token + '/sendMessage?' + urllib.urlencode({'chat_id': bot_chatID, 'parse_mode': 'Markdown', 'text': unicode(bot_message).encode('utf-8')})
	requests.get(send_text)
    
# load persistance
#
def load():
    try:
        p = pickle.load( open( 'charge_status.p', 'rb' ) )
    except:
        p = { 'charging': False, 'soc': 0.0, 'odo': 0, 'cec': 0.0, 'start_cec': 0.0 }

    return p

# save persistance
#
def save(p):
    pickle.dump( p, open( 'charge_status.p', 'wb' ) )

# delete persistance
#
def delete():
    os.remove('charge_status.p')

# dump persistance
#
def dump():
    return load()

# check if we are driving.  Returns :
#   0 - charging
#   1 - driving
#   -1 - can't read data
def get_driving():
    try:
        args = ['driving']
        kwargs = {
            'mode': '220',
            'pid': '101',
            'header': '7E4',
            'baudrate': 500000,
            'formula': 'bytes_to_int(message.data[53:54])',
            'protocol': '6',
            'verify': False,
            'force': True,
        }
        # note - sums are done outside of the forumla due to autopi failing
        # with 0
        #
        return (int(__salt__['obd.query'](*args, **kwargs)['value'])&4)/4
    except:
        return -1

# get charging power
#
def get_charging_power():
    args = ['charging_power']
    kwargs = {
        'mode': '220',
        'pid': '101',
        'header': '7E4',
        'baudrate': 500000,
        'formula': '(twos_comp(bytes_to_int(message.data[13:14])*256+bytes_to_int(message.data[14:15]),16)/10.0)*((bytes_to_int(message.data[15:16])*256+bytes_to_int(message.data[16:17]))/10.0)/1000.0',
        'protocol': '6',
        'verify': False,
        'force': True,
    }
    return __salt__['obd.query'](*args, **kwargs)['value']*-1.0

# get display state of charge
#
def get_soc():
    args = ['soc']
    kwargs = {
        'mode': '220',
        'pid': '105',
        'header': '7E4',
        'baudrate': 500000,
        'formula': 'bytes_to_int(message.data[34:35])/2.0',
        'protocol': '6',
        'verify': False,
        'force': True,
    }
    return __salt__['obd.query'](*args, **kwargs)['value']

# get odometer
#
def get_odometer():
    args = ['odometer']
    kwargs = {
        'mode': '22',
        'pid': 'B002',
        'header': '7C6',
        'baudrate': 500000,
        'formula': 'bytes_to_int(message.data[11:12])*16777216+bytes_to_int(message.data[12:13])*65536+bytes_to_int(message.data[13:14])*256+bytes_to_int(message.data[14:15])',
        'protocol': '6',
        'verify': False,
        'force': True,
    }
    return __salt__['obd.query'](*args, **kwargs)['value']

# get Accumulative Charge Power
#
def get_cec():
    args = ['odometer']
    kwargs = {
        'mode': '220',
        'pid': '101',
        'header': '7E4',
        'baudrate': 500000,
        'formula': '(bytes_to_int(message.data[41:42])*16777216+bytes_to_int(message.data[42:43])*65536+bytes_to_int(message.data[43:44])*256+bytes_to_int(message.data[44:45]))/10.0',
        'protocol': '6',
        'verify': False,
        'force': True,
    }
    return __salt__['obd.query'](*args, **kwargs)['value']

# enable autopi sleep
#
def enable_sleep():
    args = ['sleep']
    kwargs = {
        'enable': True,
    }
    __salt__['power.sleep_timer'](**kwargs)

# disable autopi sleep
#
def disable_sleep():
    args = ['sleep']
    kwargs = {
        'enable': False,
    }
    __salt__['power.sleep_timer'](**kwargs)

# get location
#
def get_location():
    args = []
    kwargs = {}
    return __salt__['ec2x.gnss_nmea_gga'](*args, **kwargs)

# get nearest charger
#
def nearest_charger():
    location = get_location()

    for charger in chargers:
        lat1 = radians(charger['latitude'])
        lon1 = radians(charger['longitude'])
        lat2 = radians(location['latitude'])
        lon2 = radians(location['longitude'])
        dlon = lon2 - lon1
        dlat = lat2 - lat1
        a = sin(dlat / 2)**2 + cos(lat1) * cos(lat2) * sin(dlon / 2)**2
        c = 2 * atan2(sqrt(a), sqrt(1 - a))
        dist = 6373.0 * c

        if dist < 0.02:
            log.info('found local charger '+charger['msg'])
            return charger['msg']

    log.info('https://api.openchargemap.io/v3/poi/?output=json&distance=0.1&maxresults=1&latitude='+str(location['latitude'])+'&longitude='+str(location['longitude']))
    result = requests.get('https://api.openchargemap.io/v3/poi/?output=json&distance=0.1&maxresults=1&latitude='+str(location['latitude'])+'&longitude='+str(location['longitude']))
    for i in result.json():
        return i['OperatorInfo']['Title']+', '+i['AddressInfo']['Title']+', '+i['UsageCost']

    return 'No local charger found'
