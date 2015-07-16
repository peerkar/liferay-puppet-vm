class liferay::cluster(
  $liferay_folder, 
  $tomcat_folder, 
  $liferay_zip_filename,
  $module_files_location,
  $liferay_vagrant_dir,
  $db_user,
  $db_password,
  $db_name,
  $xmx,
  $permsize,
  $install_path,
  $liferay_user,
  $liferay_group,
  $liferay_db,
  $solr_distribution,
  ) {

  #Node configurations
  $node1_name     = "node1"
  $node1_ajp_port = "8009"
  $node2_name     = "node2"
  $node2_ajp_port = "8010"

  $ajp_nodes      = ["BalancerMember ajp://localhost:${node1_ajp_port} route=${node1_name}" , "BalancerMember ajp://localhost:${node2_ajp_port} route=${node2_name}"]

  #Ensure that we have the root install path directory
  file {"${install_path}":
    ensure => "directory",
    owner  => $liferay_user,
    group  => $liferay_group,
    mode   => 775,
  }

  file {"${liferay_vagrant_dir}":
    ensure => "directory",
    owner  => $liferay_user,
    group  => $liferay_group,
    mode   => 775,
  }

  exec {"clean-liferay-vagrant-dir":
    command => "rm -fR ${liferay_vagrant_dir}/*",
    path    => ["/usr/bin", "/bin"],
    require => File["${liferay_vagrant_dir}"]
  }

  # Create node 1
  liferay::single { $node1_name :
    db_user               => $db_user,
    db_password           => $db_password,
    db_name               => $db_name,
    install_path          => "${install_path}/${node1_name}", 
    liferay_user          => $liferay_user,
    liferay_group         => $liferay_group,
    liferay_folder        => $liferay_folder, 
    tomcat_folder         => $tomcat_folder, 
    liferay_zip_filename  => $liferay_zip_filename,
    module_files_location => $module_files_location,
    liferay_vagrant_dir   => "${liferay_vagrant_dir}/${node1_name}",
    xmx                   => $xmx,
    permsize              => $permsize,
    cluster_conf          => true,
    data_dl_path          => "${install_path}/data/document_library",
    http_port             => "8080",
    shutdown_port         => "8005",
    redirect_port         => "8443",
    ajp_port              => "${node1_ajp_port}",
    liferay_db            => $liferay_db,
    solr_distribution     => $solr_distribution,
    require               => [
      File["${install_path}"],
      Exec["clean-liferay-vagrant-dir"],
    ],
  }

  # Create node 2
  liferay::single { $node2_name :
    db_user               => $db_user,
    db_password           => $db_password,
    db_name               => $db_name,
    install_path          => "${install_path}/${node2_name}", 
    liferay_user          => $liferay_user,
    liferay_group         => $liferay_group,
    liferay_folder        => $liferay_folder, 
    tomcat_folder         => $tomcat_folder, 
    liferay_zip_filename  => $liferay_zip_filename,
    module_files_location => $module_files_location,
    liferay_vagrant_dir   => "${liferay_vagrant_dir}/${node2_name}",
    xmx                   => $xmx,
    permsize              => $permsize,
    cluster_conf          => true,
    data_dl_path          => "${install_path}/data/document_library",
    http_port             => "8081",
    shutdown_port         => "8006",
    redirect_port         => "8444",
    ajp_port              => "${node2_ajp_port}",
    liferay_db            => $liferay_db,
    solr_distribution     => $solr_distribution,
    require               => [
      File["${install_path}"],
      Exec["clean-liferay-vagrant-dir"],
    ],
  }

    
}