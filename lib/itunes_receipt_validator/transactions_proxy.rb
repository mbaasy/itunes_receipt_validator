##
# ItunesReceiptValidator
module ItunesReceiptValidator
  ##
  # ItunesReceiptValidator::TransactionsProxy
  class TransactionsProxy < Array
    def self.import(array, receipt)
      new array.map { |t| Transaction.new(t, receipt) }.sort_by(&:purchased_at)
    end

    def where(props)
      select do |t|
        !props.map { |key, val| t.send(key.to_sym) == val }.include?(false)
      end
    end
  end
end
