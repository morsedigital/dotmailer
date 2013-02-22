require 'dotmailer/exceptions'
require 'dotmailer/data_field'
require 'dotmailer/client'

module Dotmailer
  def self.data_fields
    client.get_data_fields
  end

  def self.create_data_field(name, options = {})
    client.create_data_field(name, options)
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
