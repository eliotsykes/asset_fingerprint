namespace :asset_fingerprint do

  namespace :symlinks do
    desc 'Generate the fingerprinted symlinks for all of the assets'
    task :generate => :environment do
      AssetFingerprint.generate_all_symlinks
      puts "Fingerprinted asset symlinks generated"
    end

    desc 'Removes the fingerprinted symlinks for all of the assets'
    task :purge => :environment do
      AssetFingerprint.remove_all_symlinks
      puts "Fingerprinted asset symlinks purged"
    end
  end

end
