require 'csv'
require 'active_support/core_ext/object/blank'

module DotMailer
  class ContactImport
    def self.import(account, contacts)
      contact_import = new(account, contacts)

      contact_import.start

      contact_import
    end

    attr_reader :id

    def initialize(account, contacts)
      self.account  = account
      self.contacts = contacts
    end

    def start
      validate_headers

      response = client.post_csv '/contacts/import', contacts_csv

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
      status != 'NotFinished'
    end

    def errors
      raise ImportNotFinished unless finished?

      client.get_csv "/contacts/import/#{id}/report-faults"
    end

    def to_s
      "#{self.class.name} contacts: #{contacts.to_s}"
    end

    def inspect
      to_s
    end

    private
    attr_accessor :contacts, :account
    attr_writer :id

    def client
      account.client
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

    # Check that the contact_headers are all valid (case insensitive)
    def validate_headers
      raise UnknownDataField, unknown_headers.join(',') if unknown_headers.present?
    end

    def unknown_headers
      @unknown_headers ||= contact_headers.reject do |header|
        valid_headers.map(&:downcase).include?(header.downcase)
      end
    end

    def valid_headers
      @valid_headers ||= %w(id email optInType emailType) + account.data_fields.map(&:name)
    end
  end
end
