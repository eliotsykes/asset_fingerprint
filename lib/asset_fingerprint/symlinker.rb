module AssetFingerprint

  # Create fingerprinted symlinks for all assets.  
  def self.generate_all_symlinks
    #assets = ['favicon.ico', 'downloads', 'images', 'javascripts', 'stylesheets']
    assets = ['favicon.ico', 'downloads']
    assets.each do |source|
      path = abs_path_to_asset(source)
      if File.file?(path)
        AssetFingerprint.generate_symlink(source)
      end
    end
    #Dir['config/recipes/*.rb'].each { |recipe| load(recipe) }
  end
  
  def self.generate_symlink(source)
    asset_fingerprint = get_asset_fingerprint(source)
    fingerprinted_path = FileNamePathRewriter.build_fingerprinted_path(source, asset_fingerprint)
    AssetFingerprint::Symlinker.force_execute(source, fingerprinted_path)
  end
  
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
        force_execute(source, fingerprinted_path)
        @@symlinked << fingerprinted_path
      end
    end
    
    def self.force_execute(source, fingerprinted_path)
      abs_source_path = AssetFingerprint.abs_path_to_asset(source)
      abs_fingerprinted_path  = AssetFingerprint.abs_path_to_asset(fingerprinted_path)
      FileUtils.ln_sf(abs_source_path, abs_fingerprinted_path)
    end
    
    def self.already_symlinked?(fingerprinted_path)
      @@symlinked.include?(fingerprinted_path)
    end
    
    def self.enabled?
      AssetFingerprint.symlink_on_the_fly?
    end
    
  end
end
