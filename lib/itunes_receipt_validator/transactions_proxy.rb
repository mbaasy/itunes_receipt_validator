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

    def find_first(id)
      find { |t| t.id == id }
    end

    def find_last(id)
      sort_by { |a, b| b.purchased_at <=> a.purchaed_at }.last
    end
  end
end
