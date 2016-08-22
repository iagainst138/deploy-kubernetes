#!/usr/bin/env python

import subprocess

from ansible.module_utils.basic import *

def route_exists(network):
    cmd = 'ip route list | grep {}'.format(network)
    return os.system(cmd) == 0


def main():
    module = AnsibleModule(
        argument_spec = dict(
            routes = dict(required=True),
        )
    )

    changed = False
    failed = False
    error_msg = ''

    cmd = "ip a | grep -Po 'inet .*? ' | awk '{print $2}' | cut -d/ -f 1"
    p = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE)
    o,_ = p.communicate()
    ips = [ i for i in o.split() if i != '' ]

    routes = module.params.get('routes')
    for network, gateway in routes:
        #if os.system('ip route show | egrep "{} via {}"'.format(network, gateway)) != 0:
        if not route_exists(network) and gateway not in ips:
            cmd = 'ip route add {} via {}'.format(network, gateway)
            p = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
            o,_ = p.communicate()
            r = p.returncode
            if r != 0:
                failed = True
                error_msg = o
            else:
                changed = True

    if failed:
        module.fail_json(
            msg=error_msg
        )
    else:
        module.exit_json(
            changed=changed,
        )

if __name__ == '__main__':
    main()
