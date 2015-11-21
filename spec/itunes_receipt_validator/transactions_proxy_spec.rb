require 'spec_helper'

describe ItunesReceiptValidator::TransactionsProxy do
  subject { ItunesReceiptValidator.new(receipt).transactions }

  shared_examples :a_transactions_proxy do
    it 'contains an set of ItunesReceiptValidator::Transaction instances' do
      subject.each do |transaction|
        expect(transaction).to be_a(ItunesReceiptValidator::Transaction)
      end
    end

    describe '#find_first' do
    end

    describe '#find_last' do
    end
  end

  context 'with a unified style receipt' do
    include_context :unified_receipt
    it_behaves_like :a_transactions_proxy

    it 'contains more than one transaction' do
      expect(subject.size).to be > 1
    end
  end

  context 'with a transaction style receipt' do
    include_context :transaction_receipt
    it_behaves_like :a_transactions_proxy

    it 'contains only one transaction' do
      expect(subject.size).to eq(1)
    end
  end
end
