module Dotmailer
  class DataField
    def initialize(attributes)
      self.attributes = attributes
    end

    def name
      attributes['name']
    end

    def type
      attributes['type']
    end

    def visibility
      attributes['visibility']
    end

    def default
      attributes['defaultValue']
    end

    def to_json(options = {})
      attributes.to_json
    end

    def to_s
      %{#{self.class.name} name: "#{name}", type: "#{type}", visibility: "#{visibility}", default: "#{default}"}
    end

    def ==(other)
      attributes == other.attributes
    end

    protected
    attr_accessor :attributes
  end
end
