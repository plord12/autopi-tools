import logging
from timeit import default_timer as timer

log = logging.getLogger(__name__)

def known():
    """
    OBD scan of known pids
    """

    log.info ("SALT: "+str(__salt__))
    
    """
    args = ['7E4#220101']
    kwargs = {
        'auto_format': True,
        'expect_response': True,
        'raw_response': True,
        'baudrate': 500000,
        'protocol': '6'
    }
    res = __salt__['obd.send'](*args, **kwargs)
    values = res['values']
    log.info ("TEST: auto_format: True raw_response: True "+str(values))
    line = values[0]
    log.info ("TEST: auto_format: True raw_response: True "+str(line))
    char = line[0:1]
    log.info ("TEST: auto_format: True raw_response: True "+str(char))   
    int = bytes_to_int(line[0:1])
    log.info ("TEST: auto_format: True raw_response: True "+str(int))   
    """
    
    # 7A0 / 7A8 - BCM / TPMS
    for mode in ['22']:
        for pid in ['B00C','B00E','C002','C00B']:
            args = ['scan '+mode+pid]
            kwargs = {
                'mode': mode,
                'pid': pid,
                'header': '7A0',
                'baudrate': 500000,
                'protocol': '6',
                'verify': False,
                'force': True,
            }
            log.info ("SCAN: "+mode+" "+pid+" "+str(__salt__['obd.query'](*args, **kwargs)))

    # 7E4/7EC = BMC
    for mode in ['220']:
        for pid in ['101','102','103','104','105','106']:
            args = ['scan '+mode+pid]
            kwargs = {
                'mode': mode,
                'pid': pid,
                'header': '7E4',
                'baudrate': 500000,
                'protocol': '6',
                'verify': False,
                'force': True,
            }
            log.info ("SCAN: "+mode+" "+pid+" "+str(__salt__['obd.query'](*args, **kwargs)))

    # 7E3 / 7EB = MCU
    for mode in ['21']:
        for pid in ['01','02','03','04','05','06','12']:
            args = ['scan '+mode+pid]
            kwargs = {
                'mode': mode,
                'pid': pid,
                'header': '7E3',
                'baudrate': 500000,
                'protocol': '6',
                'verify': False,
                'force': True,
            }
            log.info ("SCAN: "+mode+" "+pid+" "+str(__salt__['obd.query'](*args, **kwargs)))

    # 7E5/7ED = OBC
    for mode in ['21']:
        for pid in ['01','03']:
            args = ['scan '+mode+pid]
            kwargs = {
                'mode': mode,
                'pid': pid,
                'header': '7E5',
                'baudrate': 500000,
                'protocol': '6',
                'verify': False,
                'force': True,
            }
            log.info ("SCAN: "+mode+" "+pid+" "+str(__salt__['obd.query'](*args, **kwargs)))

    # 7E2/7EA = VMCU
    for mode in ['21']:
        for pid in ['01','02']:
            args = ['scan '+mode+pid]
            kwargs = {
                'mode': mode,
                'pid': pid,
                'header': '7E2',
                'baudrate': 500000,
                'protocol': '6',
                'verify': False,
                'force': True,
            }
            log.info ("SCAN: "+mode+" "+pid+" "+str(__salt__['obd.query'](*args, **kwargs)))

    # 7C6/7CE Cluster odometer
    for mode in ['22']:
        for pid in ['B002']:
            args = ['scan '+mode+pid]
            kwargs = {
                'mode': mode,
                'pid': pid,
                'header': '7C6',
                'baudrate': 500000,
                'protocol': '6',
                'verify': False,
                'force': True,
            }
            log.info ("SCAN: "+mode+" "+pid+" "+str(__salt__['obd.query'](*args, **kwargs)))

    # 770/778 IGMP
    for mode in ['22']:
        for pid in ['BC03','BC04','BC07']:
            args = ['scan '+mode+pid]
            kwargs = {
                'mode': mode,
                'pid': pid,
                'header': '770',
                'baudrate': 500000,
                'protocol': '6',
                'verify': False,
                'force': True,
            }
            log.info ("SCAN: "+mode+" "+pid+" "+str(__salt__['obd.query'](*args, **kwargs)))

    # 7B3/7BB AirCon
    for mode in ['220']:
        for pid in ['100','102']:
            args = ['scan '+mode+pid]
            kwargs = {
                'mode': mode,
                'pid': pid,
                'header': '7B3',
                'baudrate': 500000,
                'protocol': '6',
                'verify': False,
                'force': True,
            }
            log.info ("SCAN: "+mode+" "+pid+" "+str(__salt__['obd.query'](*args, **kwargs)))

    # 7D1/7D9 ABS ESP
    for mode in ['22']:
        for pid in ['C101']:
            args = ['scan '+mode+pid]
            kwargs = {
                'mode': mode,
                'pid': pid,
                'header': '7D1',
                'baudrate': 500000,
                'protocol': '6',
                'verify': False,
                'force': True,
            }
            log.info ("SCAN: "+mode+" "+pid+" "+str(__salt__['obd.query'](*args, **kwargs)))


    # 7E6/7EE ??
    for mode in ['21']:
        for pid in ['0805','0806','0807','0808','0809','080a','080b','080c','080d','080e','080f']:
            args = ['scan '+mode+pid]
            kwargs = {
                'mode': mode,
                'pid': pid,
                'header': '7E6',
                'baudrate': 500000,
                'protocol': '6',
                'verify': False,
                'force': True,
            }
            log.info ("SCAN: "+mode+" "+pid+" "+str(__salt__['obd.query'](*args, **kwargs)))

    return {"msg": "Scan finished"}

