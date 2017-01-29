require 'sequel'
require 'chronic_duration'

DB = Sequel.connect(ENV['DATABASE_URL'] || 'postgres://localhost/bujin-retail') unless defined?(DB)
DB.extension(:pagination)

class EbayListing < Sequel::Model

  def time_remaining
    ChronicDuration.output(self.end_time - Time.now, format: :short).split(' ')[0..-2].join(' ')
  end

end
