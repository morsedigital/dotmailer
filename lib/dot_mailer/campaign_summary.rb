module DotMailer
  class CampaignSummary
    %w(
    numUniqueOpens
    numUniqueTextOpens
    numTotalUniqueOpens
    numOpens
    numTextOpens
    numTotalOpens
    numClicks
    numTextClicks
    numTotalClicks
    numPageViews
    numTotalPageViews
    numTextPageViews
    numForwards
    numTextForwardsge
    numEstimatedForwards
    numTextEstimatedForwards
    numTotalEstimatedForwards
    numReplies
    numTextReplies
    numTotalReplies
    numHardBounces
    numTextHardBounces
    numTotalHardBounces
    numSoftBounces
    numTextSoftBounces
    numTotalSoftBounces
    numUnsubscribes
    numTextUnsubscribes
    numTotalUnsubscribes
    numIspComplaints
    numTextIspComplaints
    numTotalIspComplaints
    numMailBlocks
    numTextMailBlocks
    numTotalMailBlocks
    numSent
    numTextSent
    numTotalSent
    numRecipientsClicked
    numDelivered
    numTextDelivered
    numTotalDelivered
    percentageDelivered
    percentageUniqueOpens
    percentageOpens
    percentageUnsubscribes
    percentageReplies
    percentageHardBounces
    percentageSoftBounces
    percentageUsersClicked
    percentageClicksToOpens
    ).each do |meth|
      define_method(meth.underscore) do
        @params[meth]
      end
    end

    def date_sent
      Time.parse(@params["dateSent"])
    end

    def initialize(account, id)
      @params = account.client.get "/campaigns/#{id.to_s}/summary"
    end
    #
    # def method_missing(name, *args, &block)
    #   @params[name.classify]
    # end
  end
end

