module DotMailer
  class ImportNotFinished < Exception
  end

  class InvalidRequest < Exception
  end

  class NotFound < Exception
  end

  class UnknownDataField < Exception
  end

  class UnknownOptInType < Exception
  end
end
