require 'spec_helper'

describe DotMailer::ContactImport do
  let(:client)  { double 'client' }
  let(:account) { double 'account', :client => client }

  let(:contacts) do
    [
      { 'Email' => 'john.doe@example.com' }
    ]
  end

  describe 'Class' do
    subject { DotMailer::ContactImport }

    describe '.import' do
      let(:contact_import) { double 'contact import', :start => double }

      before(:each) do
        subject.stub :new => contact_import
      end

      it 'should create a new instance with the account and contacts' do
        subject.should_receive(:new).with(account, contacts)

        subject.import account, contacts
      end

      it 'should start the new contact import' do
        contact_import.should_receive :start

        subject.import account, contacts
      end

      it 'should return the contact import' do
        subject.import(account, contacts).should == contact_import
      end
    end
  end

  subject { DotMailer::ContactImport.new(account, contacts) }

  its(:id) { should be_nil }

  describe '#start' do
    let(:contacts_csv) { "Email\njohn.doe@example.com\n" }
    let(:id)           { double 'id' }
    let(:response)     { { 'id' => id, 'status' => 'NotFinished' } }

    before(:each) do
      client.stub :post_csv => response
    end

    it 'should call post_csv on the client with the contacts in CSV format' do
      client.should_receive(:post_csv).with('/contacts/import', contacts_csv)

      subject.start
    end

    it 'should set the id from the response' do
      subject.start
      subject.id.should == id
    end
  end

  describe '#status' do
    before(:each) do
      subject.stub :id => id
    end

    context 'when the import has not started' do
      let(:id) { nil }

      its(:status) { should == 'NotStarted' }
    end

    context 'when the import has started' do
      let(:id)       { '12345' }
      let(:status)   { double 'status' }
      let(:response) { { 'id' => id, 'status' => status } }

      before(:each) do
        client.stub :get => response
      end

      it 'should get the status from the client' do
        client.should_receive(:get).with("/contacts/import/#{id}")

        subject.status
      end

      it 'should return the status from the client' do
        subject.status.should == status
      end
    end
  end

  describe '#finished?' do
    context 'when the import status is not "Finished"' do
      before(:each) do
        subject.stub :status => 'NotFinished'
      end

      specify { subject.should_not be_finished }
    end

    context 'when the import status is "Finished"' do
      before(:each) do
        subject.stub :status => 'Finished'
      end

      specify { subject.should be_finished }
    end
  end
end
