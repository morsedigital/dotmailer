require 'dotmailer/exceptions'
require 'dotmailer/data_field'
require 'dotmailer/contact_import'
require 'dotmailer/client'

module Dotmailer
  def self.data_fields
    DataField.all
  end

  def self.create_data_field(name, options = {})
    DataField.create name, options
  end

  def self.import_contacts(contacts)
    ContactImport.import contacts
  end

  def self.client
    @client ||= Client.new(api_user, api_pass)
  end

  def self.api_user
    ENV['DOTMAILER_USER'] || raise(MissingCredentials, 'DOTMAILER_USER is not set in the environment')
  end

  def self.api_pass
    ENV['DOTMAILER_PASS'] || raise(MissingCredentials, 'DOTMAILER_PASS is not set in the environment')
  end
end
