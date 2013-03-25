require 'spec_helper'

describe DotMailer::Suppression do
  let(:account)       { double 'account' }
  let(:attributes)    { double 'attributes' }
  let(:date_removed)  { '2013-03-01T15:30:45Z' }
  let(:reason)        { double 'reason' }
  let(:contact)       { double 'contact' }

  subject do
    DotMailer::Suppression.new(
      account,
      'suppressedContact' => attributes,
      'dateRemoved'       => date_removed,
      'reason'            => reason
    )
  end

  before(:each) do
    DotMailer::Contact.stub(:new).with(account, attributes).and_return(contact)
  end

  its(:contact)      { should == contact }
  its(:date_removed) { should == Time.parse('1st March 2013 15:30:45 +00:00') }
  its(:reason)       { should == reason }
end
