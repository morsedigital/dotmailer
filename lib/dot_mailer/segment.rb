module DotMailer
  class Segment
    def initialize(account, attributes)
      self.account = account
      self.attributes = attributes
    end

    def self.find_by_id(account, id)
      response = account.client.get "/segments"
      response = response.detect {|segment| segment['id'] == id}

      new(account, response)
    end

    def id
      attributes['id']
    end

    def refresh!
      client.post "/segments/refresh/#{self.id}"
    end

    private
    attr_accessor :attributes, :account
  end
end

