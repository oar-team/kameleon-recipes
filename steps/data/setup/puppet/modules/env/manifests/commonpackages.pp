class env::commonpackages{
  
}

class env::commonpackages::rubyrspec{
  package{ 'ruby-rspec':
    ensure => installed;
  }
}

class env::commonpackages::rake{
  package{ 'rake':
    ensure => installed;
  }
}

class env::commonpackages::rsyslog{
  package{ 'rsyslog':
    ensure => installed;
  }
}
