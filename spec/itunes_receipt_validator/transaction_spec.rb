require 'spec_helper'

describe ItunesReceiptValidator::Transaction do
  subject { ItunesReceiptValidator.new(receipt).transactions.first }

  before do
    stub_request(:post, 'https://sandbox.itunes.apple.com/verifyReceipt')
      .to_return(body: remote_json)
  end

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

  shared_examples :a_latest_transaction do
    describe '#latest' do
      it 'returns a Transaction instance' do
        expect(subject.latest).to be_a(described_class)
      end

      it 'has the same original_id' do
        expect(subject.latest.original_id).to eq(subject.original_id)
      end

      it 'has a different id' do
        expect(subject.latest.id).to_not eq(subject.id)
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
    it_behaves_like :a_latest_transaction do
      describe '#expired?' do
        context 'when the expiry date is in the future' do
          before do
            Timecop.travel(expires_at - 3600)
          end

          it 'returns false' do
            expect(subject.latest.expired?).to eq(false)
          end
        end

        context 'when the expiry date is in the past' do
          before do
            Timecop.travel(expires_at + 3600)
          end

          it 'returns true' do
            expect(subject.latest.expired?).to eq(true)
          end
        end
      end
    end
  end

  context 'with a expired subscription transaction style receipt' do
    include_context :expired_subscription_transaction_receipt
    it_behaves_like :a_transaction
    it_behaves_like :a_latest_transaction do
      describe '#expired?' do
        it 'returns true' do
          expect(subject.latest.expired?).to eq(true)
        end
      end
    end
  end
end
