# iTunes Receipt Validator

[![Code Climate](https://codeclimate.com/github/mbaasy/itunes_receipt_validator/badges/gpa.svg)](https://codeclimate.com/github/mbaasy/itunes_receipt_validator)
[![Test Coverage](https://codeclimate.com/github/mbaasy/itunes_receipt_validator/badges/coverage.svg)](https://codeclimate.com/github/mbaasy/itunes_receipt_validator/coverage)
[![Build Status](https://travis-ci.org/mbaasy/itunes_receipt_validator.svg?branch=master)](https://travis-ci.org/mbaasy/itunes_receipt_validator)
[![Gem Version](https://badge.fury.io/rb/itunes_receipt_validator.svg)](https://badge.fury.io/rb/itunes_receipt_validator)

## Decode locally

The difference between this gem and any of the alternatives is that it decodes the base64 encoded receipt with our [ItunesReceiptDecoder](https://github.com/mbaasy/itunes_receipt_decoder) library to extract the data from the receipt **without** making a HTTP request to Apple's servers.

## No redundent HTTP requests

Because this library decodes the receipt first, it determins the origin of the receipt before making any HTTP requests. This means you don't need to make an additional request to the sandbox or prduction URLs.

Secondly, if the receipt can't be decoded, it can't be validated. This will prevent unnecessary requests when you receive fraudulent receipts.

## Handle any style of receipt

Apple offers two kinds of receipts:

1. The deprecated [[SKPaymentTransaction transactionReceipt]](https://developer.apple.com/library/ios/documentation/StoreKit/Reference/SKPaymentTransaction_Class/#//apple_ref/occ/instp/SKPaymentTransaction/transactionReceipt) and;
1. The Grand Unified Receipt [[NSBundle appStoreReceiptURL]](https://developer.apple.com/library/prerelease/ios/documentation/Cocoa/Reference/Foundation/Classes/NSBundle_Class/#//apple_ref/occ/instp/NSBundle/appStoreReceiptURL)

Validating both kinds of receipts requires separate logic because the schemas and data are entirely different.

## Normalize all the things

No matter if the receipt is a `[SKPaymentTransaction transactionReceipt]` or `[NSBundle appStoreReceiptURL]`, the responses are normalized with extra helpful methods for all your iOS and OSX receipt validation needs.

## Need a complete solution?

We have a cloud service available at **[mbaasy.com](https://mbaasy.com)**, it takes care of in-app purchase management, receipt validation and reporting so you don't have to. It even offers integration with your own API through webhooks to notify you of new, expired, renewed and cancelled purchases for iOS, OSX and Google Play receipts. It will save you time and money but most of all it allows you to focus on your core project instead of wasting time on receipt validation.

We offer this libary because we believe in the Open Source movement, [mbaasy.com](https://mbaasy.com) is built upon a foundation of Open Source projects, so this libary is our way of giving back to the community.

## Install

Install from the command line:

```sh
$ gem install itunes_receipt_validator
```

Or include it in your Gemfile:

```ruby
gem 'itunes_receipt_validator'
```

## Usage

### Initialization

```ruby
validator = ItunesReceiptValidator.new(
  base64_encoded_receipt,
  shared_secret: 'your_shared_secret'
) # => ItunesReceiptValidator::Receipt
```

Or intialize with a block:

```ruby
shared_secrets = {
  'com.example.app1' => 'shared_secret_for_app1'
  'com.example.app2' => 'shared_secret_for_app2'
}
validator = ItunesReceiptValidator.new(base64_encoded_receipt) do |receipt|
  receipt.shared_secret = shared_secrets.fetch(receipt.bundle_id)
end
```

### BYO HTTP requests

If you require more flexibility with upstream HTTP requests to Apple's Validation API you can initialize with your own request method.

```ruby
validator = ItunesReceiptValidator.new(base64_encoded_receipt) do |receipt|
  receipt.shared_secret = 'your_shared_secret'
  receipt.request_method = lambda do |url, headers, body|
    MyFancyRequest.new(url, headers: headers, body: body)
  end
end
```

Your custom method exposes a HTTP status code and a response body as `status` and `body` respectively.

### ItunesReceiptValidator::Receipt methods

```ruby
validator.sandbox?
```
Returns true or false (opposite of production?).

```ruby
validator.production?
```
Returns true or false (opposite of sandbox?).

```ruby
validator.bundle_id
```
Returns the bundle_id of the app (e.g. com.mbaasy.ios).

```ruby
validator.transactions
```
Returns a sub-class of `Array`, with transactions sourced locally from the receipt. See [ItunesReceiptValidator::TransactionsProxy methods](#itunesreceiptvalidatortransactionsproxy-methods).

```ruby
validator.latest_transactions
```
Returns a sub-class of `Array`, with transactions sourced from Apple's validation API. See [ItunesReceiptValidator::TransactionsProxy methods](#itunesreceiptvalidatortransactionsproxy-methods).

```ruby
validator.latest_receipt
```
Returns a base64 encoded string for the latest receipt sourced from Apple's validation API.

```ruby
validator.local
```
Returns the `ItunesReceiptDecoder::Decode::Transaction` or `ItunesReceiptDecoder::Decode::Unified` instances. See the [ItunesReceiptDecoder](https://github.com/mbaasy/itunes_receipt_decoder) gem.

```ruby
validator.remote
```
Returns the `ItunesReceiptValidator::Remote` instance.

### ItunesReceiptValidator::TransactionsProxy methods

Inerhits from [Array](http://apidock.com/ruby/Array) and includes [Enumerable](http://apidock.com/ruby/Enumerable).

```ruby
transactions.where(id: 1234)
```
Like ActiveRecord's `where` it accepts a hash of arguments and returns a new instance of `ItunesReceiptValidator::TransactionsProxy`.

### ItunesReceiptValidator::Transaction methods

```ruby
transaction.expired?
```
Returns true or false. This method will make a request to Apple's validation API to check if the receipt itself has expired, or if the latest transaction retrieved is expired.

```ruby
transaction.cancelled?
```
Returns true or false.

```ruby
transaction.auto_renewing?
```
Returns true if `web_order_line_item_id` is present.

```ruby
transaction.trial_period?
```
Returns true or false.

```ruby
transaction.latest
```
Returns a `ItunesReceiptValidator::Transaction` by making a request to Apple's validation API and matches it with the `original_id`.

### ItunesReceiptValidator::Transaction properties

``` ruby
transaction.id
```
The transaction identifier of the item that was purchased.

See [Transaction Identifier](https://developer.apple.com/library/ios/releasenotes/General/ValidateAppStoreReceipt/Chapters/ReceiptFields.html#//apple_ref/doc/uid/TP40010573-CH106-SW13).

```ruby
transaction.original_id
```
For a transaction that restores a previous transaction, the transaction identifier of the original transaction. Otherwise, identical to the transaction identifier.

See [Original Transaction Identifier](https://developer.apple.com/library/ios/releasenotes/General/ValidateAppStoreReceipt/Chapters/ReceiptFields.html#//apple_ref/doc/uid/TP40010573-CH106-SW14).

```ruby
transaction.product_id
```
The product identifier of the item that was purchased.

See [Product Identifier](https://developer.apple.com/library/ios/releasenotes/General/ValidateAppStoreReceipt/Chapters/ReceiptFields.html#//apple_ref/doc/uid/TP40010573-CH106-SW11).

```ruby
transaction.quantity
```
The number of items purchased.

See [Quantity](https://developer.apple.com/library/ios/releasenotes/General/ValidateAppStoreReceipt/Chapters/ReceiptFields.html#//apple_ref/doc/uid/TP40010573-CH106-SW10).

```ruby
transaction.first_purchased_at
```
For a transaction that restores a previous transaction, the date of the original transaction. Cast as a `Time` instance.

See [Original Purchase Date](https://developer.apple.com/library/ios/releasenotes/General/ValidateAppStoreReceipt/Chapters/ReceiptFields.html#//apple_ref/doc/uid/TP40010573-CH106-SW4).

```ruby
transaction.purchased_at
```
The date and time that the item was purchased. Cast as a `Time` instance.

See [Purchase Date](https://developer.apple.com/library/ios/releasenotes/General/ValidateAppStoreReceipt/Chapters/ReceiptFields.html#//apple_ref/doc/uid/TP40010573-CH106-SW15).

```ruby
transaction.expires_at
```
The expiration date for the subscription. Cast as a `Time` instance.

See [Subscription Expiration Date](https://developer.apple.com/library/ios/releasenotes/General/ValidateAppStoreReceipt/Chapters/ReceiptFields.html#//apple_ref/doc/uid/TP40010573-CH106-SW28).

```ruby
transaction.cancelled_at
```
For a transaction that was canceled by Apple customer support, the time and date of the cancellation. Cast as a `Time` instance.

See [Cancellation Date](https://developer.apple.com/library/ios/releasenotes/General/ValidateAppStoreReceipt/Chapters/ReceiptFields.html#//apple_ref/doc/uid/TP40010573-CH106-SW19).

```ruby
transaction.web_order_line_item_id
```
The primary key for identifying subscription purchases.

See [Web Order Line Item ID](https://developer.apple.com/library/ios/releasenotes/General/ValidateAppStoreReceipt/Chapters/ReceiptFields.html#//apple_ref/doc/uid/TP40010573-CH106-SW17).

```ruby
transaction.trial_period
```

Undocumented with Apple.

## Testing

1. `bundle install`
1. `rake`

---

Copyright 2015 [mbaasy.com](https://mbaasy.com/). This project is subject to the [MIT License](/LICENSE).
