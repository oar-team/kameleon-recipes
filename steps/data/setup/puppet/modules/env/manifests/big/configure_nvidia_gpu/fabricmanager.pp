class env::big::configure_nvidia_gpu::fabricmanager () {

### This class exists for GPU clusters equipped with nvswitch technology
### that require the fabricmanager driver.

  include env::big::prepare_kernel_module_build

  $fabric_source = 'https://developer.download.nvidia.com/compute/cuda/redist/fabricmanager/linux-x86_64/fabricmanager-linux-x86_64-460.91.03.tar.gz'
  $fabric_tar_file = '/tmp/fabricmanager-linux-x86_64-460.91.03.tar.gz'
  $fabric_folder = '/tmp/fabricmanager'

  $installation_folder = '/usr/bin'

exec{
  'retrieve_fabricmanager':
    command   => "/usr/bin/wget $fabric_source -O $fabric_tar_file",
    timeout   => 300, # 5 min
    creates   => "$fabric_tar_file";
  'extract_fabricmanager':
    command => "/usr/bin/tar -xzf $fabric_tar_file -C /tmp/",
    timeout => 120, # 2 min
    creates => "$fabric_folder";
  'rewrite_paths':
    command => "/usr/bin/sed -i \'s/\${PWD}/\\/tmp\\/fabricmanager/g\' $fabric_folder/fm_run_package_installer.sh",
    timeout => 60; # 1 min
  'install_fabricmanager':
    command     => "$fabric_folder/fm_run_package_installer.sh",
    timeout     => 300, # 5 min
    user        => root,
    environment => ["HOME=/root", "USER=root"];
  }

file {
  '/etc/systemd/system/nvidia-fabricmanager.service':
    ensure    => file,
    owner     => root,
    group     => root,
    mode      => '0644',
    source    => 'puppet:///modules/env/big/nvidia/nvidia-fabricmanager.service';
  '/etc/systemd/system/multi-user.target.wants/nvidia-fabricmanager.service':
    ensure => absent;
  }
}
