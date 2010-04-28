module AssetFingerprint

  def self.fire_new_asset_file_event(path)
    # New asset file created, lets symlink to it
    (AssetFingerprint::Asset.create(path)).build_symlink
  end

end
