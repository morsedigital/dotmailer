require 'spec_helper'

describe DotMailer::Client do
  let(:api_user)      { 'john_doe' }
  let(:api_pass)      { 's3cr3t' }
  let(:api_base_url)  { "https://#{api_user}:#{api_pass}@api.dotmailer.com" }
  let(:api_path)      { '/some/api/path' }
  let(:api_endpoint)  { "#{api_base_url}/v2#{api_path}" }

  subject { DotMailer::Client.new(api_user, api_pass) }

  describe '#get' do
    let(:response) { { 'foo' => 'bar' } }

    before(:each) do
      stub_request(:get, api_endpoint).to_return(:body => response.to_json)
    end

    it 'should GET the endpoint with a JSON accept header' do
      subject.get api_path

      WebMock.should have_requested(:get, api_endpoint).with(
        :headers => { 'Accept' => 'application/json' }
      )
    end

    it 'should return the response from the endpoint' do
      subject.get(api_path).should == response
    end

    context 'when the path is not found' do
      let(:error_message) { 'not found' }
      let(:response)      { { 'message' => error_message } }

      before(:each) do
        stub_request(:get, api_endpoint).to_return(:status => 404, :body => response.to_json)
      end

      it 'should raise a NotFound error with the error message' do
        expect { subject.get(api_path).should }.to raise_error(DotMailer::NotFound, error_message)
      end
    end
  end

  describe '#post' do
    let(:data)     { 'some random data' }
    let(:response) { { 'foo' => 'bar' } }

    before(:each) do
      stub_request(:post, api_endpoint).to_return(:body => response.to_json)
    end

    it 'should POST the data to the endpoint with a JSON accept header' do
      subject.post api_path, data

      WebMock.should have_requested(:post, api_endpoint).with(
        :headers => { 'Accept' => 'application/json' },
        :body    => data
      )
    end

    it 'should return the response from the endpoint' do
      subject.post(api_path, data).should == response
    end

    context 'when the data is invalid for the endpoint' do
      let(:error_message) { 'invalid data' }
      let(:response)      { { 'message' => error_message } }

      before(:each) do
        stub_request(:post, api_endpoint).to_return(:status => 400, :body => response.to_json)
      end

      it 'should raise an InvalidRequest error with the error message' do
        expect { subject.post(api_path, data) }.to raise_error(DotMailer::InvalidRequest, error_message)
      end
    end
  end

  describe '#post_json' do
    let(:params) { { 'foo' => 'bar' } }

    it 'should call post with the path' do
      subject.should_receive(:post).with(api_path, anything, anything)

      subject.post_json api_path, params
    end

    it 'should convert the params to JSON' do
      subject.should_receive(:post).with(anything, params.to_json, anything)

      subject.post_json api_path, params
    end

    it 'should pass use the correct content type' do
      subject.should_receive(:post).with(anything, anything, hash_including(:content_type => :json))

      subject.post_json api_path, params
    end
  end

  describe '#post_csv' do
    let(:csv)      { "Some\nCSV\nString" }
    let(:tempfile) { double 'tempfile', :write => true, :rewind => true }

    before(:each) do
      Tempfile.stub :new => tempfile
      subject.stub :post => double
    end

    it 'should call post with the path' do
      subject.should_receive(:post).with(api_path, anything)

      subject.post_csv api_path, csv
    end

    it 'should create a Tempfile with the contents and rewind it' do
      Tempfile.should_receive(:new).and_return(tempfile)
      tempfile.should_receive(:write).with(csv)
      tempfile.should_receive(:rewind)

      subject.post_csv api_path, csv
    end

    it 'should call post with the tempfile' do
      subject.should_receive(:post).with(api_path, hash_including(:csv => tempfile))

      subject.post_csv api_path, csv
    end
  end
end
