# deploy-kubernetes

An ansible playbook to deploy kubernetes based on https://github.com/kelseyhightower/kubernetes-the-hard-way/.


### Usage
Create an inventory file with similar to the following:

```
[master]
192.168.122.11

[minion]
192.168.122.11
192.168.122.12

[etcd]
192.168.122.11
```

Deploy with the following command:
```ansible-playbook -i inventory deploy-kubernetes.yml```

### Prerequisites
This has been tested on Ubuntu 16.04 with Ansible v2.0. It is also assumed that you have ssh access enabled for root on the target hosts. There is an issue with Ubuntu 16.04 in that it doesn't ship with Python 2.7 which is needed for Ansible, so Python 2.7 must also be pre-installed on the target hosts.
