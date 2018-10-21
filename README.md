# Blocking Facebook from your machine using the blockhosts gem

    require 'blockhosts'

    # add the facebook domains to /etc/hosts
    Host.add 'facebook', 'http://a0.jamesrobertson.eu/r/txt/2018/oct/21/' + 
                          'facebook-list-of-urls-to-block.txt'

    # Enforce the blocking of Facebook domains in /etc/hosts
    Host.block 'facebook' 

    #Host.unblock 'facebook' # comments out the facebook entries in /etc/hosts
    #Host.rm 'facebook' # removes the facebook entries from /etc/hosts

blockhosts facebook hosts block gem
