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

`Dotmailer.data_fields` will return an Array of `Dotmailer::DataField` objects representing the data fields for the global address book:

    Dotmailer.data_fields
    => [
         Dotmailer::DataField name: "FIELD1", type: "String", visibility: "Public", default: "",
         Dotmailer::DataField name: "FIELD2", type: "Numeric", visibility: "Private", default: 0
       ]

### Create

`Dotmailer.create_data_field` will attempt to create a new data field. On success it returns true, on failure it raises an exception:

    Dotmailer.create_data_field 'FIELD3', :type => 'String'
    => true

    Dotmailer.create_data_field 'FIELD3', :type => 'String'
    => Dotmailer::DuplicateDataField

Contacts
--------

### Bulk Import

`Dotmailer.import_contacts` will start a batch import of contacts into the global address book, and return a `Dotmailer::ContactImport` object which has a `status`:

    import = Dotmailer.import_contacts [
      { 'Email' => 'joe@example.com' },
      { 'Email' => 'sue@example.com' },
      { 'Email' => 'bob@example.com' }
    ]
    => Dotmailer::ContactImport contacts: [{"Email"=>"joe@example.com" }, {"Email"=>"sue@example.com" }, {"Email"=>"bob@example.com"}]

    import.finished?
    => false
    import.status
    => "NotFinished"

Then, once the import has finished:

    import.finished?
    => true
    import.status
    => "Finished"
