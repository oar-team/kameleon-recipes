# Marking images for debug purpose and to help kadeploy and pre/post-install to recognize images

class env::min::add_image_version_in_etc () {

  file {
    '/etc/grid5000':
      ensure   => directory,
      mode     => '0755',
      owner    => root,
      group    => root;
    "/etc/grid5000/release":
      ensure   => file,
      mode     => '0644',
      owner    => root,
      source   => 'puppet:///modules/env/min/image_versioning/release',
      group    => root;
  }
}
