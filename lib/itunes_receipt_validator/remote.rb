require 'json'
require 'uri'
require 'net/https'

##
# ItunesReceiptValidator
module ItunesReceiptValidator
  ##
  # ItunesReceiptValidator::Receipt
  class Remote
    PRODUCTION_ENDPOINT = 'https://buy.itunes.apple.com/verifyReceipt'.freeze
    SANDBOX_ENDPOINT = 'https://sandbox.itunes.apple.com/verifyReceipt'.freeze

    EXPIRATION_INTENTS = {
      0 => :no_expiration_intent,
      1 => :canceled,                   # Customer canceled their subscription
      2 => :billing_error,              # Customers payment information invalid
      3 => :customer_did_not_agree,     # To a recent price increase
      4 => :product_was_not_available,  # For purchase at the time of renewal
      5 => :unknown_error
    }.freeze

    attr_reader :receipt
    attr_accessor :sandbox, :shared_secret, :request_method

    def initialize(receipt)
      @receipt = receipt
      @request_method = lambda do |url, headers, body|
        default_request_method(url, headers, body)
      end
      yield self
    end

    def status
      json[:status].to_i
    end

    def valid?
      status.zero?
    end

    def in_billing_retry_period?
      json.key?(:is_in_billing_retry_period) &&
        json[:is_in_billing_retry_period] == 1
    end

    def in_cancelled_billing_retry_period?
      json.key?(:is_in_billing_retry_period) &&
        json[:is_in_billing_retry_period].zero?
    end

    def expiration_intent
      EXPIRATION_INTENTS[json[:expiration_intent].to_i]
    end

    def expired?
      status == 21_006
    end

    def json
      @json ||= JSON.parse(response.body, symbolize_names: true)
    end

    private

    def request_url
      sandbox ? SANDBOX_ENDPOINT : PRODUCTION_ENDPOINT
    end

    def request_headers
      {
        'Accept' => 'application/json',
        'Content-Type' => 'application/json'
      }
    end

    def request_body
      {
        'password' => shared_secret,
        'receipt-data' => receipt
      }.to_json
    end

    def response
      @response ||= request_method.call(
        request_url, request_headers, request_body
      )
    end

    def default_request_method(url, headers, body)
      uri = URI(url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_PEER
      request = Net::HTTP::Post.new(uri.request_uri)
      headers.each { |key, val| request[key] = val }
      request.body = body
      http.request request
    end
  end
end
