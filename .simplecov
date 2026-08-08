SimpleCov.cover "app/**/*.rb"
SimpleCov.no_default_skips
SimpleCov.skip "/config/"
SimpleCov.skip "/db/migrate/"
SimpleCov.skip "/db/schema.rb"
SimpleCov.skip "/db/seeds.rb"
SimpleCov.skip "/test/"
SimpleCov.merge_timeout 86400
