require 'test_helper'
require 'asset_fingerprint/asset'
require 'asset_fingerprint/fingerprinter'

module AssetFingerprint
  class FingerprinterTest < ActiveSupport::TestCase
    
    def test_fingerprint_returns_empty_string_for_non_existent_asset
      asset = Asset.create('path/to/non-existent-asset.css')
      assert_equal '', Fingerprinter.fingerprint(asset)
    end
  end
end
