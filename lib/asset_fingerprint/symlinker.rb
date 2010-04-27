module AssetFingerprint
  class Symlinker
    
    @@symlinked = []
    
    def self.execute(source, fingerprinted_path)
      if already_symlinked?(fingerprinted_path)
        Rails.logger.info("'#{fingerprinted_path}' is already symlinked")
      else
        abs_source_path = abs_path_to_asset(source)
        abs_fingerprinted_path  = abs_path_to_asset(fingerprinted_path)
        Rails.logger.info("Creating symlink '#{abs_fingerprinted_path}'")
        FileUtils.ln_sf(abs_source_path, abs_fingerprinted_path)
        @@symlinked << fingerprinted_path
      end
    end
    
    def self.already_symlinked?(fingerprinted_path)
      @@symlinked.include?(fingerprinted_path)
    end
    
    def self.abs_path_to_asset(source)
      ActionView::Helpers::AssetTagHelper.abs_path_to_asset(source)
    end
    
  end
end
