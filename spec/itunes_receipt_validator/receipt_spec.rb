require 'spec_helper'

describe ItunesReceiptValidator::Receipt do
  let(:instance) { ItunesReceiptValidator.new(receipt) }

  shared_examples :a_receipt do
    describe '#bundle_id' do
      subject { instance.bundle_id }

      it 'returns the bundle id' do
        expect(subject).to eq('com.mbaasy.ios.demo')
      end
    end

    describe '#sandbox?' do
      subject { instance.sandbox? }

      context 'when the receipt is from sandbox' do
        before do
          allow(instance.decoded).to receive(:sandbox?).and_return(true)
        end

        it 'returns true' do
          expect(subject).to eq(true)
        end
      end

      context 'when the receipt is from production' do
        before do
          allow(instance.decoded).to receive(:sandbox?).and_return(false)
        end

        it 'returns false' do
          expect(subject).to eq(false)
        end
      end
    end

    describe '#production?' do
      subject { instance.production? }

      context 'when the receipt is from sandbox' do
        before do
          allow(instance.decoded).to receive(:sandbox?).and_return(true)
        end

        it 'returns false' do
          expect(subject).to eq(false)
        end
      end

      context 'when the receipt is from production' do
        before do
          allow(instance.decoded).to receive(:sandbox?).and_return(false)
        end

        it 'returns true' do
          expect(subject).to eq(true)
        end
      end
    end

    describe '#transactions' do
      subject { instance.transactions }

      it 'returns an instance of ItunesReceiptValidator::TransactionsProxy' do
        expect(subject).to be_a(ItunesReceiptValidator::TransactionsProxy)
      end
    end
  end

  context 'with a unified style receipt' do
    include_context :unified_receipt
    it_behaves_like :a_receipt
  end

  context 'with a transaction style receipt' do
    include_context :transaction_receipt
    it_behaves_like :a_receipt
  end
end
