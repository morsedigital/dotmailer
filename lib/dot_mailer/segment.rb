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
      client.post_json "/segments/refresh/#{self.id}", {}
    end

    def refresh_progress
      response = client.get "/segments/refresh/#{self.id}"
      return response["status"]
    end

    private
    attr_accessor :attributes, :account

    def client
      account.client
    end
  end
end

