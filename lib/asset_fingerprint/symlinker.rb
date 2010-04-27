module AssetFingerprint
  
  @@symlink_on_the_fly = true
  def self.symlink_on_the_fly=(value)
    @@symlink_on_the_fly = value
  end
  
  def self.symlink_on_the_fly?
    @@symlink_on_the_fly
  end
  
  class Symlinker
    
    @@symlinked = []
    
    def self.execute(source, fingerprinted_path)
      return unless enabled?
      unless already_symlinked?(fingerprinted_path)
        abs_source_path = abs_path_to_asset(source)
        abs_fingerprinted_path  = abs_path_to_asset(fingerprinted_path)
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
    
    def self.enabled?
      AssetFingerprint.symlink_on_the_fly?
    end
    
  end
end
