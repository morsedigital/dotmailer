require 'csv'

module Dotmailer
  class ContactImport
    def self.client
      Dotmailer.client
    end

    def self.import(contacts)
      contact_import = new(contacts)

      contact_import.start

      contact_import
    end

    attr_reader :id

    def initialize(contacts)
      self.contacts = contacts
    end

    def start
      response = client.post '/contacts/import', contacts_csv

      self.id = response['id']
    end

    def status
      if id.nil?
        'NotStarted'
      else
        response = client.get "/contacts/import/#{id}"

        response['status']
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
    attr_accessor :contacts
    attr_writer :id

    def client
      self.class.client
    end

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
