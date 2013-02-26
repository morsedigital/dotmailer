require 'spec_helper'

describe DotMailer::DataField do
  describe 'Class' do
    let(:client)  { double 'client' }
    let(:account) { double 'account', :client => client }

    subject { DotMailer::DataField }

    describe '.all' do
      let(:data_fields) {
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
      }

      before(:each) do
        client.stub :get => data_fields
      end

      it 'should get the fields from the client' do
        client.should_receive(:get).with('/data-fields')

        subject.all account
      end

      it 'should return a list of DataFields from the client' do
        subject.all(account).should == data_fields.map { |df| subject.new(df) }
      end
    end

    describe '.create' do
      let(:name) { 'FIRSTNAME' }

      let(:data_field) do
        {
          'name'         => name,
          'type'         => 'String',
          'visibility'   => 'Public',
          'defaultValue' => nil
        }
      end

      before(:each) do
        client.stub :post_json => data_field
      end

      it 'should call post_json on the client with the field' do
        client.should_receive(:post_json).with('/data-fields', data_field)

        subject.create account, name
      end

      it 'should return true' do
        subject.create(account, name).should == true
      end
    end
  end

  let(:name)       { 'FIRSTNAME' }
  let(:type)       { 'String' }
  let(:visibility) { 'Public' }
  let(:default)    { 'John' }

  let(:attributes) do
    {
      'name'         => name,
      'type'         => type,
      'visibility'   => visibility,
      'defaultValue' => default
    }
  end

  subject { DotMailer::DataField.new(attributes) }

  its(:name)       { should == name }
  its(:type)       { should == type }
  its(:visibility) { should == visibility }
  its(:default)    { should == default }

  its(:to_s) { should == 'DotMailer::DataField name: "FIRSTNAME", type: "String", visibility: "Public", default: "John"' }

  its(:to_json) { should == attributes.to_json }

  describe '#==' do
    specify { subject.should == DotMailer::DataField.new(attributes) }
  end

  describe '#date?' do
    context 'when type is "Date"' do
      let(:type) { 'Date' }

      specify { subject.should be_date }
    end

    context 'when type is not "Date"' do
      let(:type) { 'String' }

      specify { subject.should_not be_date }
    end
  end
end
