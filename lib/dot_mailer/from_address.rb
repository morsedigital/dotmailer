module DotMailer
  class FromAddress
    def initialize(attributes)
      self.attributes = attributes
    end

    def id
      attributes['id']
    end

    def email
      attributes['email']
    end

    def to_s
      %{#{self.class.name} id: #{id}, email: #{email}}
    end

    def inspect
      to_s
    end

    private
    attr_accessor :attributes
  end
end
