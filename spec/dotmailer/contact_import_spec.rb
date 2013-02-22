require 'spec_helper'

describe Dotmailer::ContactImport do
  let(:client) { double 'client' }

  let(:contacts) do
    [
      { 'Email' => 'john.doe@example.com' }
    ]
  end

  subject { Dotmailer::ContactImport.new(client, contacts) }

  its(:id) { should be_nil }

  describe '#start' do
    let(:contacts_csv) { "Email\njohn.doe@example.com\n" }
    let(:id)           { double 'id' }

    before(:each) do
      client.stub :import_contacts => id
    end

    it 'should call #import_contacts on the client' do
      client.should_receive(:import_contacts).with(contacts_csv)

      subject.start
    end

    it 'should set the id' do
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
      let(:id)     { double 'id' }
      let(:status) { double 'status' }

      before(:each) do
        client.stub :import_status => status
      end

      it 'should call #import_status on the client' do
        client.should_receive(:import_status).with(id)

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
