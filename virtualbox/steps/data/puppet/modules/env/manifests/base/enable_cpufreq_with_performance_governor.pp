class env::base::enable_cpufreq_with_performance_governor (){

  package {
    'cpufrequtils':
      ensure   => installed;
  }

  file {
    '/etc/default/cpufrequtils':
      ensure   => file,
      owner    => root,
      group    => root,
      mode     => '0644',
      source   => 'puppet:///modules/env/base/cpufreq/cpufrequtils'
  }
}
