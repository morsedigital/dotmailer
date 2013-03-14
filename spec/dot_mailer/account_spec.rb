require 'spec_helper'

describe DotMailer::Account do
  let(:api_user) { double 'api user' }
  let(:api_pass) { double 'api pass' }
  let(:client)   { double 'client' }

  subject { DotMailer::Account.new(api_user, api_pass) }

  before(:each) do
    subject.stub :client => client
  end

  describe '#initialize' do
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

  describe '#suppress' do
    let(:email) { double 'email' }

    before(:each) do
      client.stub :post_json
    end

    it 'should call post_json on the client with the correct path' do
      client.should_receive(:post_json).with('/contacts/unsubscribe', anything)

      subject.suppress email
    end

    it 'should call post_json on the client with the email address' do
      client.should_receive(:post_json).with(anything, 'Email' => email)

      subject.suppress email
    end
  end
end
