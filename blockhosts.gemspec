Gem::Specification.new do |s|
  s.name = 'blockhosts'
  s.version = '0.3.0'
  s.summary = 'Conveniently enables or disables the blocking of hostnames ' + 
      'in the /etc/hosts file e.g. 127.0.0.1 facebook.com'
  s.authors = ['James Robertson']
  s.files = Dir['lib/blockhosts.rb']
  s.add_runtime_dependency('rxfhelper', '~> 0.9', '>=0.9.1')
  s.add_runtime_dependency('sps-sub', '~> 0.3', '>=0.3.7') 
  s.signing_key = '../privatekeys/blockhosts.pem'
  s.cert_chain  = ['gem-public_cert.pem']
  s.license = 'MIT'
  s.email = 'james@jamesrobertson.eu'
  s.homepage = 'https://github.com/jrobertson/blockhosts'
end
