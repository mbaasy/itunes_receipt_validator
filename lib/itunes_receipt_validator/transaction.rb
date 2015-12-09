require 'time'

##
# ItunesReceiptValidator
module ItunesReceiptValidator
  ##
  # ItunesReceiptValidator::Transaction
  class Transaction
    ATTR_MAP = {
      id: :transaction_id,
      original_id: :original_transaction_id,
      product_id: :product_id,
      quantity: :quantity,
      web_order_line_item_id: proc do |hash|
        hash[:web_order_line_item_id].to_s if
          hash.fetch(:web_order_line_item_id, 0).to_i > 0
      end,
      trial_period: ->(hash) { hash[:is_trial_period] == 'true' },
      purchased_at: proc do |hash|
        parse_date(hash[:purchase_date_ms] || hash[:purchase_date])
      end,
      first_purchased_at: proc do |hash|
        parse_date hash[:original_purchase_date_ms] ||
                   hash[:original_purchase_date]
      end,
      cancelled_at: proc do |hash|
        parse_date(hash[:cancelled_date_ms] || hash[:cancelled_date])
      end,
      expires_at: proc do |hash|
        if hash[:bid]
          parse_date(hash[:expires_date] || hash[:expires_date_formatted])
        else
          parse_date(hash[:expires_date_ms] || hash[:expires_date])
        end
      end
    }

    attr_reader :id, :original_id, :product_id, :quantity, :first_purchased_at,
                :purchased_at, :expires_at, :cancelled_at,
                :web_order_line_item_id, :trial_period, :receipt

    def initialize(hash, receipt)
      normalize(hash)
      @receipt = receipt
    end

    def expired?
      !auto_renewing? ||
        receipt.remote.expired? ||
        latest.expires_at < Time.now.utc
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

    attr_writer :id, :original_id, :product_id, :quantity,
                :web_order_line_item_id, :trial_period, :purchased_at,
                :first_purchased_at, :cancelled_at, :expires_at

    def normalize(hash)
      ATTR_MAP.each do |key, val|
        if val.is_a?(Proc)
          send("#{key}=".to_s, instance_exec(hash, &val))
        else
          send("#{key}=".to_s, hash[val])
        end
      end
    end

    def parse_date(date)
      return nil if date.nil?
      if date.is_a?(Integer) || (date =~ /^\d+$/) == 0
        Time.at(date.to_f / 1000).utc
      else
        Time.strptime(date, '%F %T Etc/%Z').utc
      end
    rescue StandardError => _e
      nil
    end
  end
end
