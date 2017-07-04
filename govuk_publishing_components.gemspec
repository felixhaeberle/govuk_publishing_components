$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "govuk_publishing_components/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "govuk_publishing_components"
  s.version     = GovukPublishingComponents::VERSION
  s.authors     = ["GOV.UK Dev"]
  s.email       = ["govuk-dev@digital.cabinet-office.gov.uk"]
  s.summary     = "A gem to document components in GOV.UK frontend applications"
  s.description = "A gem to document components in GOV.UK frontend applications"
  s.homepage    = "https://github.com/alphagov/govuk_publishing_components"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "LICENCE.md", "Rakefile", "README.md"]

  s.add_dependency "rails", "~> 5.0.0", ">= 5.0.0.1"
end
