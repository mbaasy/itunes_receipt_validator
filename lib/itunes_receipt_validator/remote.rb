##
# ItunesReceiptValidator
module ItunesReceiptValidator
  ##
  # ItunesReceiptValidator::Receipt
  class Remote
    PRODUCTION_ENDPOINT = 'https://buy.itunes.apple.com/verifyReceipt'
    SANDBOX_ENDPOINT = 'https://sandbox.itunes.apple.com/verifyReceipt'

    attr_reader :decoded, :options

    def initialize(decoded, options = {})
      @decoded = decoded
      @options = options
    end

    def response
      @response ||= HTTParty.post(
        decoded.sandbox? ? SANDBOX_ENDPOINT : PRODUCTION_ENDPOINT,
        options.merge(payload)
      )
    end

    def normalized

    end

    private

    def payload
      {
        headers: {
          'Accept' => 'application/json',
          'Content-Type' => 'application/json'
        },
        body: {
          'password' => options.fetch(:shared_secret),
          'receipt-data' => decoded.receipt
        }.to_json
      }
    end
  end
end
