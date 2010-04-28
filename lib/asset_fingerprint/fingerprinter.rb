require 'digest/md5'

module AssetFingerprint

  class Fingerprinter
    
    def self.fingerprint(asset)
      return ENV["RAILS_ASSET_ID"] if ENV["RAILS_ASSET_ID"]
      build_fingerprint(asset)
    end
    
  end
  
  class TimestampFingerprinter < Fingerprinter
    
    def self.build_fingerprint(asset)
      path = asset.source_absolute_path
      File.exist?(path) ? File.mtime(path).to_i.to_s : ''
    end
    
  end
  
  class Md5Fingerprinter <  Fingerprinter
    
    def self.build_fingerprint(asset)
      path = asset.source_absolute_path
      Digest::MD5.hexdigest(File.read(path))
    end
    
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
  
  # Default to md5 fingerprinter
  self.fingerprinter = :md5
  
  def self.fingerprinter
    @@fingerprinter
  end
  
end
