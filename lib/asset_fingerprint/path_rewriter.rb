require 'asset_fingerprint/symlinker'

module AssetFingerprint
  
  def self.rewrite_asset_path(source, asset_fingerprint)
    return source if asset_fingerprint.blank?
    path_rewriter.rewrite(source, asset_fingerprint)
  end
  
  def self.path_rewriter=(value)
    if :file_name == value
      @@path_rewriter = FileNamePathRewriter
    elsif :query_string == value
      @@path_rewriter = QueryStringPathRewriter
    else
      @@path_rewriter = value
    end
  end
  
  def self.path_rewriter
    @@path_rewriter
  end
  
  module FileNamePathRewriter
    
    def self.rewrite(source, asset_fingerprint)
      # Insert the fingerprinted string as part of the filename
      # The -1 value causes the fingerprint to be appended, happens
      # if there is no period in source.
      # Example result if source = 'images/logo.png' the result would
      # be "images/logo-fp-#{asset_fingerprint}.png"
      fingerprint_index = source.rindex('.') || -1
      fingerprinted_path = String.new(source).insert(fingerprint_index, "-fp-#{asset_fingerprint}")
      AssetFingerprint::Symlinker.execute(source, fingerprinted_path)
      fingerprinted_path
    end
    
  end
  
  module QueryStringPathRewriter
    
    def self.rewrite(source, asset_fingerprint)
      source + "?#{asset_fingerprint}"
    end
    
  end
  
end
