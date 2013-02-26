require 'spec_helper'

describe DotMailer::Account do
  let(:api_user) { double 'api user' }
  let(:api_pass) { double 'api pass' }

  describe '#initialize' do
    let(:client) { double 'client' }

    before(:each) do
      DotMailer::Client.stub :new => client
    end

    it 'should initialize a Client with the credentials' do
      DotMailer::Client.should_receive(:new).with(api_user, api_pass)

      DotMailer::Account.new(api_user, api_pass)
    end

    it 'should set the client' do
      DotMailer::Client.should_receive(:new).with(api_user, api_pass)

      account = DotMailer::Account.new(api_user, api_pass)
    end
  end
end
