# frozen_string_literal: true

require 'json'
require 'yaml'
require 'refrepo/data_loader'
require 'optparse'

require_relative 'config'

options = {}
OptionParser.new do |parser|
  parser.on('-o AAA', '--output', 'Output folder')
end.parse!(into: options)

unless File.directory?(options[:output])
  raise OptionParser::InvalidArgument, "'#{options[:output]}' is not an existing folder"
end

ENABLE_UNUSED_GEN_JOBS = !(ENV['ENABLE_UNUSED_GEN_JOBS'] || '').empty?
ENABLE_UNUSED_TEST_JOBS = !(ENV['ENABLE_UNUSED_TEST_JOBS'] || '').empty?

REFAPI_BRANCH = (ENV['REFREPO_BRANCH'] || 'master').freeze

CLUSTERS = (ENV['CLUSTERS'] || '').split(',').freeze
ENVIRONMENTS_REGEX = /#{ENV['ENVIRONMENTS'] || '.*'}/.freeze
EXPLICIT_ENVIRONMENTS_LIST = (ENV['ENVIRONMENTS_LIST'] || '').split(',').freeze

GENERATE_ENVS = map_all_envs do |os, version, arch, variant|
  full_name = env_name(os, version, arch, variant)
  full_name if ENVIRONMENTS_REGEX.match?(full_name) || EXPLICIT_ENVIRONMENTS_LIST.include?(full_name)
end.flatten.compact.freeze

puts "unused gen jobs enabled: #{ENABLE_UNUSED_GEN_JOBS}"
puts "unused test jobs enabled: #{ENABLE_UNUSED_TEST_JOBS}"


def clusters_per_arch
  res = {}
  all_sites.each do |site|
    clusters_per_arch_for_site(site).each do |arch, clusters|
      res[arch] ||= {}
      res[arch][site] = clusters
    end
  end
  res
end

def autostart_cluster?(cluster)
  CLUSTERS.empty? || CLUSTERS.include?(cluster)
end

def emit_cluster?(cluster)
  ENABLE_UNUSED_TEST_JOBS || autostart_cluster?(cluster)
end

def autostart_generation?(environment)
  GENERATE_ENVS.include?(environment)
end

def emit_generation?(environment)
  ENABLE_UNUSED_GEN_JOBS || autostart_generation?(environment)
end

def pipeline_for_config(clusters_config, os, version, arch, variant)
  # NOTE: I intentionally used the "rocket" notation for the hashes, because there
  # is not built-in way to stringify keys when using to_yaml, and extending
  # Psych::Visitors::YAMLTree's visit_Symbol seems a bit overkill for such a small
  # code.
  environment = env_name(os, version, arch, variant)
  common_inputs = {
    'environment-name' => environment,
  }
  generate_image_job = {
    'local' => 'ci/gitlab/generate-image.yml',
    'inputs' => {
      'autostart' => autostart_generation?(environment),
      **common_inputs,
    },
  }
  tests_clusters_jobs = clusters_config[arch].map do |site, clusters|
    clusters.select(&method(:emit_cluster?)).map do |cluster|
      {
        'local' => 'ci/gitlab/test-image-on-cluster.yml',
        'inputs' => {
          'site' => site,
          'cluster' => cluster,
          'refapi' => REFAPI_BRANCH,
          'autostart' => autostart_cluster?(cluster),
          **common_inputs,
        },
      }
    end
  end.flatten
  {
    'stages' => ['generate', *all_sites],
    'include' => [
      'ci/gitlab/post-job.yml',
      generate_image_job,
      *tests_clusters_jobs,
    ],
  }
end

def main_pipeline
  environments_pipelines = map_all_envs do |os, version, arch, variant|
    next unless emit_generation?(env_name(os, version, arch, variant))

    {
      'local' => 'ci/gitlab/gen-job-os.yml',
      'inputs' => {
        'os' => os,
        'version' => version,
        'arch' => arch,
        'variant' => variant,
      },
    }
  end.flatten.compact
  {
    'stages' => ['setup', *ENV_CONFIG.keys],
    # NOTE: this job is here to simply make available the generated artifacts
    # to the child pipeline, because we can't reference grand parents jobs
    # in include:trigger.
    'gen-child-child-pipelines' => {
      'stage' => 'setup',
      'tags' => %w[linux],
      'needs' => [{
        'pipeline' => '$PARENT_PIPELINE_ID',
        'job' => 'gen-child-pipelines',
      }],
      'script' => ['echo ok'],
      'artifacts' => {
        'paths' => %w[generated],
      },
    },
    'include' => environments_pipelines,
  }
end

clusters_config = clusters_per_arch

File.open("#{options[:output]}/main.yml", 'w') do |file|
  YAML.dump(main_pipeline, file)
end

map_all_envs do |os, version, arch, variant|
  next unless emit_generation?(env_name(os, version, arch, variant))

  pipeline = pipeline_for_config(clusters_config, os, version, arch, variant)
  File.open("#{options[:output]}/#{os}-#{version}-#{arch}-#{variant}.yml", 'w') do |file|
    YAML.dump(pipeline, file)
  end
end
