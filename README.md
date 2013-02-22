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

Use the `Dotmailer::Client` class to access the dotMailer REST API.

You must initialize the Client with an API user and password (see [here](http://www.dotmailer.co.uk/api/more_about_api/getting_started_with_the_api.aspx) for instructions on obtaining these):

    client = Dotmailer::Client.new('your-api-username', 'your-api-password')

Data Fields
-----------

### List

`Dotmailer::Client#get_data_fields` will return an Array of `Dotmailer::DataField` objects representing the data fields for the global address book:

    client.get_data_fields
    => [
         Dotmailer::DataField name: "FIELD1", type: "String", visibility: "Public", default: "",
         Dotmailer::DataField name: "FIELD2", type: "Numeric", visibility: "Private", default: 0
       ]

### Create

`Dotmailer::Client#create_data_field` will attempt to create a new data field. On success it returns true, on failure it raises an exception:

    client.create_data_field 'FIELD3', :type => 'String'
    => true

    client.create_data_field 'FIELD3', :type => 'String'
    => Dotmailer::DuplicateDataField
