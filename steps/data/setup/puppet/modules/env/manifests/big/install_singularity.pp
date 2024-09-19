class env::big::install_singularity () {
  include env::common::software_versions

        env::common::g5kpackages {
          "${::env::common::software_versions::singularity_package}":
            ensure  => "${::env::common::software_versions::singularity_version}",
            release => "${::lsbdistcodename}";
        }
}
