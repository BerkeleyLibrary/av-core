# ------------------------------------------------------------
# Simplecov

if ENV['COVERAGE']
  require 'colorize'
  require 'simplecov'
end

# ------------------------------------------------------------
# RSpec

require 'webmock/rspec'

RSpec.configure do |config|
  config.color = true
  config.tty = true
  config.formatter = :documentation
  config.before(:each) { WebMock.disable_net_connect!(allow_localhost: true) }
  config.after(:each) { WebMock.allow_net_connect! }
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
  config.shared_context_metadata_behavior = :apply_to_host_groups
end

# ------------------------------------------------------------
# Code under test

require 'av/core'

# ------------------------------------------------------------
# Utility methods

def sru_url_base
  'https://berkeley.alma.exlibrisgroup.com/view/sru/01UCS_BER?version=1.2&operation=searchRetrieve&query='
end

def permalink_base
  'https://search.library.berkeley.edu/permalink/01UCS_BER/iqob43/alma'
end

def alma_sru_url_for(record_id)
  return "#{sru_url_base}alma.mms_id%3D#{record_id}" unless AV::RecordId::Type.for_id(record_id) == AV::RecordId::Type::MILLENNIUM

  full_bib = AV::RecordId.ensure_check_digit(record_id)
  "#{sru_url_base}alma.other_system_number%3DUCB-#{full_bib}-01ucs_ber"
end

def alma_sru_data_path_for(record_id)
  "spec/data/alma/#{record_id}-sru.xml"
end

def stub_sru_request(record_id)
  sru_url = alma_sru_url_for(record_id)
  marc_xml_path = alma_sru_data_path_for(record_id)

  stub_request(:get, sru_url).to_return(status: 200, body: File.read(marc_xml_path))
end

def alma_marc_record_for(record_id)
  marc_xml_path = alma_sru_data_path_for(record_id)
  MARC::XMLReader.new(marc_xml_path).first
end
