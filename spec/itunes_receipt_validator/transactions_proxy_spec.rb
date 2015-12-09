require 'spec_helper'

describe ItunesReceiptValidator::TransactionsProxy do
  subject { ItunesReceiptValidator.new(receipt).transactions }

  shared_examples :a_transactions_proxy do
    it 'contains an set of ItunesReceiptValidator::Transaction instances' do
      subject.each do |transaction|
        expect(transaction).to be_a(ItunesReceiptValidator::Transaction)
      end
    end
  end

  context 'with a unified style receipt' do
    include_context :unified_receipt
    it_behaves_like :a_transactions_proxy
    let(:managed_product_transactions) do
      remote_transactions.select { |t| !t.key?(:web_order_line_item_id) }
    end
    let(:subscription_product_transactions) do
      remote_transactions.select { |t| t.key?(:web_order_line_item_id) }
    end

    before do
      expect(managed_product_transactions.size).to be >= 1
      expect(subscription_product_transactions.size).to be >= 1
    end

    it 'contains the correct number of transactions' do
      expect(subject.size).to eq(remote_transactions.size)
    end

    it 'assigns attrs for all transactions' do
      remote_transactions.each do |t|
        transaction = subject.where(id: t[:transaction_id]).first
        expect(transaction.id).to eq(t[:transaction_id])
        expect(transaction.product_id).to eq(t[:product_id])
        expect(transaction.quantity.to_s).to eq(t[:quantity])
        expect(transaction.purchased_at.strftime('%F %T Etc/GMT'))
          .to eq(t[:purchase_date])
        expect(transaction.first_purchased_at.strftime('%F %T Etc/GMT'))
          .to eq(t[:original_purchase_date])
        expect(transaction.web_order_line_item_id)
          .to eq(t[:web_order_line_item_id])
      end
    end

    it 'assigns attrs for all managed product transactions' do
      managed_product_transactions.each do |t|
        transaction = subject.where(id: t[:transaction_id]).first
        expect(transaction.auto_renewing?).to eq(false)
      end
    end

    it 'assigns attrs for all subscription transactions' do
      subscription_product_transactions.each do |t|
        transaction = subject.where(id: t[:transaction_id]).first
        expect(transaction.auto_renewing?).to eq(true)
        expect(transaction.cancelled?).to eq(false)
        expect(transaction.trial_period?).to eq(false)
        expect(transaction.expires_at.strftime('%F %T Etc/GMT'))
          .to eq(t[:expires_date])
      end
    end
  end

  context 'with a subscription transaction style receipt' do
    include_context :subscription_transaction_receipt
    it_behaves_like :a_transactions_proxy

    it 'contains only one transaction' do
      expect(subject.size).to eq(1)
    end

    it 'assigns attrs the transaction' do
      t = remote_transaction
      transaction = subject.where(id: t[:transaction_id]).first
      expect(transaction.id).to eq(t[:transaction_id])
      expect(transaction.product_id).to eq(t[:product_id])
      expect(transaction.quantity.to_s).to eq(t[:quantity])
      expect(transaction.purchased_at.strftime('%F %T Etc/GMT'))
        .to eq(t[:purchase_date])
      expect(transaction.first_purchased_at.strftime('%F %T Etc/GMT'))
        .to eq(t[:original_purchase_date])
      expect(transaction.web_order_line_item_id)
        .to eq(t[:web_order_line_item_id])
      expect(transaction.auto_renewing?).to eq(true)
      expect(transaction.cancelled?).to eq(false)
      expect(transaction.trial_period?).to eq(false)
      expect(transaction.expires_at.strftime('%F %T Etc/GMT'))
        .to eq(t[:expires_date_formatted])
    end
  end
end
