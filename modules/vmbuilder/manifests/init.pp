class vmbuilder(
    $db_user              = "liferay",
    $db_password          = "D3P4ssw0rd",
    $db_name              = "lportal",
    $timzone              = "Europe/Dublin",
    $liferay_user         = "liferay",
    $liferay_group        = "www",
    $install_path         = "/opt",
    $liferay_db           = "mysql",
    $liferay_zip_filename = "liferay-portal-tomcat-6.2-ce-ga6-20160112152609836.zip",
    $liferay_folder       = "liferay-portal-6.2-ce-ga6",
    $tomcat_folder        = "tomcat-7.0.62",
    $liferay_version      = "6.2.5%20GA6",
    $liferay_cluster      = false,
    $xmx                  = "2048",
    $permsize             = "512",
    $use_firewall         = false,
    $httpserver           = "",
    $java_distribution    = "oracle",
    $solr_distribution    = "",
    $mail_server          = "",
    $apm                  = "",
    $liferay_dev          = false,
  ) {

  $liferay_install_path = "${install_path}/liferay"
  
  #Setup and updating APT
  include aptsetup

  #Ensure that we have unzip and wget to use across all the modules
  #Limitation to puppet3
  package {"unzip":
    name   => "unzip",
    ensure => present,
  }

  package {"zip":
    name   => "zip",
    ensure => present,
  }

  package {"wget":
    name   => "wget",
    ensure => present,
  }

  #Unix configurations
  include hosts

  class { 'groups' :
    liferay_group => $liferay_group,
  }

  class { 'users' :
    liferay_user      => $liferay_user,
    liferay_group     => $liferay_group,
    liferay_user_home => $liferay_install_path,
  }

  #Configuring ntp module
  include '::ntp'

  #Setting the proper timezone
  class { 'timezone':
      timezone => $timzone,
  }

  #Setup Java distribution
  class {'javad' :
    distribution => $java_distribution,
  }

  #Setup BD (default mysql)
  class { 'db':
    db_user     => $db_user,
    db_password => $db_password,
    db_name     => $db_name,
    liferay_db  => $liferay_db,
  }

  #Install SOLR
  if ($solr_distribution) {
    $solr_http_port = "8180"

    class { 'solr':
      distribution  => $solr_distribution,
      liferay_user  => $liferay_user,
      liferay_group => $liferay_group,
      http_port     => $solr_http_port,
    }
  }

  #Install the mail server
  if ($mail_server) {
    $mail_server_port = "1025"
    $mail_http_port   = "1080"

    class { 'email':
      mail_server      => $mail_server,
      mail_server_port => $mail_server_port,
      mail_http_port   => $mail_http_port,
    }
  }

  #Install the APM tool
  class {'apm' :
    apm                  => $apm,
    install_path         => $install_path,
    liferay_cluster      => $liferay_cluster,
    java_distribution   => $java_distribution,
    require              => [
      Class['javad'], 
      Class['users'],
    ],
  }

  #Setup Liferay
  class { 'liferay' :
    db_user              => $db_user,
    db_password          => $db_password,
    db_name              => $db_name,
    install_path         => $liferay_install_path, 
    liferay_user         => $liferay_user,
    liferay_group        => $liferay_group,
    liferay_cluster      => $liferay_cluster,
    liferay_zip_filename => $liferay_zip_filename,
    liferay_folder       => $liferay_folder,
    tomcat_folder        => $tomcat_folder,
    version              => $liferay_version,
    xmx                  => $xmx,
    permsize             => $permsize,
    liferay_db           => $liferay_db,
    solr_http_port       => $solr_http_port,
    solr_distribution    => $solr_distribution,
    mail_server_port     => $mail_server_port,
    apm                  => $apm,
    liferay_dev          => $liferay_dev,
    require              => [
      Class['javad'], 
      Class['users'],
      Class['db'],
      Class['apm'],
    ],
  } 

  #Setup httpserver (default apache2)
  class {'httpserver' :
    httpserver => $httpserver,
    cluster    => $liferay_cluster,
    require    => [
      Class['liferay'],
    ],
  }

  #Setup firewall
  if ($use_firewall) {
    class {'iptables' :
      cluster     => $liferay_cluster,
      solr        => $solr_distribution,
      mail_server => $mail_server,
      apm         => $apm,
    }
  }




}