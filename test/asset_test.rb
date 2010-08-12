require 'test_helper'
require 'asset_fingerprint/asset'

class AssetTest < ActiveSupport::TestCase

  def test_normalize_to_source_handles_arg_with_query_string
    path = '/path/to/foo-fp-12345678901234567890123456789012.png?mouseover=bar.png'
    normalized = ::AssetFingerprint::Asset.normalize_to_source(path)
    assert_equal '/path/to/foo-fp-12345678901234567890123456789012.png', normalized
  end
  
  def test_normalize_to_source_handles_arg_without_query_string
    path = '/path/to/foo-fp-12345678901234567890123456789012.png'
    normalized = ::AssetFingerprint::Asset.normalize_to_source(path)
    assert_equal '/path/to/foo-fp-12345678901234567890123456789012.png', normalized
  end
  
end
