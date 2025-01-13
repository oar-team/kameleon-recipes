# frozen_string_literal: true

require_relative 'config-env'
require 'refrepo/data_loader'

REF = load_data_hierarchy.freeze

def all_sites
  REF['sites'].keys
end

def clusters_for_site(site)
  REF['sites'][site]['clusters'].keys
end

def clusters_per_arch_for_site(site)
  clusters = clusters_for_site(site)

  archs_per_cluster = clusters.to_h do |c|
    # Since all nodes in a cluster have the same arch, we can look only at
    # the first node's architecture.
    arch = REF['sites'][site]['clusters'][c]['nodes'].values.first['architecture']['platform_type']
    # Convert arch to g5k's funky arch names.
    [c, ARCH_TO_G5K_ARCH[arch]]
  end
  # Group clusters per arch and return them
  archs_per_cluster.keys.group_by { |k| archs_per_cluster[k] }
end
