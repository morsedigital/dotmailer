require 'csv'

module Dotmailer
  class ContactImport
    attr_reader :id

    def initialize(client, contacts)
      self.client   = client
      self.contacts = contacts
    end

    def start
      self.id = client.import_contacts contacts_csv
    end

    def status
      if id.nil?
        'NotStarted'
      else
        client.import_status id
      end
    end

    def finished?
      status == 'Finished'
    end

    def to_s
      "#{self.class.name} contacts: #{contacts.to_s}"
    end

    def inspect
      to_s
    end

    private
    attr_accessor :client, :contacts
    attr_writer :id

    def contact_headers
      @contact_headers ||= contacts.map(&:keys).flatten.uniq
    end

    def contacts_csv
      @contacts_csv ||= CSV.generate do |csv|
        csv << contact_headers

        contacts.each do |contact|
          csv << contact_headers.map { |header| contact[header] }
        end
      end
    end
  end
end
