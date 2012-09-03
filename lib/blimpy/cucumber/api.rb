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

      def vm_name
        # If @vmname exists, we'll use that
        return @vmname unless @vmname.nil?
        'blimpy-cucumber-test'
      end

      def vm_flavor
        return @vmflavor unless @vmflavor.nil?
        'm1.small'
      end

      def vm_ports
        return @vmports unless @vmports.nil?
        [22, 80, 8080]
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
            ship.name = vm_name
            ship.flavor = vm_flavor
            ship.image_id = image_id
            ship.username = username
            ship.ports = vm_ports
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

      def nodes
        # Nodes should be an Array of strings that will be joined together to
        # be tacked into the site.pp when the host is provisioned
        @nodes ||= []
      end

      def work_dir
        File.join(Dir.pwd, 'tmp', 'cucumber')
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

        # If we have an ignore file, we'll probably want it in the new tree as
        # well
        if File.exists? '.blimpignore'
          FileUtils.ln_s(File.join(@original_dir, '.blimpignore'), '.blimpignore')
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
