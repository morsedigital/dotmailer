require 'time'

module DotMailer
  class Suppression
    attr_reader :contact, :date_removed, :reason

    def self.suppressed_since(account, time)
      # NOTE: The API states the time should be in XML schema format but it doesn't
      #       actually support that format correctly (it gets confused about time
      #       zones), but treats times with no time zone as UTC, so we use that fact
      #       here.
      #
      # TODO: replace this time formatting with `time.utc.xmlschema` when the API is fixed
      time_string = time.utc.strftime '%Y-%m-%dT%H:%M:%S'

      response = account.client.get("/contacts/suppressed-since/#{time_string}")

      response.map do |attributes|
        new(account, attributes)
      end
    end

    def initialize(account, attributes)
      @contact      = Contact.new account, attributes['suppressedContact']
      @date_removed = Time.parse attributes['dateRemoved']
      @reason       = attributes['reason']
    end

    def to_s
      %{#{self.class.name} reason: #{reason}, date_removed: #{date_removed}, contact: #{contact.to_s}}
    end

    def inspect
      to_s
    end
  end
end
