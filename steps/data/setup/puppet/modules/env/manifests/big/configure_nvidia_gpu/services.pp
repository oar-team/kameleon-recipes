class env::big::configure_nvidia_gpu::services () {

  # We only install the service but do not enable it.
  # Services that depend on it can add "Wants=nvidia-smi.service"
  # and "After=nvidia-smi.service", and this will automatically start
  # this service.
  file{
    '/etc/systemd/system/nvidia-smi.service':
      ensure    => file,
      owner     => root,
      group     => root,
      mode      => '0644',
      source    => 'puppet:///modules/env/big/nvidia/nvidia-smi.service';
  }
}
