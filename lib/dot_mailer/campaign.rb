module DotMailer
  class Campaign
    def self.create(account, attributes)
      params = {}

      params['Name']             = attributes[:name]               || raise('missing :name')
      params['Subject']          = attributes[:subject]            || raise('missing :subject')
      params['FromName']         = attributes[:from_name]          || raise('missing :from_name')
      params['HtmlContent']      = attributes[:html_content]       || raise('missing :html_content')
      params['PlainTextContent'] = attributes[:plain_text_content] || raise('missing :plain_text_content')

      raise 'missing :from_email' unless attributes[:from_email]

      from_address = account.from_addresses.detect do |from_address|
        from_address.email == attributes[:from_email]
      end

      raise InvalidFromAddress, attributes[:from_email] unless from_address.present?

      params['FromAddress'] = from_address.to_hash

      response = account.client.post_json('/campaigns', params)

      new(account, response)
    end

    def self.find_by_id(account, id)
      response = account.client.get "/campaigns/#{id}"

      new(account, response)
    end

    def initialize(account, attributes)
      self.account    = account
      self.attributes = attributes
    end

    def id
      attributes['id']
    end

    def name
      attributes['name']
    end

    def from_name
      attributes['fromName']
    end

    def from_address
      FromAddress.new attributes['fromAddress']
    end

    def html_content
      attributes['htmlContent']
    end

    def plain_text_content
      attributes['plainTextContent']
    end

    def to_s
      %{#{self.class.name} id: #{id}, name: #{name}}
    end

    def inspect
      to_s
    end

    def send_to_contact_ids(contact_ids)
      client.post_json '/campaigns/send', {
        'campaignId' => id,
        'contactIds' => contact_ids
      }
    end

    def send_to_segment(segment)
       client.post_json '/campaigns/send', {
         'campaignId' => id,
         'addressBookIds' => [segment.id]
       }
     end
    private
    attr_accessor :attributes, :account

    def client
      account.client
    end
  end
end
