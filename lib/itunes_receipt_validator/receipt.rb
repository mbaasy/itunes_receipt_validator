##
# ItunesReceiptValidator
module ItunesReceiptValidator
  ##
  # ItunesReceiptValidator::Receipt
  class Receipt
    attr_reader :receipt, :bundle_id

    def initialize(receipt, options = {})
      @receipt = receipt
      decoded
    end

    def sandbox?
      decoded.sandbox?
    end

    def production?
      !sandbox?
    end

    def bundle_id
      @bundle_id = decoded.receipt
                   .fetch(decoded.style == :unified ? :bundle_id : :bid)
    end

    def transactions
      @transactions = TransactionsProxy.import(decoded_transactions_source)
    end

    def decoded
      @decoded ||= ItunesReceiptDecoder.new(receipt, expand_timestamps: true)
    end

    private

    def decoded_transactions_source
      if decoded.style == :unified
        decoded.receipt.fetch(:in_app)
      else
        [decoded.receipt]
      end
    end
  end
end
