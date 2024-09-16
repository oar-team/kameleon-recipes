# frozen_string_literal: true

require 'json'
require 'yaml'
require 'refrepo/data_loader'
require 'optparse'

require_relative '../config'

options = {}
OptionParser.new do |parser|
  parser.on('-o AAA', '--output', 'Output folder')
  parser.on('-t TTT', '--tag', 'Tag')
  parser.on('-c CCC', '--commit', 'Commit')
end.parse!(into: options)

unless File.directory?(options[:output])
  raise OptionParser::InvalidArgument, "'#{options[:output]}' is not an existing folder"
end

if options[:tag].nil? || options[:tag].empty?
  raise OptionParser::InvalidArgument, "Please specify a tag"
end

if options[:commit].nil? || options[:commit].empty?
  raise OptionParser::InvalidArgument, "Please specify a commit"
end

# FIXME: check the tag name matches 'envname/YYYYMMDDXX'
ENV_NAME, TAG=options[:tag].split('/')
# FIXME: from here we could (should ?) make sure the tag matches the commit.
COMMIT=options[:commit]

puts "Generating push pipeline for #{ENV_NAME} from commit #{COMMIT}"


# This function generate the necessary include to generate all the images
# for ENV_NAME.
# TODO: there is a discussion to have here, do we want to :
#   - assume all images have already been generated (eg: by a manual pipeline on the tagged commit)?
#   - disregard all previous generations and *just* use image generation from this pipeline?
#   - a bit of both: we have the tagged commit, so we could look for the already
#   generated images, and generate the missing one(s).
# I'll let these jobs in manual for now.
def gen_environments_includes
  map_all_envs do |os, version, arch, variant|
    environment = env_name(os, version, arch, variant)
    next unless environment.start_with?(ENV_NAME)
    {
      'local' => 'ci/gitlab/generate-image.yml',
      'inputs' => {
        'autostart' => false,
        'environment-name' => environment,
      },
    }
  end.flatten.compact
end

def gen_sites_per_arch
  sites_per_arch={}
  all_sites.each do |s|
    clusters_per_arch = clusters_per_arch_for_site(s)
    clusters_per_arch.keys.each do |arch|
      sites_per_arch[arch] ||= []
      sites_per_arch[arch] << s
    end
  end
  sites_per_arch
end

LOCAL_FAILURE_HANDLER=<<-HANDLER
if [ -n "${LOCAL_FAIL}" ]; then
  FAILED_SITES="${FAILED_SITES} ${LOCAL_FAIL}"
  echo -e "\e[31mPushing the image to ${LOCAL_FAIL} failed, see the log.\e[0m"
  LOCAL_FAIL=""
fi
HANDLER

FAILURE_HANDLER=<<-HANDLER
if [ -n "${FAILED_SITES}" ]; then
  echo "The following site(s) failed:${FAILED_SITES}, please take a look at the log"
  exit 1;
fi
HANDLER

START_SECTION='echo -e "\e[0Ksection_start:`date +%%s`:push_%{site}[collapsed=true]\r\e[0KPushing image to %{site}"'
END_SECTION='echo -e "\e[0Ksection_end:`date +%%s`:push_%{site}\r\e[0K"'

def gen_environments_push
  # NOTE: I would have loved to use includes here too, but there is a 150
  # includes limit that we hit :(
  # For these jobs it's not bad so I have inlined them.

  full_pipeline = {}
  all_stages = %w(generate)
  sites_per_arch = gen_sites_per_arch
  map_all_envs do |os, version, arch, variant|
    environment = env_name(os, version, arch, variant)
    next unless environment.start_with?(ENV_NAME)
    env_with_arch = "#{os}#{version}-#{arch}"
    all_stages << env_with_arch
    sites_for_env = sites_per_arch[arch]
    oar_arch = G5K_ARCH_TO_ARCH[arch]

    # Create a push command for each relevant site
    # We wrap the push in a collapsed log, and each site failure is recorded
    # locally and "ignored" (as far as gitlab-ci is concerned).
    # At the end of all sites we handle all local failures and we fail the job
    # if any site has failed.
    push_all = sites_for_env.map do |site|
      [
        START_SECTION % { site: site },
        "cat ci/gitlab/push/create-image-locally.sh| ssh ajenkins@#{site} 'TMP=`mktemp -d`; cat - > $TMP/job.sh; chmod 755 -R $TMP; $TMP/job.sh -e #{environment} -a #{oar_arch} -c #{COMMIT} -t #{TAG}; RETVAL=$?; rm -rf $TMP; exit $RETVAL' || LOCAL_FAIL=\"#{site}\"",
        END_SECTION % { site: site },
        LOCAL_FAILURE_HANDLER,
      ]
    end.flatten
    full_pipeline["#{environment}"] = {
      'stage' => env_with_arch,
      'variables' => {
        'AUTOSTART' => false,
        'FAILED_SITES' => '',
      },
      # We start the job automatically if we're told to do so, otherwise we put
      # the job in manual mode.
      'rules' => [
        { 'if' => '$AUTOSTART == "true"' },
        { 'when' => 'manual' },
      ],
      'needs' => [],
      'tags' => %w(grid5000-shell),
      'script' => [
        "echo \"Sending and executing the push script on relevant sites (#{sites_for_env.join(",")})\"",
        # Send and execute the script on the relevant sites.
        *push_all,
        FAILURE_HANDLER,
        # TODO: do we want to display image versions on all relevant sites ?
      ],
    }
  end.flatten.compact
  full_pipeline['stages'] = all_stages.uniq
  full_pipeline
end

def main_pipeline
  {
    'stages' => ['generate', *all_sites],
    'include' => [
      # FIXME: optionally do this?
      # *gen_environments_includes,
    ],
    **gen_environments_push,
  }
end

File.open("#{options[:output]}/main-tag.yml", 'w') do |file|
  YAML.dump(main_pipeline, file)
end
