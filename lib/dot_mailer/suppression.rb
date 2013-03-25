require 'time'

module DotMailer
  class Suppression
    attr_reader :contact, :date_removed, :reason

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
