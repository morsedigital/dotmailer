module DotMailer
  module OptInType
    DOUBLE          = 'Double'
    SINGLE          = 'Single'
    UNKNOWN         = 'Unknown'
    VERIFIED_DOUBLE = 'VerifiedDouble'

    def self.all
      constants(false).map(&method(:const_get))
    end

    def self.exists?(opt_in_type)
      all.include?(opt_in_type)
    end
  end
end
