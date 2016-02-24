require 'spec_helper'

shared_context :subscription_transaction_receipt do
  let(:receipt) { File.read(receipt_path).chomp }
  let(:remote_json) { File.read(remote_path) }
  let(:remote_hash) { JSON.parse(remote_json, symbolize_names: true) }
  let(:remote_transaction) { remote_hash[:receipt] }
  let(:expires_at) { Time.at remote_transaction[:expires_date].to_i / 1000 }
  let(:receipt_path) do
    File.expand_path('../../receipts/subscription_transaction.txt', __FILE__)
  end
  let(:remote_path) do
    File.expand_path('../../remote/subscription_transaction.json', __FILE__)
  end
end

shared_context :expired_subscription_transaction_receipt do
  let(:receipt) { File.read(receipt_path).chomp }
  let(:remote_json) { File.read(remote_path) }
  let(:remote_hash) { JSON.parse(remote_json, symbolize_names: true) }
  let(:remote_transaction) { remote_hash[:receipt] }
  let(:expires_at) { Time.at remote_transaction[:expires_date].to_i / 1000 }
  let(:receipt_path) do
    File.expand_path('../../receipts/subscription_transaction.txt', __FILE__)
  end
  let(:remote_path) do
    File.expand_path('../../remote/expired_transaction.json', __FILE__)
  end
end

shared_context :unified_receipt do
  let(:receipt) { File.read(receipt_path).chomp }
  let(:remote_json) { File.read(remote_path) }
  let(:remote_hash) { JSON.parse(remote_json, symbolize_names: true) }
  let(:remote_transactions) { remote_hash[:receipt][:in_app] }
  let(:receipt_path) do
    File.expand_path('../../receipts/unified.txt', __FILE__)
  end
  let(:remote_path) do
    File.expand_path('../../remote/unified.json', __FILE__)
  end
end
