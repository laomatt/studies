CarrierWave::Backgrounder.configure do |c|
  c.backend :sidekiq
end
