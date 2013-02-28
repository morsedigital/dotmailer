module DotMailer
  class InvalidRequest < Exception
  end

  class NotFound < Exception
  end

  class UnknownDataField < Exception
  end

  class UnknownOptInType < Exception
  end

  class MissingCredentials < Exception
  end
end
