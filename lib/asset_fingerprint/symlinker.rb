module AssetFingerprint
  
  def self.generate_all_symlinks
    Asset.generate_all_symlinks
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
    
    def self.execute(asset)
      return unless enabled?
      unless already_symlinked?(asset.fingerprinted_path)
        symlink_done = force_execute(asset)
        @@symlinked << asset.fingerprinted_path if symlink_done
      end
    end
    
    def self.force_execute(asset)
      return false unless asset.symlinkable?
      FileUtils.ln_sf(asset.source_absolute_path, asset.fingerprinted_absolute_path)
      true
    end
    
    def self.already_symlinked?(fingerprinted_path)
      @@symlinked.include?(fingerprinted_path)
    end
    
    def self.enabled?
      AssetFingerprint.symlink_on_the_fly?
    end
    
  end
end
