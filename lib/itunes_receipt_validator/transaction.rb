##
# ItunesReceiptValidator
module ItunesReceiptValidator
  ##
  # ItunesReceiptValidator::Transaction
  class Transaction
    attr_reader :id, :original_id, :product_id, :quantity, :first_purchased_at,
                :purchased_at, :expires_at, :cancelled_at,
                :web_order_line_item_id, :trial_period, :receipt

    def initialize(hash, receipt)
      normalize(hash)
      @receipt = receipt
    end

    def expired?
      receipt.remote.expired? || expires_at < Time.now.utc
    end

    def cancelled?
      !cancelled_at.nil?
    end

    def auto_renewing?
      !web_order_line_item_id.nil?
    end

    def trial_period?
      trial_period
    end

    def latest
      receipt.latest_transactions.where(original_id: original_id).last
    end

    private

    def convert_ms(ms)
      return nil if ms.nil?
      Time.at(ms.to_f / 1000).utc
    end

    def normalize(hash)
      @id = hash.fetch(:transaction_id)
      @original_id = hash.fetch(:original_transaction_id)
      @product_id = hash.fetch(:product_id)
      @quantity = hash.fetch(:quantity)
      @purchased_at = convert_ms hash.fetch(:purchase_date_ms)
      @first_purchased_at = convert_ms hash.fetch(:original_purchase_date_ms)
      @cancelled_at = convert_ms hash.fetch(:cancelled_date_ms, nil)
      @web_order_line_item_id = hash.fetch(:web_order_line_item_id, nil)
      @trial_period = hash.fetch(:is_trial_period, nil) == 'true'
      if hash[:bid]
        @expires_at = convert_ms hash.fetch(:expires_date, nil)
      else
        @expires_at = convert_ms hash.fetch(:expires_date_ms, nil)
      end
    end
  end
end
