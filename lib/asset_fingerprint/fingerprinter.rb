require 'digest/md5'

module AssetFingerprint

  def self.abs_path_to_asset(source)
    File.join(ActionView::Helpers::AssetTagHelper::ASSETS_DIR, source)
  end
  
  def self.cache_asset_fingerprints
    if @@cache_asset_fingerprints.nil?
      # Asset fingerprints cache behaviour same as cache_asset_timestamps
      # if no value set.
      return ActionView::Helpers::AssetTagHelper.cache_asset_timestamps
    end
    @@cache_asset_fingerprints
  end
  
  # You can enable or disable the asset fingerprints cache.
  # With the cache enabled, the asset tag helper methods will make fewer
  # expensive calls. However this prevents you from modifying
  # any asset files while the server is running.
  #
  def self.cache_asset_fingerprints=(value)
    @@cache_asset_fingerprints = value
  end

  @@cache_asset_fingerprints = nil
  
  @@asset_fingerprints_cache = {}
  @@asset_fingerprints_cache_guard = Mutex.new
  
  def self.get_asset_fingerprint(source)
    if asset_fingerprint = ENV["RAILS_ASSET_ID"]
      asset_fingerprint
    else
      if cache_asset_fingerprints && (asset_fingerprint = @@asset_fingerprints_cache[source])
        asset_fingerprint
      else
        path = abs_path_to_asset(source)
        asset_fingerprint = calculate_fingerprint(path)
        
        if cache_asset_fingerprints
          @@asset_fingerprints_cache_guard.synchronize do
            @@asset_fingerprints_cache[source] = asset_fingerprint
          end
        end

        asset_fingerprint
      end
    end
  end
  
  def self.calculate_fingerprint(path)
    fingerprinter.fingerprint(path)
  end
  
  def self.fingerprinter=(value)
    if :timestamp == value 
      @@fingerprinter = TimestampFingerprinter
    elsif :md5 == value
      @@fingerprinter = Md5Fingerprinter
    else
      @@fingerprinter = value
    end
  end
  
  def self.fingerprinter
    @@fingerprinter
  end
  
  module TimestampFingerprinter
    
    def self.fingerprint(path)
      File.exist?(path) ? File.mtime(path).to_i.to_s : ''
    end
    
  end
  
  module Md5Fingerprinter
    
    def self.fingerprint(path)
      Digest::MD5.hexdigest(File.read(path))
    end
    
  end
  
end
