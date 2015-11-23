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
      local
    end

    def sandbox?
      local.sandbox?
    end

    def production?
      !sandbox?
    end

    def bundle_id
      @bundle_id = local.receipt
                   .fetch(local.style == :unified ? :bundle_id : :bid)
    end

    def transactions
      @transactions = TransactionsProxy.import(
        local_transactions_source, self
      )
    end

    def latest_transactions
      @latest_transactions = TransactionsProxy.import(
        remote_transactions_source, self
      )
    end

    def latest_receipt
      @latest_receipt = remote.json.fetch(:latest_receipt)
    end

    def local
      @local ||= ItunesReceiptDecoder.new(receipt, expand_timestamps: true)
    end

    def remote
      @remote ||= Remote.new(
        receipt,
        { sandbox: local.sandbox? }.merge(options)
      )
    end

    private

    def local_transactions_source
      if local.style == :unified
        local.receipt.fetch(:in_app)
      else
        [local.receipt]
      end
    end

    def remote_transactions_source
      if local.style == :unified
        remote.json.fetch(:latest_receipt_info)
      else
        [remote.json.fetch(:latest_receipt_info)]
      end
    end
  end
end
