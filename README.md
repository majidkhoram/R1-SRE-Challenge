# R1C-SRE-Challenge
I have been directed to do complete a task and I'm going to write all my thoghts here about it.


### The challenge
- [x] Prepare an infrastructure suitable for a multi-node OpenStack cluster using Arvan Terraform Provider
- [x] Using Ansible make the infra ready for OpenStack deployment
- [x] Install the OpenStack Multi-node using Kolla-Ansible
- [x] Be cautious to use OVN driver in Neutron
- [x] Setup the Monitoring and Alerting services


### My Tasks
- Get to know the role of a Terraform Provider
- Plan the Infrastructure in the file Topoplogy.md on How many VMs will be needed for a multi-node. 
- Come up with the list of actions on the OS to be prepared for OpenStack installation. (From Kolla-Ansible Docs)
- Prepare your Ansible inventory and playbook for the above item
- Prepare machines
- We need another playbook for kolla to perform the multinode installation
- Properly edit the file **globals.yml** to setup OpenStack moldules and OVN network driver
- bootstrap-servers via kolla-ansible
- precheck via kolla-ansible
- deploy OpenStack via kolla-ansible



### To run
 - Terraform to bring up the infra
 - Ansible playbook to do the needed actions on VMs
 - Ansible playbook to prepare the deploying machine (I chose controller-1 as the deploying machine)
 - Run Kolla-Ansible in 3 steps
   - bootstrap-servers
   - prechecks
   - deploy
 - 
