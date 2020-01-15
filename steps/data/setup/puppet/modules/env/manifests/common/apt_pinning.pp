# Define apt_pinning
# Parameters:
# Packages to pin
# Pinned version
# Priority

define env::common::apt_pinning (
  $packages = undef,
  $version = undef,
  $priority = 1001,
) {

  if $packages == undef or $version == undef {
    fail 'Missing required parameter'
  }

  file {
    "/etc/apt/preferences.d/${name}.pref":
      ensure  => file,
      mode    => '0644',
      owner   => root,
      group   => root,
      content => template('env/common/apt_pinning.erb');
  }
}
