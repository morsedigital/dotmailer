require 'spec_helper'

describe Dotmailer::DataField do
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

  subject { Dotmailer::DataField.new(attributes) }

  its(:name)       { should == name }
  its(:type)       { should == type }
  its(:visibility) { should == visibility }
  its(:default)    { should == default }

  its(:to_s) { should == 'Dotmailer::DataField name: "FIRSTNAME", type: "String", visibility: "Public", default: "John"' }

  its(:to_json) { should == attributes.to_json }

  describe '#==' do
    specify { subject.should == Dotmailer::DataField.new(attributes) }
  end
end
