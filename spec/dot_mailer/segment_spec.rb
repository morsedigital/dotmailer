require 'spec_helper'

describe DotMailer::Segment do
  let(:client)  { double 'client' }
  let(:account) { double 'account', :client => client }
  let(:id)       { 123 }

  describe 'Class' do
    subject { DotMailer::Segment }

    describe '.find_by_id' do

      let(:response) { [
        { "id"=>121, "name"=>"Segment A", "contacts"=>0 },
        { "id"=>id,  "name"=>"Segment B", "contacts"=>1 }
      ] }

      let(:segment) { double 'segment' }

      before(:each) do
        subject.stub :new => segment
        client.stub :get => response
      end

      it 'should call get on the client with the correct parameters' do
        client.should_receive(:get).with("/segments")

        subject.find_by_id(account, id)
      end

      it 'should initialize a Segement with the response' do
        subject.should_receive(:new).with(account, response[1])

        subject.find_by_id(account, id)
      end

      it 'should return the new Segement object' do
        subject.find_by_id(account, id).should == segment
      end
    end
  end

  describe '.refresh' do
  end

  describe '.refresh_progress' do
  end
end