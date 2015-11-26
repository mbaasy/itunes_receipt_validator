require 'pp'
require 'httparty'
require 'itunes_receipt_decoder'
require 'itunes_receipt_validator/error'
require 'itunes_receipt_validator/receipt'
require 'itunes_receipt_validator/remote'
require 'itunes_receipt_validator/transaction'
require 'itunes_receipt_validator/transactions_proxy'

##
# ItunesReceiptValidator
module ItunesReceiptValidator
  def self.new(receipt, options = {}, &block)
    Receipt.new(receipt, options, &block)
  end
end
