require 'asset_fingerprint/fingerprinter'
require 'asset_fingerprint/path_rewriter'

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
            path = AssetTagHelper.abs_path_to_asset(source)
            asset_fingerprint = AssetFingerprint.calculate_fingerprint(path)
            
            if AssetTagHelper.cache_asset_fingerprints
              @@asset_fingerprints_cache_guard.synchronize do
                @@asset_fingerprints_cache[source] = asset_fingerprint
              end
            end
    
            asset_fingerprint
          end
        end
      end
      
      def self.abs_path_to_asset(source)
        File.join(ASSETS_DIR, source)
      end
      
      # Replaces the Rails method of the same name in AssetTagHelper.
      def rewrite_asset_path(source)
        asset_fingerprint = rails_asset_fingerprint(source)
        AssetFingerprint.rewrite_asset_path(source, asset_fingerprint)
      end
       
    end
  end
end