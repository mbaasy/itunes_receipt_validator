##
# ItunesReceiptValidator
module ItunesReceiptValidator
  ##
  # ItunesReceiptValidator::Error
  class Error < StandardError; end

  ##
  # ItunesReceiptValidator::LocalDecodingError
  class LocalDecodingError < Error; end

  ##
  # ItunesReceiptValidator::RemoteNetworkError
  class RemoteNetworkError < Error; end
end
