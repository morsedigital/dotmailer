require 'active_support/core_ext/numeric/time'
require 'active_support/cache'

module DotMailer
  class Account
    CACHE_LIFETIME = 1.minute

    attr_reader :client

    def initialize(api_user, api_pass)
      self.client = Client.new(api_user, api_pass)
    end

    def data_fields
      cache.fetch 'data_fields' do
        DataField.all self
      end
    end

    def create_data_field(name, options = {})
      DataField.create self, name, options

      cache.delete 'data_fields'
    end

    def import_contacts(contacts)
      ContactImport.import self, contacts
    end

    def find_contact_by_email(email)
      Contact.find_by_email self, email
    end

    def find_contact_by_id(id)
      Contact.find_by_id self, id
    end

    def find_contacts_modified_since(time)
      Contact.modified_since(self, time)
    end

    def suppress(email)
      client.post_json '/contacts/unsubscribe', 'Email' => email
    end

    def to_s
      "#{self.class.name} client: #{client}"
    end

    def inspect
      to_s
    end

    private
    attr_writer :client

    def cache
      # Auto expire content after CACHE_LIFETIME seconds
      @cache ||= ActiveSupport::Cache::MemoryStore.new :expires_in => CACHE_LIFETIME
    end
  end
end
