import time
import logging
import requests
import json
import urllib

log = logging.getLogger(__name__)

# ABRP token ( ie email address )
#
# See https://abetterrouteplanner.com/
#   Show Settings
#   Show More Settings
#   Live Car Connection Setup
#   Next until User Email Address is shown - copy that here 
#
abrt_token = 'your token'

# ABRP API KEY
#
# See contact@iternio.com
#
abrt_apikey = 'your api key'

def telemetry():
    """
    Report telemetry to ABRP 
    """

    data = {}

    location = get_location()

    # Required

    # utc - Current UTC timestamp in seconds
    data['utc'] = time.time()
    log.info ('utc = '+str(data['utc']))

    # soc - State of Charge of the battery in percent (100 = fully charged battery)
    data['soc'] = get_soc()
    log.info ('soc = '+str(data['soc']))

    # speed - Speed of the car in km/h (GPS or OBD)
    # data['speed'] = get_speed()
    data['speed'] = location['sog_km']
    log.info ('speed = '+str(data['speed']))

    # lat - User's current latitude
    data['lat'] = location['lat']
    log.info ('lat = '+str(data['lat']))

    # lon - User's current longitude
    data['lon'] = location['lon']
    log.info ('lon = '+str(data['lon']))

    # is_charging -  1 or 0, 1 = charging, 0 = driving
    data['is_charging'] = get_charging()
    log.info ('is_charging = '+str(data['is_charging']))

    # car_model - String like:chevy:bolt:17:60:other determining what car the user has connected
    data['car_model'] = 'hyundai:kona:17:64:other'

    # optional

    # voltage - Voltage of the battery in Volts
    data['voltage'] = get_voltage()
    log.info ('voltage = '+str(data['voltage']))

    # current - Current output (input is negative) of the battery in Amps
    data['current'] = get_current()
    log.info ('current = '+str(data['current']))

    # power - Power output (input is negative) of the battery in kW
    data['power'] = data['current']*data['voltage']/1000.0
    log.info ('power = '+str(data['power']))

    # soh - State of Health of the battery in percent (100 = fully healthy battery)
    data['soh'] = get_soh()
    log.info ('soh = '+str(data['soh']))

    # elevation - User's current elevation in meters
    data['elevation'] = location['alt']
    log.info ('elevation = '+str(data['elevation']))

    # ext_temp - External temperature in Celsius
    data['ext_temp'] = get_externaltemp()
    log.info ('ext_temp = '+str(data['ext_temp']))

    # batt_temp - Battery temperature in Celsius
    data['batt_temp'] = get_batterytemp()
    log.info ('batt_temp = '+str(data['batt_temp']))

    params = {'token': abrt_token, 'api_key': abrt_apikey, 'tlm': json.dumps(data, separators=(',',':'))}

    log.info ('https://api.iternio.com/1/tlm/send?'+urllib.urlencode(params))  

    return {"msg": requests.get('https://api.iternio.com/1/tlm/send?'+urllib.urlencode(params))}

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

# get speed ( needs validation )
#
def get_speed():
    try:
        args = ['speed']
        kwargs = {
            'mode': '220',
            'pid': '100',
            'header': '7B3',
            'baudrate': 500000,
            'formula': 'bytes_to_int(message.data[32:33])',
            'protocol': '6',
            'verify': False,
            'force': True,
        }
        return __salt__['obd.query'](*args, **kwargs)['value']
    except:
        return 0

# is charging
#
def get_charging():
    try:
        args = ['charging']
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
        return 1-(int(__salt__['obd.query'](*args, **kwargs)['value'])&4)/4
    except:
        return 0

# get voltage
#
def get_voltage():
    args = ['voltage']
    kwargs = {
        'mode': '220',
        'pid': '101',
        'header': '7E4',
        'baudrate': 500000,
        'formula': '(bytes_to_int(message.data[15:16])*256+bytes_to_int(message.data[16:17]))/10.0',
        'protocol': '6',
        'verify': False,
        'force': True,
    }
    return __salt__['obd.query'](*args, **kwargs)['value']

# get current
#
def get_current():
    args = ['current']
    kwargs = {
        'mode': '220',
        'pid': '101',
        'header': '7E4',
        'baudrate': 500000,
        'formula': 'twos_comp(bytes_to_int(message.data[13:14])*256+bytes_to_int(message.data[14:15]),16)/10.0',
        'protocol': '6',
        'verify': False,
        'force': True,
    }
    return __salt__['obd.query'](*args, **kwargs)['value']

# get soh
#
def get_soh():
    args = ['soh']
    kwargs = {
        'mode': '220',
        'pid': '105',
        'header': '7E4',
        'baudrate': 500000,
        'formula': '(bytes_to_int(message.data[28:29])*256+bytes_to_int(message.data[29:30]))/10.0',
        'protocol': '6',
        'verify': False,
        'force': True,
    }
    return __salt__['obd.query'](*args, **kwargs)['value']

# get external temp
#
def get_externaltemp():
    args = ['externaltemp']
    kwargs = {
        'mode': '220',
        'pid': '100',
        'header': '7B3',
        'baudrate': 500000,
        'formula': '(bytes_to_int(message.data[9:10])/2.0)-40.0',
        'protocol': '6',
        'verify': False,
        'force': True,
    }
    return __salt__['obd.query'](*args, **kwargs)['value']

# get battery temp
#
def get_batterytemp():
    args = ['batterytemp']
    kwargs = {
        'mode': '220',
        'pid': '101',
        'header': '7E4',
        'baudrate': 500000,
        'formula': 'twos_comp(bytes_to_int(message.data[19:20]),8)',
        'protocol': '6',
        'verify': False,
        'force': True,
    }
    return __salt__['obd.query'](*args, **kwargs)['value']

# get location
#
def get_location():
    args = []
    kwargs = {}
    return __salt__['ec2x.gnss_location'](*args, **kwargs)
