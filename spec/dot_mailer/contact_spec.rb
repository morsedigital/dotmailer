require 'spec_helper'

describe DotMailer::Contact do
  describe 'Class' do
    let(:client) { double 'client' }

    subject { DotMailer::Contact }

    before(:each) do
      subject.stub :client => client
    end

    describe '.find_by_email' do
      let(:email)     { 'john.doe@example.com' }
      let(:response)  { double 'response' }
      let(:contact)   { double 'contact' }

      before(:each) do
        client.stub :get => response
        subject.stub :new => contact
      end

      it 'should get the contact from the client' do
        client.should_receive(:get).with("/contacts/#{email}")

        subject.find_by_email email
      end

      it 'should initialize a new Contact with the response from the client' do
        subject.should_receive(:new).with(response)

        subject.find_by_email email
      end

      it 'should return the new Contact object' do
        subject.find_by_email(email).should == contact
      end

      context 'when the contact doesnt exist' do
        before(:each) do
          client.stub(:get).and_raise(DotMailer::NotFound)
        end

        it 'should return nil' do
          subject.find_by_email(email).should be_nil
        end
      end
    end

    describe '.find_by_id' do
      let(:id)      { 123 }
      let(:contact) { double 'contact' }

      before(:each) do
        subject.stub :find_by_email => contact
      end

      it 'should call find_by_email with the id' do
        subject.should_receive(:find_by_email).with(id)

        subject.find_by_id id
      end

      it 'should return the contact from find_by_email' do
        subject.find_by_id(id).should == contact
      end
    end
  end

  let(:id)          { double 'id' }
  let(:email)       { double 'email' }
  let(:opt_in_type) { double 'opt in type' }
  let(:email_type)  { double 'email type' }
  let(:status)      { double 'status' }

  let(:attributes) do
    {
      'id'        => id,
      'email'     => email,
      'optInType' => opt_in_type,
      'emailType' => email_type,
      'status'    => status
    }
  end

  subject { DotMailer::Contact.new(attributes) }

  its(:id)          { should == id }
  its(:email)       { should == email }
  its(:opt_in_type) { should == opt_in_type }
  its(:email_type)  { should == email_type }
  its(:status)      { should == status }

  it_should_have_assignable_attributes :email, :email_type

  describe '#opt_in_type=' do
    let(:value) { 'some opt in type' }

    context 'when the opt in type exists' do
      before(:each) do
        DotMailer::OptInType.stub :exists? => true
      end

      it 'should change the opt in type' do
        expect { subject.opt_in_type = value }.to \
          change { subject.opt_in_type }.to(value)
      end
    end

    context 'when the opt in type doesnt exist' do
      before(:each) do
        DotMailer::OptInType.stub :exists? => false
      end

      it 'should raise an UnknownOptInType error with the value' do
        expect { subject.opt_in_type = value }.to \
          raise_error(DotMailer::UnknownOptInType, value)
      end
    end
  end

  describe '#[]' do
    let(:data_fields) { {} }

    before(:each) do
      subject.stub :data_fields => data_fields
    end

    context 'when the data field doesnt exist' do
      let(:key) { 'UNKNOWN' }

      it 'should raise an UnknownDataField error' do
        expect { subject[key] }.to raise_error(DotMailer::UnknownDataField)
      end
    end

    context 'when the data field does exist' do
      let(:key)         { double 'key' }
      let(:value)       { double 'value' }
      let(:data_fields) { { key => value } }

      specify { subject[key].should == value }
    end
  end

  describe '#[]=' do
    let(:new_value) { double 'new value' }

    let(:data_fields) { {} }

    before(:each) do
      subject.stub :data_fields => data_fields
    end

    context 'when the data field doesnt exist' do
      let(:key) { 'UNKNOWN' }

      it 'should raise an UnknownDataField error' do
        expect { subject[key] = new_value }.to raise_error(DotMailer::UnknownDataField)
      end
    end

    context 'when the data field does exist' do
      let(:key)         { double 'key' }
      let(:old_value)   { double 'old value' }
      let(:data_fields) { { key => old_value } }

      specify do
        expect { subject[key] = new_value }.to \
          change { subject[key] }.from(old_value).to(new_value)
      end
    end
  end

  describe '#save' do
    let(:id)          { '12345' }
    let(:key)         { double 'key' }
    let(:value)       { 'some value' }
    let(:data_fields) { { key => value } }
    let(:client)      { double 'client' }

    before(:each) do
      client.stub :put_json
      subject.stub :client => client, :data_fields => data_fields
    end

    it 'should call put_json on the client with the id path' do
      client.should_receive(:put_json).with("/contacts/#{id}", anything)

      subject.save
    end

    it 'should call put_json on the client with the attributes in the correct format' do
      client.should_receive(:put_json).with(anything, {
        'id'         => id,
        'email'      => email,
        'optInType'  => opt_in_type,
        'emailType'  => email_type,
        'status'     => status,
        'dataFields' => [
          { 'key' => key, 'value' => value }
        ]
      })

      subject.save
    end

    it 'should return true' do
      subject.save.should == true
    end
  end
end
