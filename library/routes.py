#!/usr/bin/env python

from ansible.module_utils.basic import *

def main():
    module = AnsibleModule(
        argument_spec = dict(
        )
    )
    cmd = './packages/kubectl get nodes --output=json'

    p = subprocess.Popen(cmd, stdout=subprocess.PIPE, shell=True)
    o,e = p.communicate()

    j = json.loads(o)

    routes = []
    for i in j['items']:
        for a in i['status']['addresses']:
            if a['type'] == 'InternalIP':
                routes.append((i['spec']['podCIDR'], a['address']))

    if len(routes) > 0:
        module.exit_json(
            changed=True,
            routes=routes,
        )
    else:
        module.fail_json(msg='no routes found')

if __name__ == '__main__':
    main()
