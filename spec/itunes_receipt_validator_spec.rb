require 'spec_helper'

describe ItunesReceiptValidator do
  shared_examples :a_receipt do
    describe '.new' do
      subject { described_class.new(receipt) }

      it 'returns an instance of Receipt' do
        expect(subject).to be_a(described_class::Receipt)
      end

      context 'when a block is given' do
        it 'assigns the shared_secret' do
          validator = described_class.new(receipt) do |receipt|
            receipt.shared_secret = 'bacon_and_eggs'
          end
          expect(validator.shared_secret).to eq('bacon_and_eggs')
        end
      end
    end
  end

  context 'with a unified stye receipt' do
    include_context :unified_receipt
    it_behaves_like :a_receipt
  end

  context 'with a transaction style receipt' do
    include_context :transaction_receipt
    it_behaves_like :a_receipt
  end
end
