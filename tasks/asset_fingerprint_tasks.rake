namespace :asset_fingerprint do

  namespace :symlinks do
    desc 'Generate the fingerprinted symlinks for all of the assets'
    task :generate => :environment do
      AssetFingerprint.generate_all_symlinks
      puts "Fingerprinted asset symlinks generated"
    end
  end

end
