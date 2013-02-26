Test against live API
---------------------

The dotMailer does not have a sandbox mode so we will need to be careful that we do not send mail to real email addresses whilst testing.

We should consider using [VCR](https://github.com/vcr/vcr) to cache HTTP requests from the API.
