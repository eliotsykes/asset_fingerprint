require 'asset_fingerprint/fingerprinter'
require 'asset_fingerprint/path_rewriter'

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
