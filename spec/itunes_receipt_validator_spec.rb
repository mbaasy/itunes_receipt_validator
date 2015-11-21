require 'spec_helper'

describe ItunesReceiptValidator do
  shared_examples :a_receipt do
    describe '.new' do
      subject { described_class.new(receipt) }

      it 'returns an instance of Receipt' do
        expect(subject).to be_a(described_class::Receipt)
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
