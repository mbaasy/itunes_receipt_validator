require 'spec_helper'

shared_context :transaction_receipt do
  let(:receipt) { File.read(receipt_path).chomp }
  let(:receipt_path) do
    File.expand_path('../../receipts/transaction.txt', __FILE__)
  end
end

shared_context :unified_receipt do
  let(:receipt) { File.read(receipt_path).chomp }
  let(:receipt_path) do
    File.expand_path('../../receipts/unified.txt', __FILE__)
  end
end
