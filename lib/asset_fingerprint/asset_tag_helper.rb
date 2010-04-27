require 'asset_fingerprint/asset'

module ActionView
  module Helpers
    module AssetTagHelper
      
      # Replaces the Rails method of the same name in AssetTagHelper.
      def rewrite_asset_path(source)
        AssetFingerprint.rewrite_asset_path(source)
      end
       
    end
  end
end
