# iTunes Receipt Validator

[![Code Climate](https://codeclimate.com/github/mbaasy/itunes_receipt_validator/badges/gpa.svg)](https://codeclimate.com/github/mbaasy/itunes_receipt_validator)
[![Test Coverage](https://codeclimate.com/github/mbaasy/itunes_receipt_validator/badges/coverage.svg)](https://codeclimate.com/github/mbaasy/itunes_receipt_validator/coverage)
[![Issue Count](https://codeclimate.com/github/mbaasy/itunes_receipt_validator/badges/issue_count.svg)](https://codeclimate.com/github/mbaasy/itunes_receipt_validator)
[![Build Status](https://travis-ci.org/mbaasy/itunes_receipt_validator.svg?branch=master)](https://travis-ci.org/mbaasy/itunes_receipt_validator)

# Install

Install from the command line:

```sh
$ gem install itunes_receipt_validator
```

Or include it in your Gemfile:

```ruby
gem 'itunes_receipt_validator'
```

# Usage

```ruby
validator = ItunesReceiptValidator.new(base64_encoded_receipt, shared_secret: 'yoursharedsecret')

validator.bundle_id # => 'com.your.BundleId'
validator.transactions # => ItunesReceiptValidator::TransactionsProxy
validator.latest_transactions #= ItunesReceiptValidator::TransactionsProxy
```
