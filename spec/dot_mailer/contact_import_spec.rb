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
      let(:wait_for_finish) { false }

      before(:each) do
        subject.stub :new => contact_import
      end

      it 'should create a new instance with the account and contacts' do
        subject.should_receive(:new).with(account, contacts)

        subject.import account, contacts, wait_for_finish
      end

      it 'should start the new contact import' do
        contact_import.should_receive :start

        subject.import account, contacts, wait_for_finish
      end

      it 'should return the contact import' do
        subject.import(account, contacts, wait_for_finish).should == contact_import
      end
    end
  end

  subject { DotMailer::ContactImport.new(account, contacts) }

  its(:id) { should be_nil }

  describe '#start' do
    before(:each) do
      account.stub :data_fields => [double('data field', :name => 'CODE')]
    end
    let(:wait_for_finish) { false }

    context 'when the contacts include a non existent data field' do
      let(:data_field_name) { 'UNKNOWN' }

      let(:contacts) do
        [
          { 'Email' => 'john.doe@example.com', data_field_name => 'some value' }
        ]
      end

      it 'should raise an UnknownDataField error with the data field name' do
        expect { subject.start(wait_for_finish) }.to raise_error(DotMailer::UnknownDataField, data_field_name)
      end
    end

    let(:contacts_csv) { "Email\njohn.doe@example.com\n" }
    let(:id)           { double 'id' }
    let(:response)     { { 'id' => id, 'status' => 'NotFinished' } }

    before(:each) do
      client.stub :post_csv => response
    end

    it 'should call post_csv on the client with the contacts in CSV format' do
      client.should_receive(:post_csv).with('/contacts/import', contacts_csv)

      subject.start(wait_for_finish)
    end

    it 'should set the id from the response' do
      subject.start(wait_for_finish)
      subject.id.should == id
    end

    context "with a wait_for_finish request" do
      let(:wait_for_finish) { true }

      it "should call the blocking wait_for_finish method" do
        subject.should_receive(:wait_until_finished)

        subject.start wait_for_finish
      end
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
    context 'when the import status is "NotFinished"' do
      before(:each) do
        subject.stub :status => 'NotFinished'
      end

      specify { subject.should_not be_finished }
    end

    context 'when the import status is not "NotFinished"' do
      before(:each) do
        subject.stub :status => 'RejectedByWatchdog'
      end

      specify { subject.should be_finished }
    end
  end

  describe '#errors' do
    let(:id) { '12345' }

    before(:each) do
      subject.stub :id => id
    end

    context 'when the import has no yet finished' do
      before(:each) do
        subject.stub :finished? => false
      end

      it 'should raise an ImportNotFinished error' do
        expect { subject.errors }.to raise_error(DotMailer::ImportNotFinished)
      end
    end

    context 'when the import has finished' do
      before(:each) do
        subject.stub :finished? => true
      end

      let(:errors) { double 'errors' }

      before(:each) do
        client.stub :get_csv => errors
      end

      it 'should call get_csv on the client with the import id in the path' do
        client.should_receive(:get_csv).with("/contacts/import/#{id}/report-faults")

        subject.errors
      end

      it 'should return the status from the client' do
        subject.errors.should == errors
      end
    end
  end

  describe '#wait_for_finish' do
    before { subject.stub(:sleep).and_return(1) }

    it "returns when finished is true" do
      subject.should_receive(:finished?).once.and_return(true)

      subject.send(:wait_until_finished)
    end

    it "returns nil when batch finished within max tries" do
      subject.stub(:finished? => true)

      subject.send(:wait_until_finished).should be_nil
    end

    it "sleeps between each call to finished" do
      subject.stub(:finished? => true)
      subject.should_receive(:sleep).once.with(1).and_return(true)

      subject.send(:wait_until_finished)
    end

    it "raises an error when not finished within max tries" do
      subject.should_receive(:finished?).exactly(10).times.and_return(false)

      expect { subject.send(:wait_until_finished) }.to raise_error(DotMailer::ImportNotFinished)
    end
  end
end
