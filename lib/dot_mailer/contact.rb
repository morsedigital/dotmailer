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

    private
    attr_accessor :attributes
  end
end
