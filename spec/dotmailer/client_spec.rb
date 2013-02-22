require 'spec_helper'

describe Dotmailer::Client do
  let(:api_user) { 'john_doe' }
  let(:api_pass) { 's3cr3t' }
  let(:api_base_url) { "https://#{api_user}:#{api_pass}@api.dotmailer.com" }

  subject { Dotmailer::Client.new(api_user, api_pass) }

  context 'data fields' do
    let(:data_fields_endpoint) do
      "#{api_base_url}/v2/data-fields"
    end

    describe '#get_data_fields' do
      let(:data_fields) do
        [
          Dotmailer::DataField.new(
            'name'         => 'FIRSTNAME',
            'type'         => 'String',
            'visibility'   => 'Public',
            'defaultValue' => 'John'
          ),
          Dotmailer::DataField.new(
            'name'         => 'CODE',
            'type'         => 'String',
            'visibility'   => 'Private',
            'defaultValue' => nil
          )
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

    describe '#create_data_field' do
      let(:name) { 'FIRSTNAME' }

      let(:data_field_json) do
        {
          'name'         => name,
          'type'         => 'String',
          'visibility'   => 'Public',
          'defaultValue' => nil
        }.to_json
      end

      before(:each) do
        stub_request(:post, data_fields_endpoint).to_return(:body => data_field_json)
      end

      it 'should post the field to the data fields endpoint' do
        subject.create_data_field name

        WebMock.should have_requested(:post, data_fields_endpoint).with(
          :body    => data_field_json,
          :headers => {
            'Accept'       => 'application/json',
            'Content-Type' => 'application/json'
          }
        )
      end

      context 'when the field doesnt exist' do
        it 'should return true' do
          subject.create_data_field(name).should == true
        end
      end

      context 'when the field already exists' do
        before(:each) do
          stub_request(:post, data_fields_endpoint).to_return(:status => 400)
        end

        it 'should raise an error' do
          expect { subject.create_data_field(name) }.to raise_error(Dotmailer::DuplicateDataField)
        end
      end
    end
  end
end
