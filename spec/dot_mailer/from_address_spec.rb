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

  its(:id)    { should == id }
  its(:email) { should == email}
end
