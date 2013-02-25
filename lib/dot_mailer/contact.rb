require 'active_support/core_ext/object/try'

module DotMailer
  class Contact
    def self.client
      DotMailer.client
    end

    def self.find_by_email(email)
      response = client.get("/contacts/#{email}")

      new(response)
    rescue DotMailer::NotFound
      nil
    end

    # The API makes no distinction between finding
    # by email or id, so we just delegate to
    # Contact.find_by_email
    def self.find_by_id(id)
      find_by_email id
    end

    def initialize(attributes)
      self.attributes = attributes
    end

    def id
      attributes['id']
    end

    def email
      attributes['email']
    end

    def opt_in_type
      attributes['optInType']
    end

    def email_type
      attributes['emailType']
    end

    def status
      attributes['status']
    end

    # A wrapper method for accessing data field values by name, e.g.:
    #
    #   contact['FIRSTNAME']
    #
    def [](key)
      if data_fields.has_key?(key)
        data_fields[key]
      else
        raise UnknownDataField, key
      end
    end

    private
    attr_accessor :attributes

    # Convert data fields from the API into a flat hash.
    #
    # The API returns data field values in the following format:
    #
    #   'dataFields' => [
    #     { 'key' => 'FIELD1', 'value' => 'some value'},
    #     { 'key' => 'FIELD2', 'value' => 'some other value'}
    #   ]
    #
    # We convert that here to:
    #
    #   { 'FIELD1' => 'some value', 'FIELD2' => 'some other value' }
    #
    def data_fields
      @data_fields ||=
        begin
          DataField.all.each_with_object({}) do |data_field, hash|
            value = attributes['dataFields'].detect { |f| f['key'] == data_field.name }.try(:[], 'value')

            hash[data_field.name] = value
          end
        end
    end
  end
end
