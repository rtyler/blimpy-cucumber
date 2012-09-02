require 'fileutils'

require 'rubygems'
require 'blimpy'


module Blimpy
  module Cucumber
    module API
      def start_vms
        # Make sure we set up our vms at some point properly
        expect(vm).to_not be_nil
        @fleet.start
      end

      def destroy_vms
        @fleet.destroy unless @fleet.nil?
      end

      def vm(type='Linux')
        unless @fleet.nil?
          return @fleet.ships.first
        end

        # Default to Ubuntu 12.04 LTS in us-west-2
        image_id = 'ami-4038b470'
        region = 'us-west-2'
        username = 'ubuntu'

        if type == 'FreeBSD'
          # FreeBSD 9.0-RELEASE/amd64 in us-west-2
          image_id = 'ami-cab73afa'
          username = 'root'
        end

        @fleet = Blimpy.fleet do |fleet|
          fleet.add(:aws) do |ship|
            ship.name = "prosody-cucumber"
            # Use m1.small instead of a tiny
            ship.flavor = 'm1.small'
            ship.image_id = image_id
            ship.username = username
            ship.ports = [22, 5222, 5269]
            ship.region = region
            ship.livery = Blimpy::Livery::Puppet
          end
        end
        @fleet.ships.first
      end

      def resources
        # Resources should be an Array of strings that will be joined together to
        # make the full Puppet node manifest that will be provisioned on the host
        @resources ||= []
      end

      def work_dir
        File.expand_path(File.dirname(__FILE__) + "/../../tmp/cucumber")
      end

      def manifest_path
        File.join(work_dir, 'manifests')
      end

      def modules_path
        File.join(work_dir, 'modules')
      end

      def setup_work_dir
        # We can't set this up unless we've already "remembered" our original
        # directory
        expect(@original_dir).to_not be_nil

        FileUtils.mkdir_p(manifest_path)
        prosody_module = File.join(modules_path, 'prosody')
        FileUtils.mkdir_p(prosody_module)

        # Make sure all of these directories are made available in the test
        # directory
        ['manifests', 'templates', 'lib'].each do |linkable|
          original = File.join(@original_dir, linkable)
          next unless File.exists?(original)

          FileUtils.ln_s(original, File.join(prosody_module, linkable))
        end
      end
    end
  end
end

Before do
  @original_dir = Dir.pwd

  unless File.exists?(work_dir)
    FileUtils.mkdir_p(work_dir)
  end

  Dir.chdir(work_dir)

  setup_work_dir
end

After do
  destroy_vms

  Dir.chdir(@original_dir)
  # Nuke the temporary working directory after we're all finished
  FileUtils.rm_rf(work_dir)
end
