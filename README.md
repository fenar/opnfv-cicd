Welcome to OPNFV CICD Host Machine Preparation

Scripts in this folder is to help you automate implementation of CICD Host as described by OPNFV.
Reference: https://wiki.opnfv.org/display/INF/How+to+Setup+CI+to+Run+OPNFV+Deployment+and+Testing

NOTES:
(1) It is assumed that you have prepared your lab with MaaS & Juju installed on Master Node and your servers are enlisted.

Please execute as described belo
(1) $ ./01-deploy-cicdhost.sh
    This script will allocate a server from your MaaS and deploy Ubuntu OS and later install all tools required.

(2) Login to your Jenkins Web Portal http://ip:8080 with admin/<passwd*>
    <passwd*> would be printed at the end of script execution.

(3) On Jenkin Web UI, Select Default Plugins Install Option (Left Box) and click install.

(4) $./02-installjenkins-pugins.sh
    This script will install required additional plugins on Jenkins.


Date | Author(s):
(1) 07/9/2017 | Fatih E. NAR
