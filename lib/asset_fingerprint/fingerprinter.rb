require 'digest/md5'

module AssetFingerprint
  
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
