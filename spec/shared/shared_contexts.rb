require 'spec_helper'

shared_context :transaction_receipt do
  let(:receipt) { File.read(receipt_path).chomp }
  let(:remote_json) { File.read(remote_path) }
  let(:receipt_path) do
    File.expand_path('../../receipts/transaction.txt', __FILE__)
  end
  let(:remote_path) do
    File.expand_path('../../remote/transaction.json', __FILE__)
  end
end

shared_context :unified_receipt do
  let(:receipt) { File.read(receipt_path).chomp }
  let(:remote_json) { File.read(remote_path) }
  let(:receipt_path) do
    File.expand_path('../../receipts/unified.txt', __FILE__)
  end
  let(:remote_path) do
    File.expand_path('../../remote/unified.json', __FILE__)
  end
end
