require 'test_helper'
require 'asset_fingerprint/asset'

class AssetTest < ActiveSupport::TestCase

  def test_normalize_to_source_handles_arg_with_query_string
    path = '/path/to/foo-fp-001abc78901234567890123456789012.png?mouseover=bar.png'
    normalized = ::AssetFingerprint::Asset.normalize_to_source(path)
    assert_equal '/path/to/foo-fp-001abc78901234567890123456789012.png', normalized
  end
  
  def test_normalize_to_source_handles_arg_without_query_string
    path = '/path/to/foo-fp-001abc78901234567890123456789012.png'
    normalized = ::AssetFingerprint::Asset.normalize_to_source(path)
    assert_equal '/path/to/foo-fp-001abc78901234567890123456789012.png', normalized
  end
  
  def test_fingerprint_symlink_returns_true_for_fingerprint_symlink
    fingerprinted_path = 'test/resources/test-fp-002abc78901234567890123456789012.gif'
    FileUtils.ln_sf('test/resources/test.gif', fingerprinted_path)
    assert ::AssetFingerprint::Asset.fingerprint_symlink?(fingerprinted_path)
    File.delete(fingerprinted_path)
  end
    
  def test_fingerprint_symlink_returns_false_for_non_symlink_file_with_fingerprint_like_filename
    path = 'test/resources/foo-fp-003abc78901234567890123456789012.css'
    FileUtils.touch(path)
    assert !(::AssetFingerprint::Asset.fingerprint_symlink?(path))
    File.delete(path)
  end
  
  def test_fingerprint_symlink_returns_false_for_symlink_with_non_fingerprint_like_filename
    symlink_path = 'test/resources/symlink-to-test.gif'
    FileUtils.ln_sf('test/resources/test.gif', symlink_path)
    assert !(::AssetFingerprint::Asset.fingerprint_symlink?(symlink_path))
    File.delete(symlink_path)
  end
  
end
