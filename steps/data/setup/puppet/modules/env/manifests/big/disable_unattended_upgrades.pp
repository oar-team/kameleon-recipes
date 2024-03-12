class env::big::disable_unattended_upgrades {

  case "${::lsbdistcodename}" {
    'bookworm': {
        # Disable unattended-upgrades service
        service { 'unattended-upgrades':
            enable => false,
        }
    }
  }
}
