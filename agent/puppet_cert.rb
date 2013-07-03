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

      def clean_own_ssl
        ::Puppet::Face[:certificate,'0.0.1'].destroy @certname, {:ca_location => 'local'}
        ::Puppet::Face[:key,'0.0.1'].destroy @certname
        ::Puppet::Face[:certificate_request,'0.0.1'].destroy @certname
      end

      def clean_cached_ca
        ::Puppet::Face[:certificate,'0.0.1'].destroy 'ca', {:ca_location => 'local'}

        # dummy text required - #7833
        ::Puppet::Face[:certificate_revocation_list,'0.0.1'].destroy 'dummy_text_just_because'
      end

      def generate_cer
        ::Puppet::Face[:certificate,'0.0.1'].generate @certname, {:ca_location => 'remote'}
      end

      def get_cert
        ::Puppet::Face[:certificate,'0.0.1'].find @certname, {:ca_location => 'local'}
      end

      def get_csr
        ::Puppet::Face[:certificate_request,'0.0.1'].find @certname
      end

      def get_fingerprint puppet_ssl_obj
        algo = puppet_ssl_obj.digest_algorithm
        hash = OpenSSL::Digest.new(algo, puppet_ssl_obj.content.to_der)
        "(#{algo.upcase}) #{hash.hexdigest.scan(/../).join(':').upcase}"
      end

      action "regen" do
        clean_own_ssl
        clean_cached_ca
        generate_cer
      end

      action "clean_agent" do
        reply[:success] = true
        begin
          clean_own_ssl
          clean_cached_ca unless request[:clean_ca] == false
        rescue
          reply[:success] = false
        end
      end

      action "list" do

        raw_cert = get_cert
        if raw_cert != nil
          cert = OpenSSL::X509::Certificate.new raw_cert.content
          extensions = cert.extensions

          reply[:cn] = cert.subject.to_s
          reply[:expiration] = cert.not_after.to_s
          reply[:valid_from] = cert.not_before.to_s
          reply[:alt_name] = raw_cert.subject_alt_names
          reply[:fingerprint] = get_fingerprint raw_cert
          reply[:type] = raw_cert.class.name
        else
          raw_csr = get_csr
          csr = OpenSSL::X509::Request.new raw_csr.content
          extensions = csr.attributes

          reply[:cn] = csr.subject.to_s
          reply[:expiration] = nil
          reply[:valid_from] = nil
          reply[:alt_name] = raw_csr.subject_alt_names
          reply[:fingerprint] = get_fingerprint raw_csr
          reply[:type] = raw_csr.class.name
        end
      end

    end
  end
end

