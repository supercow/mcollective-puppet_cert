module MCollective
  module Agent
    class Puppet_cert<RPC::Agent

      require 'openssl'
      require 'puppet'
      require 'puppet/face'
      def startup_hook
        unless ::Puppet.settings.app_defaults_initialized?
          ::Puppet.settings.preferred_run_mode = :agent
          ::Puppet.settings.initialize_global_settings([])
          ::Puppet.settings.initialize_app_defaults(::Puppet::Settings.app_defaults_for_run_mode(::Puppet.run_mode))
        end
        @ssldir = ::Puppet[:ssldir]
        @certname = ::Puppet[:certname]
      end

      action "clean_self" do
        reply[:success] = true
        begin
          ::Puppet::Face[:certificate,'0.0.1'].destroy @certname, {:ca_location => 'local'}
          ::Puppet::Face[:key,'0.0.1'].destroy @certname
          ::Puppet::Face[:certificate_request,'0.0.1'].destroy @certname
          ::Puppet::Face[:certificate,'0.0.1'].destroy 'ca', {:ca_location => 'local'}
        rescue
          reply[:success] = false
        end
      end

      action "list" do
        # would be really f'in sweet if I could use faces here...
        raw = File.read("#{@ssldir}/certs/#{@certname}.pem")
        cert = OpenSSL::X509::Certificate.new raw

        alt_name = ''
        identifier = ''
        cert.extensions.each do |ext|
          case ext.oid
          when 'subjectAltName'
            alt_name = ext.value
          when 'subjectKeyIdentifier'
            identifier = ext.value
          end
        end

        reply[:cn] = cert.subject.to_s
        reply[:expiration] = cert.not_after.to_s
        reply[:alt_name] = alt_name.to_s
        reply[:identifier] = identifier
        reply[:valid_from] = cert.not_before.to_s
      end

    end
  end
end

