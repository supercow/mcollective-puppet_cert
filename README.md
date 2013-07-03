puppet\_cert
===========

Manage Puppet SSL agent certs

      Author: James Sweeny <james.sweeny@puppetlabs.com>
     Version: 0.0.1
     License: Apache 2.0
     Timeout: 5
   Home Page: http://puppetlabs.com

   Requires MCollective 2.2.1 or newer
   Requires Puppet 3.0.0 or newer

EXAMPLES:
=========
```shell
root@master vagrant]# mco rpc puppet_cert list
Discovering hosts using the mc method for 2 second(s) .... 2

 * [ ========================================================> ] 2 / 2


agent1.localdomain
   subjectAltNames: []
      Subject Name: /CN=agent1.localdomain
   Expiration Date: nil
       fingerprint: (SHA256) 31:39:FF:67:89:54:2D:78:1C:1C:C9:B5:7B:05:95:B3:52:97:28:F3:00:37:71:90:FC:AD:2C:0B:8C:29:21:61
              Type: Puppet::SSL::CertificateRequest
        Valid from: nil

master.localdomain
   subjectAltNames: ["DNS:master",
                     "DNS:master.localdomain",
                     "DNS:puppet",
                     "DNS:puppet.localdomain"]
      Subject Name: /CN=master.localdomain
   Expiration Date: 2018-07-02 20:58:20 UTC
       fingerprint: (SHA256) 47:D8:1C:3C:05:C7:EF:A3:6E:A0:98:3E:85:77:F3:DF:03:63:28:47:FA:4F:89:C1:E8:F5:75:09:4A:AF:C3:54
              Type: Puppet::SSL::Certificate
        Valid from: 2013-07-02 20:58:20 UTC



Finished processing 2 / 2 hosts in 551.50 ms
```

ACTIONS:
========
   clean\_agent, list, regen

   clean\_agent action:
   -------------------
       Clean local SSL keys and certs from the puppet agent

       INPUT:
           clean\_ca:
              Description: Will clean cached CA certs and CRLs
                   Prompt: Clean cached CA data?
                     Type: boolean


       OUTPUT:
   list action:
   ------------
       List details of each puppet agent's certificate

       INPUT:

       OUTPUT:
           alt\_name:
              Description: Subject alternative names
               Display As: subjectAltNames

           cn:
              Description: The certname of the puppet agent
               Display As: Subject Name

           expiration:
              Description: The expiration date of the puppet cert
               Display As: Expiration Date

           fingerprint:
              Description: The hash fingerprint of the puppet agent cert
               Display As: fingerprint

           type:
              Description: Whether the output describes a CSR or a signed cert
               Display As: Type

           valid\_from:
              Description: The date the puppet cert is valid from
               Display As: Valid from

   regen action:
   -------------
       Cleans and regenerates puppet agent SSL keys and certs.

       INPUT:

       OUTPUT:
