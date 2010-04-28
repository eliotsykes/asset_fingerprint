module AssetFingerprint

  module FileNamePathRewriter
    
    def self.populate_fingerprinted_path(asset)
      # Insert the fingerprinted string as part of the filename
      # The -1 value causes the fingerprint to be appended, happens
      # if there is no period in source.
      # Example result if source = 'images/logo.png' the result would
      # be "images/logo-fp-#{asset_fingerprint}.png"
      fingerprint_index = asset.source.rindex('.') || -1
      asset.fingerprinted_path = String.new(asset.source).insert(fingerprint_index, "-fp-#{asset.fingerprint}")
      asset.build_symlink_on_the_fly
    end
    
    def self.fingerprinted_paths_symlinkable?
      true
    end
    
    def self.remove_fingerprint(path)
      return path unless path.include?('-fp-')
      path_components = path.split('-fp-')
      prefix = path_components.first
      fingerprint_and_ext = path_components.last
      if !fingerprint_and_ext.blank? && fingerprint_and_ext.include?('.')
        # There is a file extension
        ext = fingerprint_and_ext.split('.').last
      end
      if ext.blank?
        return prefix
      else
        return "#{prefix}.#{ext}"
      end
    end
    
  end
  
  module QueryStringPathRewriter
    
    def self.populate_fingerprinted_path(asset)
      asset.fingerprinted_path = asset.source + "?#{asset.fingerprint}"
    end
    
    def self.fingerprinted_paths_symlinkable?
      false
    end
    
    def self.remove_fingerprint(path)
      path.split('?').first          
    end
  end
  
  def self.rewrite_asset_path(source)
    (AssetFingerprint::Asset.create(source)).fingerprinted_path    
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
  
  # Default to file_name path rewriter
  self.path_rewriter = :file_name
  
  def self.path_rewriter
    @@path_rewriter
  end
  
end
