metadata :name => "puppet_cert",
         :description => "Manage Puppet SSL certs",
         :author => "James Sweeny <james.sweeny@puppetlabs.com>",
         :license => "Apache 2.0",
         :version => "0.0.1",
         :url => "http://puppetlabs.com",
         :timeout => 5

requires :mcollective => "2.2.1"

action "regen", :description => "Cleans and regenerates puppet agent SSL keys and certs." do
  display :always

end

action "clean_agent", :description => "Clean local SSL keys and certs from the puppet agent" do
  display :always

  input :clean_ca,
        :prompt      => "Clean cached CA data?",
        :description => "Will clean cached CA certs and CRLs",
        :type        => :boolean,
        :default     => true,
        :optional    => true

end

action "list", :description => "List details of each puppet agent's certificate" do
  display :always

  output :expiration,
         :description => "The expiration date of the puppet cert",
         :display_as  => "Expiration Date",
         :optional    => true

  output :valid_from,
         :description => "The date the puppet cert is valid from",
         :display_as  => "Valid from",
         :optional    => true

  output :cn,
         :description => "The certname of the puppet agent",
         :display_as  => "Subject Name",
         :default     => "Unknown"

  output :alt_name,
         :description => "Subject alternative names",
         :display_as  => "subjectAltNames",
         :default     => ""

  output :fingerprint,
         :description => "The hash fingerprint of the puppet agent cert",
         :display_as  => "fingerprint",
         :default     => nil

  output :type,
         :description => "Whether the output describes a CSR or a signed cert",
         :display_as  => "Type",
         :default     => nil

end

