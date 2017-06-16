Welcome to OPNFV CICD Host Machine Preparation
----

Scripts in this folder is to help you automate implementation of CICD Host as described by OPNFV.
Reference: https://wiki.opnfv.org/display/INF/How+to+Setup+CI+to+Run+OPNFV+Deployment+and+Testing

NOTES:
(*) It is assumed that you have prepared your lab with MaaS & Juju installed on Master Node and your servers are enlisted.

Please execute as described below
----

(1) $ ./01-deploy-cicdhost.sh
    This script will allocate a server from your MaaS and deploy Ubuntu OS and later install all tools required.

(2) Login to your Jenkins Web Portal http://ip:8080 with admin/<passwd*>
    <passwd*> would be printed at the end of script execution.
    Please save this password for later use!
    
(3) On Jenkin Web UI, Select Default Plugins Install Option (Left Box) and click install.

(4) On Jenkins Web UI: Go to Manage Jenkins -> Manage Plugins -> Select Available Tab and enter Plugin Name (List of Plugins given at the end of Step-1 as output on console) on to Filter/Search Tab on right top, after finishing selecting all plugins click on install with restart button.
    
(5) $./03-prepare-jumphost.sh [Jump-Host- ie where MaaS runs]
     This script will add necessary components to your Jump-Host.
     
(6) $./04-configure-jumphost-for-jenkins-user.sh [Jump-Host]
     This script will create jenkins user with sshkeys setup on Jump-Host.
     
(7) Manual Step: Connect Jumphost to Jenkins<br>
```sh
            [Open Jenkins Web Interface]<br>
            Click "Credentials" -> "Jenkins in second table" -> "Global Credentials" -> "Add Credentials"<br>
            Fill in the boxes<br>
            Kind: SSH username with private key<br>
            Scope: System (Jenkins and nodes only)<br>
            Username: jenkins<br>
            Private Key: Enter directly and paste the private key of the jenkins user you created on the jumphost<br>
            Description: jenkins on vzw-pod1 jumphost<br>
    Go back to Jenkins main page and click "Build Executor Status"<br>
            [Click "New Node" and fill in the boxes]<br>
            Node Name: vzw-pod1<br>
            # of executors: 2<br>
            Remote root directory: /home/jenkins/slave_root<br>
            Labels: joid-baremetal<br>
            Launch Method: Launch slave agents via ssh<br>
            Host: IP of the jumphost<br>
            Credentials: select the credentials you added as "jenkins on vzw-pod1 jumphost"<br>
            Host Key Verification Strategy: Non verifying Verification Strategy<br>
            <Click Save<br>
    The node should now be online with 2 executors<br>
```
(8) Manual Step: Configure and Test Jenkins Job Builder<br>
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
     
(9) $./05-opnfv-jjb-setup-cicd.sh && $./06-opnfv-releng-setup-cicd.sh [CI/CD-Host]
     These scripts will fetch RelEng Job from OPNFV Git Repo and checkout for local jenkins job build.

(10) Please login to CI host and execute below commands. <br>
                cd ~/repos/releng/jjb/joid <br>
                vi joid-daily-jobs.yml <br>
 
                !!!UPDATE THE LINE 142 WHERE THE GIT URL IS SPECIFIED!!!
                !!!url: 'ssh://<IP OF JUMPHOST>/home/jenkins/repos/{project}'!!!
 
                git add -A .
                git commit -m 'add vzw config'
                cd ~/repos/releng/jjb
                jenkins-jobs update joid/joid-daily-jobs.yml:functest/functest-daily-jobs.yml:yardstick/yardstick-daily-jobs.yml:global/installer-params.yml:global/slave-params.yml
     
     
(10) $./07-podconfig-jumphost.sh [Jump-Host]
     This script will setup lab-networking blueprint to be used by OPNFV Jenkins Jobs.
     
(11) $./08-deploy-testresultbackend.sh [CI/CD-Host]
     These scripts will install InfluxdDB & Grafana to be used within CI/CD Setup.
     Once install completed, following steps shall be followed:<br>
     (a) Configure Jenkins to use InfluxDB @ Jenkins WebUI: Manage Jenkins -> Configure System -> new influxdb target<br>
                # Url: http://localhost:8086/<br>
                # Database: jenkins_data<br>
                # User: admin<br>
                # Password: admin<br>
      (b) Configure Grafana to get data from InfluxDB<br>

Date | Author(s):
(A) 07/9/2017 | Fatih E. NAR
