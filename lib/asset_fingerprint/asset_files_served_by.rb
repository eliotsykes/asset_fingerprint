module AssetFingerprint
  
  # Valid values are :symlink, :server_rewrite
  @@asset_files_served_by = :symlink
  def self.asset_files_served_by=(value)
    @@asset_files_served_by = value
  end
  
  def self.asset_files_served_by
    @@asset_files_served_by
  end
  
  def self.asset_files_served_by_symlink?
    :symlink == asset_files_served_by
  end
  
  def self.asset_files_served_by_server_rewrite?
    :server_rewrite == asset_files_served_by
  end
  
end
