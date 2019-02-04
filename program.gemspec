# coding: UTF-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "program"
  spec.version       = '1.0'
  spec.authors       = ["JSH"]
  spec.email         = ["fake-address@email.com"]
  spec.summary       = %q{Pull custom reports using the NICE-inContact reporting API}
  spec.description   = %q{Program uses the NICE-inContact reporting API to pull custom reporting templates from VCC}
  spec.homepage      = ""
  spec.license       = ""

  spec.files         = ['lib/program.rb']
  spec.executables   = ['bin/program']
  spec.test_files    = ['tests/test_program.rb']
  spec.require_paths = ["lib"]
end
