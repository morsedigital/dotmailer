require 'spec_helper'

describe DotMailer::FromAddress do
  let(:id)    { double 'id' }
  let(:email) { double 'email' }

  let(:attributes) do
    {
      'id'    => id,
      'email' => email
    }
  end

  subject { DotMailer::FromAddress.new(attributes) }

  its(:id)      { should == id }
  its(:email)   { should == email}
  its(:to_hash) { should == attributes }

  describe '#==' do
    it 'should equal a from address with the same attributes' do
      subject.should == DotMailer::FromAddress.new(attributes)
    end
  end
end
