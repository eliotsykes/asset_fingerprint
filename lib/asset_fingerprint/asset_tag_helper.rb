require 'digest/md5'

module ActionView
  module Helpers
    module AssetTagHelper

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
      
      def rails_asset_fingerprint(source)
        if asset_fingerprint = ENV["RAILS_ASSET_ID"]
          asset_fingerprint
        else
          if AssetTagHelper.cache_asset_fingerprints && (asset_fingerprint = @@asset_fingerprints_cache[source])
            asset_fingerprint
          else
            path = File.join(ASSETS_DIR, source)
            asset_fingerprint = calculate_asset_fingerprint(path)
    
            if AssetTagHelper.cache_asset_fingerprints
              @@asset_fingerprints_cache_guard.synchronize do
                @@asset_fingerprints_cache[source] = asset_fingerprint
              end
            end
    
            asset_fingerprint
          end
        end
      end
      
      def fingerprint_in_query_string(source, asset_fingerprint)
        source + "?#{asset_fingerprint}"
      end
      
      def fingerprint_in_file_name(source, asset_fingerprint)
        # Insert the fingerprinted string as part of the filename
        # The -1 value causes the fingerprint to be appended, happens
        # if there is no period in source.
        # Example result if source = 'images/logo.png' the result would
        # be "images/logo-fp-#{asset_fingerprint}.png"
        fingerprint_index = source.rindex('.') || -1
        String.new(source).insert(fingerprint_index, "-fp-#{asset_fingerprint}")
      end
      
      # Replaces the Rails method of the same name in AssetTagHelper.
      def rewrite_asset_path(source)
        asset_fingerprint = rails_asset_fingerprint(source)
        if :query_string == @@asset_fingerprint_strategy[:path]
          result = fingerprint_in_query_string(source, asset_fingerprint)
        elsif :file_name == @@asset_fingerprint_strategy[:path]
          result = fingerprint_in_file_name(source, asset_fingerprint)
        else
          raise RuntimeError.new "Unknown :path strategy '#{@@asset_fingerprint_strategy[:path]}'"
        end
        result = source if asset_fingerprint.blank?
        result
      end
      
      # Use this to set how fingerprints are calculated and how the
      # fingerprints are put into the asset path.
      # 
      # Default strategy is as follows:
      # {:fingerprint => :timestamp, :path => :query_string}
      #
      # Valid :fingerprint values are :timestamp, :md5
      # Valid :path values are :query_string, :file_name 
      def self.asset_fingerprint_strategy=(value)
        @@asset_fingerprint_strategy = value
      end
      
      @@asset_fingerprint_strategy = { :fingerprint => :timestamp, :path => :query_string }
      
      # This is where the asset fingerprint is calculated, where the path
      # argument is the path to the asset file.
      def calculate_asset_fingerprint(path)
        if :timestamp == @@asset_fingerprint_strategy[:fingerprint]
          return File.exist?(path) ? File.mtime(path).to_i.to_s : ''
        elsif :md5 == @@asset_fingerprint_strategy[:fingerprint]
          return Digest::MD5.hexdigest(File.read(path))
        else
          raise RuntimeError.new "Unknown :fingerprint strategy '#{@@asset_fingerprint_strategy[:fingerprint]}'"
        end
      end
    
    end
  end
end