# Liferay VM Setup #

Project for ramp up a VM running Liferay from scratch using [Puppet](https://puppetlabs.com/) and [Vagrant](https://www.vagrantup.com/).

Disclaimer: This setup is not prepared/tuned for production environments and its usage for that propose is not recommended. 

### Usage ###

#### Prerequisites ####

* [Vagrant](http://docs.vagrantup.com/v2/getting-started/index.html) 
* [VirtualBox](https://www.virtualbox.org/)
* [Ubuntu trusty64 - Vagrant box](https://atlas.hashicorp.com/ubuntu/boxes/trusty64)

#### Default usage (Liferay 6.2 CE GA6) ####

1. Open file "/manifests/default.pp"
2. Adjust the initial parameters for your case (top of the file)
3. Go to the terminal and execute "vagrant up" on the project root directory

#### Cluster configuration (Liferay 6.2 CE GA6 / 2 nodes) ####

1. Open file "/manifests/default.pp"
2. Uncomment cluster related configurations
3. Adjust the initial parameters for your case (top of the file)
4. Go to the terminal and execute "vagrant up" on the project root directory

```
The second node must be manually started after the process is complete.
Example: sudo service tomcat8081 start


```

#### Other Liferay distribution (Tomcat bundle) ####

1. Open file "/manifests/default.pp"
2. Copy the Liferay distribution archive to "/modules/liferay/files" 
3. Adjust the initial parameters for your case (top of the file)
4. Uncomment Liferay archive specific parameters and ensure that they are aligned with your case
5. Go to the terminal and execute "vagrant up" on the project root directory

### VM Configuration ###

#### Hardware ####

* OS: [Ubuntu](https://atlas.hashicorp.com/ubuntu/boxes/trusty64) - Official Ubuntu Server 14.04 LTS (Trusty Tahr) builds
* CPU: 2
* RAM: 4096 (can be set to 3072 for single instance usage)
* Changes can be done adjusting vb.memory and vb.cpus parameters in Vagrantfile

#### Groups #####

* www

#### Users #####

* liferay (www)

#### NTP & Timezone #####

* [NTP Module](https://forge.puppetlabs.com/puppetlabs/ntp)
* [Timezone Module](https://forge.puppetlabs.com/saz/timezone) (default to "Europe/Dublin")

#### Java (OracleJDK or OpenJDK) #####

* Version: Oracle 1.7 (default) or OpenJDK 7
* [Java Module](https://forge.puppetlabs.com/puppetlabs/java)
* Remote jmx configured on ports 9090 and 9091 with credential controlRole:liferay

#### Database (MySQL or PostgreSQL) #####

* [MySQL Module](https://forge.puppetlabs.com/puppetlabs/mysql) (Default)
* [PostgreSQL Module](https://forge.puppetlabs.com/puppetlabs/postgresql)
* liferay user
* lportal database
* Accessed only through localhost interface

#### Liferay #####

* Default usage will download Liferay 6.2 CE GA6 - bundled with Tomcat (7.0.62)
* Configured to access lportal database
* Configured to use <VAGRANT_SHARED_FOLDER>/liferay/deploy for deployments
* <VAGRANT_SHARED_FOLDER>/liferay/portal-ext.properties available for configurations 
* Configures tomcat as an unix service
* Use default port 8080 for http
* Development mode (optional) 
	* Will import portal-developer.properties file

#### Liferay (Cluster) #####

* Default usage will download Liferay 6.2 CE GA6 - bundled with Tomcat (7.0.62)
* Configured to access lportal database for both nodes
* Configured to use <VAGRANT_SHARED_FOLDER>/liferay/nodeX/deploy for deployments
* <VAGRANT_SHARED_FOLDER>/liferay/nodeX/portal-ext.properties available for configurations 
* Configures tomcat and tomcat8081 as unix service
* Set /opt/liferay/data/document_library as document library for both nodes, using Liferay AdvancedFileSystemStore
* Http ports configured are 8080 for node1 and 8081 for node2
* Uses the default Liferay cluster configuration (Multicast and RMI)

#### HTTP Server (Optional) ####

* By default, none is used
* Apache2
	* Configured with http proxy from port 80 to 8080
	* Uses mod-jk
	* Not configured to serve static content
* Apache2 (Cluster)
	* Configured with http proxy from port 80 to 8080/8081
	* Sticky sessions
	* Load balancing configured with "by request" approach
	* Uses proxy, proxy_ajp, proxy_balancer, lbmethod_byrequest and slotmem_shm modules
	* Not configured to serve static content
* NginX
	* Configured with http proxy from port 80 to 8080
	* Using HTTP instead of AJP
	* Not configured to serve static content
* NginX (Cluster)
	* Configured with http proxy from port 80 to 8080/8081
	* Not configured to serve static content
	* Using ip_hash (don't rely on AJP to attach the sticky session via jvmRoute)

#### SOLR (Optional) #####

* Supported versions: 3.5.0
* Uses [Tomcat Module](https://forge.puppetlabs.com/puppetlabs/tomcat)
* [Solr admin](http://localhost:18180/solr/admin)

#### Email Server (Optional) #####

* Configures Liferay to use [Mailcatcher](http://mailcatcher.me/) as dummy email server
* [Web interface](http://localhost:11080) available to see all sent emails

#### APM tool (Optional) #####

* By default, none is used
* [DynaTrace](http://www.dynatrace.com/en/index.html)
	* For the sake of simplicity and resource consumption, it is configured to run only with single node and Oracle JDK
	* The current configuration is installing DynaTrace Server and Collector on the same VM, as so, VM resources need to be increased (tested with 6GB RAM and 4 CPUs)
	* Requires ulimit to be increased to 2048 (uses [ulimit module](https://forge.puppetlabs.com/arioch/ulimit/readme))
	* Used UNIX services: dynaTraceServer and dynaTraceCollector
	* [DynaTrace Web client](https://localhost:19911/) (user and password = admin)

#### IPTables (VM Local ports) #####

* Optional - Disabled by default
* [Firewall Module](https://forge.puppetlabs.com/puppetlabs/firewall)
* 22 ssh
* 80, 443 http server
* 8080, 8000 tomcat
* 9090, 9091 jmx
* 8081 tomcat2 (Cluster only)
* 23301-23351 Multicast (Cluster only)
* 8180 solr (Optional)
* 1080 Mailcatcher web interface (Optional)
* 8021, 2021, 9911 DynaTrace (Optional)

#### VM Exposed Ports #####

* host: 1080, guest: 80    (Http server)
* host: 18080, guest: 8080 (Tomcat - Liferay node 1)
* host: 18081, guest: 8081 (Tomcat - Liferay node 2)
* host: 18000, guest: 8000 (Tomcat debug - Liferay node 1)
* host: 19090, guest: 9090 (jmx)
* host: 19091, guest: 9091 (jmx)
* host: 18180, guest: 8180 (SOLR)
* host: 11080, guest: 1080 (Mailcatcher)
* host: 12021, guest: 2021 (Dynatrace client)
* host: 18021, guest: 8021 (Dynatrace web client)
* host: 19911, guest: 9911 (Dynatrace web client)

### Contribution guidelines ###

Feedback, contributions and improvements are welcome. Feel free to contact me.

### Special Thanks ###

Special thanks to Thiago Moreira for his valuable input to this project at earlier stage.