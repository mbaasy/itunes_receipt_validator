##
# ItunesReceiptValidator
module ItunesReceiptValidator
  ##
  # ItunesReceiptValidator::TransactionsProxy
  class TransactionsProxy < Array
    include Enumerable

    def self.import(array)
      new array.map { |t| Transaction.new(t) }
        .sort { |a, b| a.purchased_at <=> b.purchased_at }
    end
  end
end
