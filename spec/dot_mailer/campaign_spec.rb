require 'spec_helper'

describe DotMailer::Campaign do
  let(:client)  { double 'client' }
  let(:account) { double 'account', :client => client }

  let(:id)                 { 123 }
  let(:name)               { 'my_campaign' }
  let(:campaign_subject)   { 'My Campaign' }
  let(:from_name)          { 'Me' }
  let(:from_email)         { 'me@example.com' }
  let(:html_content)       { '<h1>Hello!</h1><a href="http://$UNSUB$">Unsubscribe</a>' }
  let(:plain_text_content) { "Hello!\n======\nhttp://$UNSUB$" }

  let(:from_address) do
    DotMailer::FromAddress.new 'id' => 123, 'email' => from_email
  end

  subject do
    DotMailer::Campaign.new(account, {
      'id'               => id,
      'name'             => name,
      'subject'          => campaign_subject,
      'fromName'         => from_name,
      'fromAddress'      => from_address.to_hash,
      'htmlContent'      => html_content,
      'plainTextContent' => plain_text_content
    })
  end

  describe 'Class' do
    subject { DotMailer::Campaign }

    describe '.create' do
      let(:response) { double 'response' }
      let(:campaign) { double 'campaign' }

      # We define a method so we can override keys within
      # context blocks without redefining other keys
      def attributes
        {
          :name               => name,
          :subject            => campaign_subject,
          :from_name          => from_name,
          :from_email         => from_email,
          :html_content       => html_content,
          :plain_text_content => plain_text_content
        }
      end

      before(:each) do
        account.stub :from_addresses => [from_address]
        client.stub :post_json => response
        subject.stub :new => campaign
      end

      [
        :name,
        :subject,
        :from_name,
        :from_email,
        :html_content,
        :plain_text_content
      ].each do |attribute|
        context "without specifying #{attribute}" do
          define_method :attributes do
            super().except(attribute)
          end

          it 'should raise an error' do
            expect { subject.create(account, attributes) }.to \
              raise_error(RuntimeError, "missing :#{attribute}")
          end
        end
      end

      context 'when the fromAddress is not a valid from address' do
        let(:unknown_email) { 'unknown@example.com' }

        def attributes
          super.merge(:from_email => unknown_email)
        end

        it 'should raise an error' do
          expect { subject.create(account, attributes) }.to \
            raise_error(DotMailer::InvalidFromAddress, unknown_email)
        end
      end

      it 'should call post_json on the client with the correct path' do
        client.should_receive(:post_json).with('/campaigns', anything)

        subject.create(account, attributes)
      end

      it 'should call post_json on the client with the correct parameters' do
        client.should_receive(:post_json).with(anything, {
          'Name'             => name,
          'Subject'          => campaign_subject,
          'FromName'         => from_name,
          'FromAddress'      => from_address.to_hash,
          'HtmlContent'      => html_content,
          'PlainTextContent' => plain_text_content
        })

        subject.create(account, attributes)
      end

      it 'should instantiate a new Campaign object with the account and response' do
        subject.should_receive(:new).with(account, response)

        subject.create(account, attributes)
      end

      it 'should return the new Campaign object' do
        subject.create(account, attributes).should == campaign
      end
    end

    describe '.find_by_id' do
      let(:id)       { 123 }
      let(:response) { double 'response' }
      let(:campaign) { double 'campaign' }

      before(:each) do
        subject.stub :new => campaign
        client.stub :get => response
      end

      it 'should call get on the client with the correct parameters' do
        client.should_receive(:get).with("/campaigns/#{id}")

        subject.find_by_id(account, id)
      end

      it 'should initialize a Campaign with the response' do
        subject.should_receive(:new).with(account, response)

        subject.find_by_id(account, id)
      end

      it 'should return the new Campaign object' do
        subject.find_by_id(account, id).should == campaign
      end
    end
  end

  its(:id)                 { should == id }
  its(:name)               { should == name }
  its(:from_name)          { should == from_name }
  its(:from_address)       { should == from_address }
  its(:html_content)       { should == html_content }
  its(:plain_text_content) { should == plain_text_content }

  describe '#send_to_contact_ids' do
    let(:contact_ids) { double 'contact ids' }

    it 'should call post_json on the client with the correct path' do
      client.should_receive(:post_json).with('/campaigns/send', anything)

      subject.send_to_contact_ids contact_ids
    end

    it 'should call post_json on the client with the contact ids' do
      client.should_receive(:post_json).with(anything, {
        'campaignId' => id,
        'contactIds' => contact_ids
      })

      subject.send_to_contact_ids contact_ids
    end
  end
end
