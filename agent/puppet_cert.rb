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
        puppet_cert = get_cert
        puppet_cert ||= get_csr

        if puppet_cert.is_a? ::Puppet::SSL::Certificate
          cert = OpenSSL::X509::Certificate.new puppet_cert.content
        elsif puppet_cert.is_a? ::Puppet::SSL::CertificateRequest
          cert = OpenSSL::X509::Request.new puppet_cert.content
        else
          reply.fail "No valid ::Puppet certificate or CSR found."
        end

        reply[:cn] = cert.subject.to_s
        if cert.is_a? OpenSSL::X509::Certificate
          reply[:expiration] = cert.not_after.to_s
          reply[:valid_from] = cert.not_before.to_s
        end
        reply[:alt_name] = puppet_cert.subject_alt_names
        reply[:fingerprint] = get_fingerprint puppet_cert
        reply[:type] = puppet_cert.class.name
      end

    end
  end
end

