require 'spec_helper'

describe DotMailer::Suppression do
  let(:client)             { double 'client' }
  let(:account)            { double 'account', :client => client }
  let(:contact_attributes) { double 'contact attributes' }
  let(:date_removed)       { '2013-03-01T15:30:45Z' }
  let(:reason)             { double 'reason' }
  let(:contact)            { double 'contact' }

  subject do
    DotMailer::Suppression.new(
      account,
      'suppressedContact' => contact_attributes,
      'dateRemoved'       => date_removed,
      'reason'            => reason
    )
  end

  before(:each) do
    DotMailer::Contact.stub(:new).with(account, contact_attributes).and_return(contact)
  end

  its(:contact)      { should == contact }
  its(:date_removed) { should == Time.parse('1st March 2013 16:30:45 +01:00') }
  its(:reason)       { should == reason }

  describe 'Class' do
    subject { DotMailer::Suppression }

    describe '.suppressed_since' do
      let(:time)        { Time.parse('1st February 2013 16:30:45 +01:00') }
      let(:suppression) { double 'suppression' }

      let(:attributes) do
        {
          'suppressedContact' => contact_attributes,
          'dateRemoved'       => date_removed,
          'reason'            => reason
        }
      end

      let(:response) { 3.times.map { attributes } }

      before(:each) do
        client.stub :get => response
        subject.stub :new => suppression
      end

      it 'should call get on the client with a path containing the time in UTC XML schema format' do
        client.should_receive(:get).with('/contacts/suppressed-since/2013-02-01T15:30:45Z')

        subject.suppressed_since(account, time)
      end

      it 'should initialize some suppressions' do
        subject.should_receive(:new).exactly(3).times.with(account, attributes)

        subject.suppressed_since(account, time)
      end

      it 'should return the suppressions' do
        subject.suppressed_since(account, time).should == 3.times.map { suppression }
      end
    end
  end
end
