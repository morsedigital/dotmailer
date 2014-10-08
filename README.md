dotMailer [![Build Status](https://travis-ci.org/econsultancy/dotmailer.png?branch=master)](https://travis-ci.org/econsultancy/dotmailer) [![Gem Version](https://badge.fury.io/rb/dotmailer.png)](http://badge.fury.io/rb/dotmailer) 
=========

[dotMailer](http://www.dotmailer.co.uk/) provide both a REST and SOAP API for interacting with their system. The REST API supports both XML and JSON payloads.

This gem provides a Ruby wrapper allowing you to access the REST API, and uses JSON payloads.

For a full description of the API, see https://api.dotmailer.com

Installation
------------

To install as a standalone gem:

    gem install dotmailer

To install as part of a project managed by bundler, add to your Gemfile:

    gem 'dotmailer'

Usage
-----

Interaction with the dotMailer API is done via a `DotMailer::Account` object, which is initialized with an API username and password:

    account = DotMailer::Account.new('your-api-username', 'your-api-password')

All interaction via this object will be for the dotMailer account associated with the API credentials.

For instructions on how to obtain your API username and password, see [here](http://www.dotmailer.co.uk/api/more_about_api/getting_started_with_the_api.aspx).

Data Fields
-----------

### List

`DotMailer::Account#data_fields` will return an Array of `DotMailer::DataField` objects representing the data fields for the account's global address book:

    account = DotMailer::Account.new('your-api-username', 'your-api-password')

    account.data_fields
    => [
         DotMailer::DataField name: "FIELD1", type: "String", visibility: "Public", default: "",
         DotMailer::DataField name: "FIELD2", type: "Numeric", visibility: "Private", default: 0
       ]

NOTE: The returned data fields are cached in memory for `DotMailer::Account::CACHE_LIFETIME` seconds to avoid unnecessarily hitting the API.

### Create

`DotMailer::Account#create_data_field` will attempt to create a new data field. On failure it raises an exception:

    account = DotMailer::Account.new('your-api-username', 'your-api-password')

    account.create_data_field 'FIELD3', :type => 'String'

    account.create_data_field 'FIELD3', :type => 'String'
    => DotMailer::InvalidRequest: Field already exists. ERROR_NON_UNIQUE_DATAFIELD

NOTE: successfully creating a data field via this method will invalidate any cached data fields.

Contacts
--------

### Finding A Contact

There are two ways to find contacts via the API, using a contact's email address or id.

The gem provides two methods for doing so: `DotMailer::Account#find_contact_by_email` and `DotMailer::Account#find_contact_by_id`.

Suppose you have one contact with email john@example.com and id 12345, then:

    account = DotMailer::Account.new('your-api-username', 'your-api-password')

    account.find_contact_by_email 'john@example.com'
    => DotMailer::Contact id: 12345, email: john@example.com

    account.find_contact_by_email 'sue@example.com'
    => nil

    account.find_contact_by_id 12345
    => DotMailer::Contact id: 12345, email: john@example.com

    account.find_contact_by_id 54321
    => nil

### Finding contacts modified since a particular time

Contacts modified since a particular time can be retrieved by passing a Time object to `DotMailer::Account#find_contacts_modified_since`:

    account = DotMailer::Account.new('your-api-username', 'your-api-password')

    time = Time.parse('1st March 2013 15:30')

    account.find_contacts_modified_since(time)
    => [
         DotMailer::Contact id: 123, email: bob@example.com,
         DotMailer::Contact id: 345, email: sue@example.com
       ]

### Updating a contact

Contacts can be updated by assigning new values and calling `DotMailer::Contact#save`:

    account = DotMailer::Account.new('your-api-username', 'your-api-password')

    contact = account.find_contact_by_email 'john@example.com'
    => DotMailer::Contact id: 12345, email: john@example.com, email_type: Html

    contact.email_type
    => 'Html'
    contact.email_type = 'PlainText'
    => 'PlainText

    contact.save

    contact = DotMailer.find_contact_by_email 'john@example.com'
    => DotMailer::Contact id: 12345, email: john@example.com, email_type: PlainText

### Resubscribing a contact

The dotMailer API provides a specific endpoint for resubscribing contacts which will initiate the resubscribe process via email, then redirect the contact to a specified URL.

This can be accessed through the `DotMailer::Contact#resubscribe` method:

    contact = DotMailer.find_contact_by_email 'john@example.com'
    => DotMailer::Contact id: 12345, email: john@example.com, status: Unsubscribed

    contact.subscribed?
    => false
    contact.resubscribe 'http://www.example.com/resubscribed'

Then, once the contact has gone through the resubscribe process and been redirected to the specified URL:

    contact = DotMailer.find_contact_by_email 'john@example.com'
    => DotMailer::Contact id: 12345, email: john@example.com, status: Subscribed

    contact.subscribed?
    => true

### Deleting a contact

Contacts can be deleted by calling `DotMailer::Contact#delete`:

    account = DotMailer::Account.new('your-api-username', 'your-api-password')

    contact = account.find_contact_by_email 'john@example.com'
    => DotMailer::Contact id: 12345, email: john@example.com, email_type: Html

    contact.delete

### Bulk Import

`DotMailer::Account#import_contacts` will start a batch import of contacts into the global address book, and return a `DotMailer::ContactImport` object which has a `status`:

    account = DotMailer::Account.new('your-api-username', 'your-api-password')

    contacts = [
      { 'Email' => 'joe@example.com' },
      { 'Email' => 'sue@example.com' },
      { 'Email' => 'bob@example.com' },
      { 'Email' => 'invalid@email'   }
    ]

    import = account.import_contacts contacts
    => DotMailer::ContactImport contacts: [{"Email"=>"joe@example.com" }, {"Email"=>"sue@example.com" }, {"Email"=>"bob@example.com"}]

    import.finished?
    => false
    import.status
    => "NotFinished"


The call can also block for you and will wait until the import is finished :

    import = account.import_contacts contacts, wait_for_finish: true

    # it will block here until finished is true
    # if the import takes longer than 385 seconds then it will raise `DotMailer::ImportNotFinished`

    import.finished?
    => true


Then, once the import has finished, you can query the status and get any errors (as a CSV::Table object):

    import.finished?
    => true
    import.status
    => "Finished"

    errors = import.errors
    => #<CSV::Table>
    errors.count
    => 1
    errors.first
    => #<CSV::Row "Reason":"Invalid Email" "Email":"invalid@email">

**NOTE** The specified contacts can only have the following keys (case insensitive):

* `id`
* `email`
* `optInType`
* `emailType`
* Any data field name for the account (i.e. any value in `account.data_fields.map(&:name)`)

If any other key is present in any of the contacts, a `DotMailer::UnknownDataField` error will be raised

Suppressions
------------

The dotMailer API provides an endpoint for retrieving suppressions since a particular point in time, where a "suppression" is the combination of a contact, a removal date, and a reason for the suppression.

To fetch these suppressions, pass a Time object to `DotMailer::Account#find_suppressions_since`:

    account = DotMailer::Account.new('your-api-username', 'your-api-password')

    time = Time.parse('1st March 2013 15:30')

    suppressions = account.find_suppressions_since(time)
    => [
         DotMailer::Suppression reason: Unsubscribed, date_removed: 2013-03-02 14:00:00 UTC,
         DotMailer::Suppression reason: Unsubscribed, date_removed: 2013-03-04 16:00:00 UTC
       ]

    suppressions.first.contact
    => DotMailer::Contact id: 12345, email: john@example.com

Campaigns
---------

### From addresses

Campaigns can only be sent with a from address which has been set up in dotMailer (see [here](https://support.dotmailer.com/entries/20653397-How-do-I-create-a-custom-from-address-or-additional-alias-)).

To access this list of from addresses, call `DotMailer::Account#from_addresses`:

    account = DotMailer::Account.new('your-api-username', 'your-api-password')

    account.from_addresses
    => [
         DotMailer::FromAddress id: 123 email: info@example.com,
         DotMailer::FromAddress id: 456 email: no-reply@example.com
       ]

### Creating Campaigns

To create a dotMailer campaign, call `DotMailer::Account#create_campaign` with a hash containing the following required keys:

* `:name`               - The name of the campaign as it will appear in the web interface
* `:subject`            - The subject to use when sending the campaign
* `:from_name`          - The name which will appear in the "From" header of the sent campaign
* `:from_email`         - The email which will appear in the "From" header of the sent campaign (this must be a valid from address in the dotMailer system, see "From addresses" above)
* `:html_content`       - The content which will be included in the HTML part of the sent campaign
* `:plain_text_content` - The content which will be included in the Plain Text part of the sent campaign

For example:

    account = DotMailer::Account.new('your-api-username', 'your-api-password')

    campaign = account.create_campaign(
      :name                => 'my_campaign',
      :subject             => 'My Campaign',
      :from_name           => 'Me',
      :from_email          => 'me@example.com',
      :html_content        => '<h1>Hello!</h1><a href="http://$UNSUB$">Unsubscribe</a>',
      :plain_text_content  => "Hello!\n======\nhttp://$UNSUB$"
    )
    => DotMailer::Campaign id: 123, name: my_campaign

    campaign.subject
    => "My Campaign"

    campaign.from_address
    => DotMailer::FromAddress id: 345, email: 'me@example.com'

## License

Copyright (c) 2013 Econsultancy. Distributed under the MIT License. See LICENSE.txt for further details.
