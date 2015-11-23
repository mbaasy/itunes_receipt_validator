##
# ItunesReceiptValidator
module ItunesReceiptValidator
  ##
  # ItunesReceiptValidator::Receipt
  class Remote
    PRODUCTION_ENDPOINT = 'https://buy.itunes.apple.com/verifyReceipt'
    SANDBOX_ENDPOINT = 'https://sandbox.itunes.apple.com/verifyReceipt'

    attr_reader :receipt, :sandbox, :shared_secret, :options

    def initialize(receipt, options = {})
      @receipt = receipt
      @sandbox = options.fetch(:sandbox)
      @shared_secret = options.fetch(:shared_secret)
      @options = options
    end

    def status
      json[:status].to_i
    end

    def valid?
      status == 0
    end

    def expired?
      status == 21_006
    end

    def json
      @json ||= JSON.parse(response.body, symbolize_names: true)
    end

    private

    def response
      @response ||= HTTParty.post(
        sandbox ? SANDBOX_ENDPOINT : PRODUCTION_ENDPOINT,
        options.merge(payload)
      )
    end

    def payload
      {
        headers: {
          'Accept' => 'application/json',
          'Content-Type' => 'application/json'
        },
        body: {
          'password' => shared_secret,
          'receipt-data' => receipt
        }.to_json
      }
    end
  end
end
