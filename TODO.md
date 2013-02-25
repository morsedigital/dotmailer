Test against live API
---------------------

The dotMailer does not have a sandbox mode so we will need to be careful that we do not send mail to real email addresses whilst testing.

We should consider using [VCR](https://github.com/vcr/vcr) to cache HTTP requests from the API.

Support multiple accounts
-------------------------

At present, only one API account can be used by the library, and this account is defined in the calling environment.

We should support using multiple accounts by:

* Stop expecting credentials to be passed in via environment variables, callers of the gem can decide where they store their credentials and can explicitly create clients

* Move the module methods from DotMailer e.g. `#data_fields`, to DotMailer::Client or add a client argument to each of the module methods in DotMailer
