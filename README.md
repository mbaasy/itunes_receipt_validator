# iTunes Receipt Validator

[![Code Climate](https://codeclimate.com/github/mbaasy/itunes_receipt_validator/badges/gpa.svg)](https://codeclimate.com/github/mbaasy/itunes_receipt_validator)
[![Test Coverage](https://codeclimate.com/github/mbaasy/itunes_receipt_validator/badges/coverage.svg)](https://codeclimate.com/github/mbaasy/itunes_receipt_validator/coverage)
[![Build Status](https://travis-ci.org/mbaasy/itunes_receipt_validator.svg?branch=master)](https://travis-ci.org/mbaasy/itunes_receipt_validator)
[![Gem Version](https://badge.fury.io/rb/itunes_receipt_validator.svg)](https://badge.fury.io/rb/itunes_receipt_validator)

iTunes receipts are available in two flavours:

1. The deprecated [[SKPaymentTransaction transactionReceipt]](https://developer.apple.com/library/ios/documentation/StoreKit/Reference/SKPaymentTransaction_Class/#//apple_ref/occ/instp/SKPaymentTransaction/transactionReceipt) and;
1. The Grand Unified Receipt [[NSBundle appStoreReceiptURL]](https://developer.apple.com/library/prerelease/ios/documentation/Cocoa/Reference/Foundation/Classes/NSBundle_Class/#//apple_ref/occ/instp/NSBundle/appStoreReceiptURL)

Validating both kinds of receipts require separate logic because the schemas and data are entirely different.

The different between this gem and any of the alternatives is that it firstly decodes the base64 encoded receipt with our [ItunesReceiptDecoder](https://github.com/mbaasy/itunes_receipt_decoder) gem to extract the data from the receipt **without** making a HTTP request to Apple's servers and normalizes both `[SKPaymentTransaction transactionReceipt]` receipts and `[NSBundle appStoreReceiptURL]` into a common ruby API.

It then provides methods to retrieve the latest transactions from Apple's servers and normalizes those too. This takes away the pain of disecting the receipt data and makes it easy to support both flavours of receipts.

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

### ItunesReceiptValidator::Receipt methods

```ruby
validator.sandbox? #=> true | false
validator.production? #= true | false
validator.bundle_id # => 'com.your.BundleId'
validator.transactions # => ItunesReceiptValidator::TransactionsProxy
validator.latest_transactions #= ItunesReceiptValidator::TransactionsProxy
validator.latest_receipt #=> Base64 encoded string
validator.local #=> ItunesReceiptDecoder::Decode::Transaction | ItunesReceiptDecoder::Decode::Unified
# (see https://github.com/mbaasy/itunes_receipt_decoder)
validator.remote #=> ItunesReceiptValidator::Remote
```

### ItunesReceiptValidator::TransactionsProxy methods

Inerhits from [Array](http://apidock.com/ruby/Array) and includes [Enumerable](http://apidock.com/ruby/Enumerable).

```ruby
transactions = validator.transactions
transactions.first #=> ItunesReceiptValidator::Transaction
transactions.where(id: 1234) => #=> ItunesReceiptValidator::Transaction

latest_transactions = validator.latest_transactions
latest_transactions.first #=> ItunesReceiptValidator::Transaction
latest_transactions.where(id: 1234) => #=> ItunesReceiptValidator::Transaction
```

### ItunesReceiptValidator::Transaction methods

```ruby
transaction = validator.transactions.first
transaction.expired? #=> true | false
# Will validate with Apple and check the status in the JSON payload
transaction.cancelled? #=> true | false
transaction.auto_renewing? #=> true | false
transaction.trial_period? #=> true | false
transaction.latest #=> ItunesReceiptValidator::Transaction
# Finds the latest transaction on Apple's servers with a matching original_transaction_id
```

### ItunesReceiptValidator::Transaction properties
``` ruby
transaction.id #=> transaction_id
transaction.original_id #=> original_transaction_id
transaction.product_id #=> product_id
quantity => #=> quantity
first_purchased_at => #=> Time(original_purchase_date)
purchased_at #=> Time(purchase_date)
expires_at #=> Time(expires_date)
cancelled_at #=> Time(cancelled_date)
web_order_line_item_id #=> web_order_line_item_id
trial_period #=> is_trial_period
```

## Testing

1. `bundle install`
1. `rake`

---

Copyright 2015 [mbaasy.com](https://mbaasy.com/). This project is subject to the [MIT License](/LICENSE).
