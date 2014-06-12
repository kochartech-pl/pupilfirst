fog_credentials = if Rails.env.production? or Rails.env == 'staging'
  {
    provider: 'AWS',                                     # required
    aws_access_key_id: ENV['AWS_ACCESS_KEY_ID'],         # required
    aws_secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'], # required
    # region: ENV['S3_REGION'],                          # optional, defaults to 'us-east-1'
    host: 's3.amazonaws.com',                            # optional, defaults to nil
    # endpoint: 'https://s3.example.com:8080/'           # optional, defaults to nil
    path_style: true
  }
else
  {
    :provider   => 'Local',
    :local_root => "#{Rails.root}/public"
    # :endpoint   => 'http://192.168.1.165'
  }
end

CarrierWave.configure do |config|
  config.fog_credentials = fog_credentials

  config.fog_public     = true                                   # optional, defaults to true
  config.fog_attributes = {'Cache-Control'=>'max-age=315576000'}  # optional, defaults to {}
  config.cache_dir = "#{Rails.root}/tmp/uploads"                  # To let CarrierWave work on heroku

  config.fog_directory    = ENV['S3_BUCKET_NAME'] || "svapp-#{Rails.env.to_s}"
  # config.asset_host         = "https://#{ENV["S3_BUCKET_NAME"]}.s3.amazonaws.com/#{ENV['S3_BUCKET_NAME']}"
  config.asset_host         = ENV['ASSET_HOST']
  # For testing, upload files to local `tmp` folder.
  if Rails.env.production?
    config.storage = :fog
  else
    config.storage = :file
    config.root = "#{Rails.root}/public"
  end
  if Rails.env.test? || Rails.env.cucumber?
    config.storage = :file
    config.enable_processing = false
  end
end

if Rails.env.test? || Rails.env.cucumber?
  # make sure our uploader is auto-loaded
  AvatarUploader
  FeedImageUploader
end
