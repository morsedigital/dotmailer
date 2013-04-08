module DotMailer
  class Exception < ::Exception
  end

  class ImportNotFinished < Exception
  end

  class InvalidFromAddress < Exception
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