def test():
    """
    OBD scan

    torque scan does :
        24 plus [ 0 to 1F in hex ] plus FFFF
        21 plus [ 0 to 110 in hex ] basic scan
        21 plus [ 0 to 255 in hex ] full scan
        22 plus [ 0 to 255 in hex ] plus [ 0 to 15 in hex ] plus 01 basic scan
        22 plus [ 0 to 255 in hex ] plus [ 0 to 255 in hex ] plus 01 full scan
    """

    """
    for mode in [ '24']:
        count = 0
        while count < 32:
            pid = "{:02X}FFFF".format(count)
            count += 1
            args = ['scan '+mode+pid]
            kwargs = {
                'mode': mode,
                'pid': pid,
                'baudrate': 500000,
                'protocol': '6',
                'verify': False,
                'force': True,
            }

            log.info ("SCAN: "+mode+" "+pid+" "+str(__salt__['obd.query'](*args, **kwargs)))
    """

    for mode in [ '220', '221']:
        count = 0
        while count <= 4095:
            pid = "{:02X}".format(count)
            count += 1
            args = ['scan '+mode+pid]
            kwargs = {
                'mode': mode,
                'pid': pid,
                'baudrate': 500000,
                'protocol': '6',
                'verify': False,
                'force': True,
            }

            log.info ("SCAN: "+mode+" "+pid+" "+str(__salt__['obd.query'](*args, **kwargs)))

    """
    for mode in [ '21', '22']:
        a = 0
        while a <= 255:
            b = 0
            while b <= 15:
                pid = "{:02X}".format(a)+"{:02X}".format(b)
                b += 1
                args = ['scan '+mode+pid]
                kwargs = {
                    'mode': mode,
                    'pid': pid,
                    'baudrate': 500000,
                    'protocol': '6',
                    'verify': False,
                    'force': True,
                }

                log.info ("SCAN: "+mode+" "+pid+" "+str(__salt__['obd.query'](*args, **kwargs)))
            a += 1
    """

    return {"msg": "Scan finished"}

def send():
    """
    OBD scan via obd.send
    """

    args = ['7E4#220101']
    kwargs = {
        'auto_format': True,
        'raw_response': True,
        'expect_response': True,
        'baudrate': 500000,
        'protocol': '6'
    }

    start = timer()
    res = __salt__['obd.send'](*args, **kwargs)
    end = timer()
    log.info ("TIME: "+str(end-start))
    
    #values = res['values'][0][0:1]
    log.info ("SEND: "+str(res))
    #log.info ("SEND: "+str(values))
    
    return {"msg": str(res)}
