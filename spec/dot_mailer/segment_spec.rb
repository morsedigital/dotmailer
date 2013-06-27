require 'spec_helper'

describe DotMailer::Segment do
  let(:client)  { double 'client' }
  let(:account) { double 'account', :client => client }
  let(:id)       { 123 }

  subject do
    DotMailer::Segment.new(account, { 'id' => id } )
  end

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

  describe '.refresh!' do
    let(:response) { double 'response' }
    let(:segment) { double 'segment' }

    before(:each) do
      subject.stub :new => segment
    end

    it 'should call post on the client with the correct parameters' do
      client.should_receive(:post_json).with("/segments/refresh/#{id}",{})

      subject.refresh!
    end
  end

  describe '.refresh_progress' do
    let(:status) { double 'status'}
    let(:response) { {"id" => id, "status" => status} }

    before(:each) do
      client.stub :get => response
    end

    it 'should call get on the client with the correct parameters' do
      client.should_receive(:get).with("/segments/refresh/#{id}")

      subject.refresh_progress
    end

    it 'should return a percentage complete' do
      subject.refresh_progress.should == status
    end
  end
end
