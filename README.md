dotMailer
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

To use the dotMailer API, you will need to add your API username and password to your shell environment:

    export DOTMAILER_USER=your-api-username
    export DOTMAILER_PASS=your-api-password

(You can put these in your `~/.bashrc` or `~/.profile` to load them on login).

For instructions on how to obtain your API username and password, see [here](http://www.dotmailer.co.uk/api/more_about_api/getting_started_with_the_api.aspx).

Data Fields
-----------

### List

`DotMailer.data_fields` will return an Array of `DotMailer::DataField` objects representing the data fields for the global address book:

    DotMailer.data_fields
    => [
         DotMailer::DataField name: "FIELD1", type: "String", visibility: "Public", default: "",
         DotMailer::DataField name: "FIELD2", type: "Numeric", visibility: "Private", default: 0
       ]

### Create

`DotMailer.create_data_field` will attempt to create a new data field. On success it returns true, on failure it raises an exception:

    DotMailer.create_data_field 'FIELD3', :type => 'String'
    => true

    DotMailer.create_data_field 'FIELD3', :type => 'String'
    => DotMailer::DuplicateDataField

Contacts
--------

### Finding A Contact

There are two ways to find contacts via the API, using a contact's email address or id.

The gem provides two methods for doing so: `DotMailer.find_contact_by_email` and `DotMailer.find_contact_by_id`.

Suppose you have one contact with email john@example.com and id 12345, then:

    DotMailer.find_contact_by_email 'john@example.com'
    => DotMailer::Contact id: 12345, email: john@example.com

    DotMailer.find_contact_by_email 'sue@example.com'
    => nil

    DotMailer.find_contact_by_id 12345
    => DotMailer::Contact id: 12345, email: john@example.com

    DotMailer.find_contact_by_id 54321
    => nil

### Updating a contact

Contacts can be updated by assigning new values and calling `DotMailer::Contact#save`:

    contact = DotMailer.find_contact_by_email 'john@example.com'
    => DotMailer::Contact id: 12345, email: john@example.com, email_type: Html

    contact.email_type
    => 'Html'
    contact.email_type = 'PlainText'
    => 'PlainText

    contact.save
    => true

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
    => true

Then, once the contact has gone through the resubscribe process and been redirected to the specified URL:

    contact = DotMailer.find_contact_by_email 'john@example.com'
    => DotMailer::Contact id: 12345, email: john@example.com, status: Subscribed

    contact.subscribed?
    => true

### Bulk Import

`DotMailer.import_contacts` will start a batch import of contacts into the global address book, and return a `DotMailer::ContactImport` object which has a `status`:

    import = DotMailer.import_contacts [
      { 'Email' => 'joe@example.com' },
      { 'Email' => 'sue@example.com' },
      { 'Email' => 'bob@example.com' }
    ]
    => DotMailer::ContactImport contacts: [{"Email"=>"joe@example.com" }, {"Email"=>"sue@example.com" }, {"Email"=>"bob@example.com"}]

    import.finished?
    => false
    import.status
    => "NotFinished"

Then, once the import has finished:

    import.finished?
    => true
    import.status
    => "Finished"
