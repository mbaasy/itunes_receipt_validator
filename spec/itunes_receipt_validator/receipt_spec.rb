require 'spec_helper'

describe ItunesReceiptValidator::Receipt do
  let(:options) { { shared_secret: SecureRandom.hex(20) } }
  let(:instance) { described_class.new(receipt, options) }

  before do
    stub_request(:post, 'https://sandbox.itunes.apple.com/verifyReceipt')
      .to_return(body: remote_json)
  end

  shared_examples :an_itunes_sandbox_result do
    it 'fetches the data from sandbox.itunes.apple.com' do
      subject
      expect(
        a_request(:post, 'https://sandbox.itunes.apple.com/verifyReceipt')
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

  shared_examples :an_itunes_production_result do
    it 'fetches the data from buy.itunes.apple.com' do
      subject
      expect(
        a_request(:post, 'https://buy.itunes.apple.com/verifyReceipt')
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
            .to receive(:environment).and_return(:sandbox)
        end

        it 'returns true' do
          expect(subject).to eq(true)
        end
      end

      context 'when the receipt is from production' do
        before do
          allow_any_instance_of(ItunesReceiptDecoder::Decode::Base)
            .to receive(:environment).and_return(:production)
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
            .to receive(:environment).and_return(:sandbox)
        end

        it 'returns false' do
          expect(subject).to eq(false)
        end
      end

      context 'when the receipt is from production' do
        before do
          allow_any_instance_of(ItunesReceiptDecoder::Decode::Base)
            .to receive(:environment).and_return(:production)
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

      it_behaves_like :an_itunes_sandbox_result

      it 'returns an instance of ItunesReceiptValidator::TransactionsProxy' do
        expect(subject).to be_a(ItunesReceiptValidator::TransactionsProxy)
      end
    end

    describe '#latest_receipt' do
      subject { instance.latest_receipt }

      it_behaves_like :an_itunes_sandbox_result

      it 'returns the latest_receipt' do
        expect(subject).to eq(JSON.parse(remote_json, symbolize_names: true)
          .fetch(:latest_receipt))
      end
    end

    describe '#remote' do
      subject { instance.remote }

      context 'when decoder.environment was production but status is 21_007' do
        before do
          allow_any_instance_of(ItunesReceiptDecoder::Decode::Base)
            .to receive(:environment).and_return(:production)
          stub_request(:post, 'https://buy.itunes.apple.com/verifyReceipt')
            .to_return(body: { status: 21_007 }.to_json)
        end

        it 'changes the environment' do
          expect { subject }.to change {
            instance.environment
          }.from(:production).to(:sandbox)
        end

        it_behaves_like :an_itunes_sandbox_result
      end

      context 'when decoder.environment was sandbox but status is 21_008' do
        before do
          stub_request(:post, 'https://buy.itunes.apple.com/verifyReceipt')
            .to_return(body: remote_json)
          stub_request(:post, 'https://sandbox.itunes.apple.com/verifyReceipt')
            .to_return(body: { status: 21_008 }.to_json)
        end

        it 'changes the environment' do
          expect { subject }.to change {
            instance.environment
          }.from(:sandbox).to(:production)
        end

        it_behaves_like :an_itunes_production_result
      end
    end
  end

  context 'with a unified style receipt' do
    include_context :unified_receipt
    it_behaves_like :a_receipt
  end

  context 'with a subscription transaction style receipt' do
    include_context :subscription_transaction_receipt
    it_behaves_like :a_receipt
  end
end
