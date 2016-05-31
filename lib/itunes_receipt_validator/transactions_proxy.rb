##
# ItunesReceiptValidator
module ItunesReceiptValidator
  ##
  # ItunesReceiptValidator::TransactionsProxy
  class TransactionsProxy < Array
    def self.import(array, receipt)
      new array.map { |t| Transaction.new(t, receipt) }
               .sort { |a, b| a.purchased_at <=> b.purchased_at }
    end

    def where(props)
      select do |t|
        !props.map { |key, val| t.send(key.to_sym) == val }.include?(false)
      end
    end
  end
end
