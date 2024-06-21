# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "smsaero_api/version"

Gem::Specification.new do |s|
  s.name          = "smsaero_api"
  s.version       = SmsAeroApi::VERSION
  s.licenses      = 'MIT'
  s.summary       = %q{Send SMS via smsaero.ru gate}
  s.description   = %q{Send SMS/HLR/Viber via smsaero.ru gate}
  s.authors       = ["SmsAero"]
  s.email         = ["admin@smsaero.ru"]
  s.homepage      = "https://smsaero.ru/integration/class/ruby"
  s.metadata    = { "source_code_uri" => "https://github.com/smsaero/smsaero_ruby" }

  s.required_ruby_version = '>= 2.5.0'

  s.files         = `git ls-files`.split("\n")
  s.require_paths = ["lib"]
end
