module AssetFingerprint

  module FileNamePathRewriter
    
    def self.populate_fingerprinted_path(asset)
      # Insert the fingerprinted string as part of the filename
      # The -1 value causes the fingerprint to be appended, happens
      # if there is no period in source.
      # Example result if source = 'images/logo.png' the result would
      # be "images/logo-fp-#{asset_fingerprint}.png"
      fingerprint_index = asset.source.rindex('.') || -1

      path = String.new(asset.source).insert(fingerprint_index, "-fp-#{asset.fingerprint}")
      prepend_sep = path.index(File::SEPARATOR) == 0

      unless AssetFingerprint.symlink_output_dir.empty?
        path = File.join(AssetFingerprint.symlink_output_dir, path)
        path = File::SEPARATOR + path if prepend_sep
      end

      asset.fingerprinted_path = path
      asset.build_symlink_on_the_fly
    end
    
    def self.fingerprinted_paths_symlinkable?
      true
    end
    
    def self.remove_fingerprint(path)
      return path unless path.include?('-fp-')

      # Remove the symlink output directory from the path
      unless AssetFingerprint.symlink_output_dir.empty?
        prefix = path.index(File::SEPARATOR) == 0 ? File::SEPARATOR : ''
        prefix += AssetFingerprint.symlink_output_dir
        path.sub!(prefix, '')
      end

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
