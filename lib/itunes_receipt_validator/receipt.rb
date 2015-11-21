##
# ItunesReceiptValidator
module ItunesReceiptValidator
  ##
  # ItunesReceiptValidator::Receipt
  class Receipt
    attr_reader :receipt, :options

    def initialize(receipt, options = {})
      @receipt = receipt
      @options = options
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
      @transactions = TransactionsProxy.import decoded_transactions_source
    end

    def latest_transactions
      @latest_transactions = TransactionsProxy.import remote_transactions_source
    end

    def latest_receipt
      @latest_receipt = remote.fetch(:latest_receipt)
    end

    def decoded
      @decoded ||= ItunesReceiptDecoder.new(receipt, expand_timestamps: true)
    end

    def remote
      @remote ||= Remote.new(
        receipt,
        { sandbox: decoded.sandbox? }.merge(options)
      ).json
    end

    private

    def decoded_transactions_source
      if decoded.style == :unified
        decoded.receipt.fetch(:in_app)
      else
        [decoded.receipt]
      end
    end

    def remote_transactions_source
      if decoded.style == :unified
        remote.fetch(:latest_receipt_info)
      else
        [remote.fetch(:latest_receipt_info)]
      end
    end
  end
end
