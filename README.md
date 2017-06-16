Welcome to OPNFV CICD Host Machine Preparation
----

Scripts in this folder is to help you automate implementation of CICD Host as described by OPNFV.
Reference: https://wiki.opnfv.org/display/INF/How+to+Setup+CI+to+Run+OPNFV+Deployment+and+Testing

NOTES:
(*) It is assumed that you have prepared your lab with MaaS & Juju installed on Master Node and your servers are enlisted. <br>
(**) This setup to be used with Openstack Deployment implemented under fenar/openbaton-oam under git.<br>
https://github.com/fenar/openbaton-oam

Please execute as described below
----

(1) $ ./01-deploy-cicdhost.sh
    This script will allocate a server from your MaaS and deploy Ubuntu OS and later install all tools required.

(2) Login to your Jenkins Web Portal http://ip:8080 with admin/<passwd*>
    <passwd*> would be printed at the end of script execution.
    Please save this password for later use!
    
(3) On Jenkin Web UI, Select Default Plugins Install Option (Left Box) and click install.

(4) On Jenkins Web UI: <br>
```sh
    Go to Manage Jenkins -> Manage Plugins -> Select Available Tab <br>
    enter Plugin Name (List of Plugins given at the end of Step-1 as output on console) <br>
    on to Filter/Search Tab on right top. <br>
    After finishing selecting all plugins click on install with restart button.
 ```   
(5) $./03-prepare-jumphost.sh [Jump-Host- ie where MaaS runs]
     This script will add necessary components to your Jump-Host.
     
(6) $./04-configure-jumphost-for-jenkins-user.sh [Jump-Host]
     This script will create jenkins user with sshkeys setup on Jump-Host.
     
(7) Manual Step: 
```sh
   Connect Jumphost to Jenkins<br>
            [Open Jenkins Web Interface]
            Click "Credentials" -> "Jenkins in second table" -> "Global Credentials" -> "Add Credentials"
            Fill in the boxes
            Kind: SSH username with private key
            Scope: System (Jenkins and nodes only)
            Username: jenkins
            Private Key: Enter directly and paste the private key of the jenkins user you created on the jumphost<br>
            Description: jenkins on vzw-pod1 jumphost
    Go back to Jenkins main page and click "Build Executor Status"
            [Click "New Node" and fill in the boxes]
            Node Name: vzw-pod1
            # of executors: 2
            Remote root directory: /home/jenkins/slave_root
            Labels: joid-baremetal
            Launch Method: Launch slave agents via ssh
            Host: IP of the jumphost
            Credentials: select the credentials you added as "jenkins on vzw-pod1 jumphost"
            Host Key Verification Strategy: Non verifying Verification Strategy
            Click Save
    The node should now be online with 2 executors<br>
```
(8) Manual Step: 
```sh
    Configure and Test Jenkins Job Builder
            [Login to CI host as jenkins]
            Create directory /etc/jenkins_jobs
            Create file /etc/jenkins_jobs/jenkins_jobs.ini, put below lines in it. Don't forget to update the password in it!
            (Password is 'API Token' fields from: Jenkins Web Interface -> 'admin' -> 'Configure' -> 'Show API Token')
    
                [job_builder]
                ignore_cache=False
                keep_descriptions=False
                include_path=.:scripts:~/git/
                recursive=True

                [jenkins]
                user=admin
                password=PASSWORD-GOES-HERE
                url=http://localhost:8080/
                query_plugins_info=False
                
             Create directory /etc/yardstick
             Create file /etc/yardstick/yardstick.conf, put below lines in it. 

                [DEFAULT]
                debug = True
                dispatcher = influxdb

                [dispatcher_influxdb]
                timeout = 5
                target = http://localhost:8086
                db_name = yardstick
                username = root
                password = root  
```     
(9) $./05-opnfv-jjb-setup-cicd.sh && $./06-opnfv-releng-setup-cicd.sh [CI/CD-Host] <br>
     These scripts will fetch RelEng Job from OPNFV Git Repo and checkout for local jenkins job build. <br>

(10) Please login to CI host and execute below commands. <br>
                cd ~/repos/releng/jjb/joid <br>
                vi joid-daily-jobs.yml <br>
 
                !!!UPDATE THE LINE 142 WHERE THE GIT URL IS SPECIFIED!!!
                !!!url: 'ssh://<IP OF JUMPHOST>/home/jenkins/repos/{project}'!!!
 
                git add -A .
                git commit -m 'add vzw config'
                cd ~/repos/releng/jjb
                jenkins-jobs update joid/joid-daily-jobs.yml:functest/functest-daily-jobs.yml:yardstick/yardstick-daily-jobs.yml:global/installer-params.yml:global/slave-params.yml
     
     
(10) $./07-podconfig-jumphost.sh [Jump-Host] <br>
     This script will setup lab-networking blueprint to be used by OPNFV Jenkins Jobs.
     
(11) $./08-deploy-testresultbackend.sh [CI/CD-Host] <br>
     These scripts will install InfluxdDB & Grafana to be used within CI/CD Setup. <br>
```sh
     Once install completed, following steps shall be followed:
     (a) Configure Jenkins to use InfluxDB @ Jenkins WebUI: Manage Jenkins -> Configure System -> new influxdb target
                # Url: http://localhost:8086/
                # Database: jenkins_data
                # User: admin
                # Password: admin
      (b) Configure Grafana to get data from InfluxDB
```
Date | Author(s):
(A) 07/9/2017 | Fatih E. NAR
