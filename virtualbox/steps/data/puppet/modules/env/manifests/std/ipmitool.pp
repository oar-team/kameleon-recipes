class env::std::ipmitool {

  package { 'ipmitool':
    ensure   => 'installed'
  }

  augeas {
    'module_ipmi_si':
      context => "/files/etc/modules",
      changes => ["ins ipmi_si after #comment[last()]",],
      onlyif  => "match ipmi_si size == 0 ";
    'module_ipmi_devintf':
      context => "/files/etc/modules",
      changes => ["ins ipmi_devintf after #comment[last()]",],
      onlyif  => "match ipmi_devintf size == 0 ";
  }

}
