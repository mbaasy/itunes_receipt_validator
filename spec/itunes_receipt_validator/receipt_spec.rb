require 'spec_helper'

describe ItunesReceiptValidator::Receipt do
  let(:options) { { shared_secret: SecureRandom.hex(20) } }
  let(:instance) { ItunesReceiptValidator.new(receipt, options) }

  before do
    stub_request(:post, ItunesReceiptValidator::Remote::SANDBOX_ENDPOINT)
      .to_return(body: remote_json)
  end

  shared_examples :an_itunes_request do
    it 'fetches the data from apple' do
      subject
      expect(
        a_request(:post, ItunesReceiptValidator::Remote::SANDBOX_ENDPOINT)
        .with(
          headers: {
            'Accept' => 'application/json',
            'Content-Type' => 'application/json'
          },
          body: {
            'password' => options.fetch(:shared_secret),
            'receipt-data' => receipt
          }.to_json
        )
      ).to have_been_made.once
    end
  end

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
          allow_any_instance_of(ItunesReceiptDecoder::Decode::Base)
            .to receive(:sandbox?).and_return(true)
        end

        it 'returns true' do
          expect(subject).to eq(true)
        end
      end

      context 'when the receipt is from production' do
        before do
          allow_any_instance_of(ItunesReceiptDecoder::Decode::Base)
            .to receive(:sandbox?).and_return(false)
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
          allow_any_instance_of(ItunesReceiptDecoder::Decode::Base)
            .to receive(:sandbox?).and_return(true)
        end

        it 'returns false' do
          expect(subject).to eq(false)
        end
      end

      context 'when the receipt is from production' do
        before do
          allow_any_instance_of(ItunesReceiptDecoder::Decode::Base)
            .to receive(:sandbox?).and_return(false)
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

    describe '#latest_transactions' do
      subject { instance.latest_transactions }

      it_behaves_like :an_itunes_request

      it 'returns an instance of ItunesReceiptValidator::TransactionsProxy' do
        expect(subject).to be_a(ItunesReceiptValidator::TransactionsProxy)
      end
    end

    describe '#latest_receipt' do
      subject { instance.latest_receipt }

      it_behaves_like :an_itunes_request

      it 'returns the latest_receipt' do
        expect(subject).to eq(JSON.parse(remote_json, symbolize_names: true)
          .fetch(:latest_receipt))
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
