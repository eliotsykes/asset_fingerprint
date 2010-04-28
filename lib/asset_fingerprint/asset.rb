require 'asset_fingerprint/asset_files_served_by'
require 'asset_fingerprint/event_handling'
require 'asset_fingerprint/symlinker'
require 'asset_fingerprint/fingerprinter'
require 'asset_fingerprint/path_rewriter'

module AssetFingerprint
  
  DEFAULT_ASSET_PATHS = ['favicon.ico', 'images', 'javascripts', 'stylesheets']
  @@asset_paths = DEFAULT_ASSET_PATHS
    
  # Used for rake task to generate symlinks.
  #
  # Set asset_paths if you have different paths to those given in
  # DEFAULT_ASSET_PATHS. These are relative to the public/ directory and
  # can be filenames or directories. Directories will be searched recursively
  # when generating symlinks.
  def self.asset_paths=(value)
    @@asset_paths = value
  end
  
  def self.asset_paths
    @@asset_paths
  end
  
  class Asset
    
    def self.cache_enabled?
      if @@cache_enabled.nil?
        # Asset cache behaviour same as cache_asset_timestamps
        # if no value set. This is fine for most environments, you probably
        # don't need to change this.
        return ActionView::Helpers::AssetTagHelper.cache_asset_timestamps
      end
      @@cache_enabled
    end
    

    # You can enable or disable the asset cache.
    # With the cache enabled, the asset tag helper methods will make fewer
    # expensive calls. However this prevents you from modifying
    # any asset files while the server is running. Most people will
    # not need to set this as the default behaviour is sensible and tied
    # to AssetTagHelper.cache_asset_timestamps. It is safe to ignore this
    # setting.
    def self.cache_enabled=(value)
      @@cache_enabled = value
    end
    @@cache_enabled = nil
    
    @@cache = {}
    @@cache_guard = Mutex.new
    
    attr_accessor :source 
    
    PATH_TO_ASSETS = ActionView::Helpers::AssetTagHelper::ASSETS_DIR + File::SEPARATOR
    
    def self.absolute_path?(source_or_absolute_path)
      # Returns true if the given argument begins with the absolute path of the
      # assets dir.
      0 == source_or_absolute_path.index(PATH_TO_ASSETS)
    end
    
    def self.to_relative(absolute_path)
      absolute_path.sub(PATH_TO_ASSETS, '')
    end
    
    def self.normalize_to_source(source_or_absolute_path)
      if absolute_path?(source_or_absolute_path)
        source = to_relative(source_or_absolute_path)
      else
        source = source_or_absolute_path
      end
      source
    end
    
    def self.create(source_or_absolute_path)
      source = normalize_to_source(source_or_absolute_path)
      asset = @@cache[source] if cache_enabled?
      asset = Asset.new(source) if asset.nil?
      asset
    end
    
    def initialize(source)
      self.source = source
      if Asset.cache_enabled?
        @@cache_guard.synchronize do
          @@cache[source] = self
        end
      end
    end
    
    def self.absolute_path(relative_path)
      File.join(ActionView::Helpers::AssetTagHelper::ASSETS_DIR, relative_path)
    end
    
    def source_absolute_path
      @source_absoulte_path ||= Asset.absolute_path(source)
    end
    
    def fingerprinter
      AssetFingerprint.fingerprinter
    end
    
    def fingerprint
      @fingerprint ||= fingerprinter.fingerprint(self)
    end
    
    def path_rewriter
      AssetFingerprint.path_rewriter
    end
    
    def populate_fingerprinted_path
      if fingerprint.blank?
        self.fingerprinted_path = source
      else
        path_rewriter.populate_fingerprinted_path(self)
      end
    end
    
    def fingerprinted_path=(value)
      @fingerprinted_path = value
    end
    
    def fingerprinted_path
      populate_fingerprinted_path unless @fingerprinted_path
      @fingerprinted_path
    end
    
    def fingerprinted_absolute_path
      @fingerprinted_absolute_path ||= Asset.absolute_path(fingerprinted_path)
    end
    
    def build_symlink
      AssetFingerprint::Symlinker.execute(self)
    end
    
    def build_symlink_on_the_fly
      AssetFingerprint::Symlinker.symlink_on_the_fly(self)
    end
    
    def symlinkable?
      (AssetFingerprint.path_rewriter.fingerprinted_paths_symlinkable? &&
        AssetFingerprint.asset_files_served_by_symlink?)
    end
    
    def self.generate_all_symlinks
      AssetFingerprint.asset_paths.each do |source|
        absolute_path = Asset.absolute_path(source)
        generate_symlinks(absolute_path)
      end
    end
    
    def self.generate_symlinks(path)
      if File.file?(path)
        asset = Asset.create(path)
        asset.build_symlink
      elsif File.directory?(path)
        Dir[File.join(path, '*')].each do |file_or_dir|
          generate_symlinks(file_or_dir)
        end
      end
    end
    
  end
  
end
