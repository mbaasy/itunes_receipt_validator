require 'spec_helper'

describe ItunesReceiptValidator::Transaction do
  subject { ItunesReceiptValidator.new(receipt).transactions.first }

  shared_examples :a_transaction do
    it 'includes all expected properties' do
      expect(subject).to respond_to(
        :id, :original_id, :quantity, :first_purchased_at,
        :purchased_at, :expires_at, :cancelled_at
      )
    end

    it 'parses all the timestamps' do
      %i(first_purchased_at purchased_at).each do |prop|
        expect(subject.send(prop)).to be_a(Time)
      end
    end
  end

  context 'with a unified style receipt' do
    include_context :unified_receipt
    it_behaves_like :a_transaction
  end

  context 'with a subscription transaction style receipt' do
    include_context :subscription_transaction_receipt
    it_behaves_like :a_transaction
  end
end
