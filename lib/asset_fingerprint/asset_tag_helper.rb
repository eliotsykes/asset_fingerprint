require 'asset_fingerprint/asset'

module ActionView
  module Helpers
    module AssetTagHelper
      
      # Replaces the Rails method of the same name in AssetTagHelper.
      def rewrite_asset_path(source)
        AssetFingerprint.rewrite_asset_path(source)
      end
      
      # Allows AssetFingerprint to do any handling it needs to if a new
      # asset file is created at runtime.
      def write_asset_file_contents_with_fire_new_asset_file_event(joined_asset_path, asset_paths)
        write_asset_file_contents_without_fire_new_asset_file_event(joined_asset_path, asset_paths)
        AssetFingerprint.fire_new_asset_file_event(joined_asset_path)
      end
      alias_method_chain :write_asset_file_contents, :fire_new_asset_file_event
     
    end
  end
end
