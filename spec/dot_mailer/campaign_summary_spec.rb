require 'spec_helper'

describe DotMailer::CampaignSummary do
  let(:client)  { double 'client' }
  let(:account) { double 'account', :client => client }
  let(:response) {{
    "dateSent"     => '2013-07-30T16:01:21.603Z',
    "numTotalSent" => '123',
    "percentageDelivered" => '95.8'
  }}

  subject do
    client.should_receive(:get).with("/campaigns/1/summary").and_return(response)
    DotMailer::CampaignSummary.new(account, 1)
  end

  specify { subject.date_sent.should eq(Time.parse('2013-07-30T16:01:21.603Z')) }
  specify { subject.num_total_sent.should eq(123) }
  specify { subject.percentage_delivered.should eq(95.8) }
end
