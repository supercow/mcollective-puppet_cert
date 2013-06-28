module MCollective
  module Agent
    class Puppet_cert<RPC::Agent

      require 'openssl'
      def startup_hook
        #TODO need to find a good way to discover these
        @ssldir = '/etc/puppetlabs/puppet/ssl'
        @certname = 'localhost'
      end

      action "list" do
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

