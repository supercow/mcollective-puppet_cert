metadata :name => "puppet_cert",
         :description => "Manage Puppet SSL certs",
         :author => "James Sweeny <james.sweeny@puppetlabs.com>",
         :license => "Apache 2.0",
         :version => "0.0.1",
         :url => "http://puppetlabs.com",
         :timeout => 5

requires :mcollective => "2.2.1"

action "clean_self", :description => "Clean local SSL keys and certs from the puppet agent" do
  display :always

end

action "list", :description => "List details of each puppet agent's certificate" do
  display :always

  output :expiration,
         :description => "The expiration date of the puppet cert",
         :display_as  => "Expiration Date",
         :default     => nil

  output :valid_from,
         :description => "The date the puppet cert is valid from",
         :display_as  => "Valid from",
         :default     => nil

  output :cn,
         :description => "The certname of the puppet agent",
         :display_as  => "Subject Name",
         :default     => "Unknown"

  output :alt_name,
         :description => "Subject alternative names",
         :display_as  => "subjectAltNames",
         :default     => ""

  output :identifier,
         :description => "The X509 fingerprint of the puppet agent cert",
         :display_as  => "keyIdentifier",
         :default     => nil
end

