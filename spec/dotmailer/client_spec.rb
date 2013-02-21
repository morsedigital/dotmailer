require 'spec_helper'

describe Dotmailer::Client do
  let(:api_user) { 'john_doe' }
  let(:api_pass) { 's3cr3t' }

  subject { Dotmailer::Client.new(api_user, api_pass) }

  context 'data fields' do
    let(:data_fields_endpoint) do
      "https://#{api_user}:#{api_pass}@api.dotmailer.com/v2/data-fields"
    end

    describe '#get_data_fields' do
      let(:data_fields) do
        [
          {
            'name'         => 'FIRSTNAME',
            'type'         => 'String',
            'visibility'   => 'Public',
            'defaultValue' => 'John'
          },
          {
            'name'         => 'CODE',
            'type'         => 'String',
            'visibility'   => 'Private',
            'defaultValue' => nil
          }
        ]
      end

      before(:each) do
        stub_request(:get, data_fields_endpoint).to_return(:body => data_fields.to_json)
      end

      it 'should get the fields from the data fields endpoint' do
        subject.get_data_fields

        WebMock.should have_requested(:get, data_fields_endpoint).with(
          :headers => { 'Accept' => 'application/json' }
        )
      end

      it 'should return the data fields from the data fields endpoint' do
        subject.get_data_fields.should == data_fields
      end
    end
  end
end
