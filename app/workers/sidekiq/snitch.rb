require 'sidekiq'
require 'net/http'

# A worker to contact deadmanssnitch.com periodically,
# thereby ensuring jobs are being performed and the system
# is healthy.
module Sidekiq
  class Snitch
    include Sidekiq::Worker

    def perform
      if ENV['SIDEKIQ_SNITCH_URL'].present?
        Net::HTTP.get(URI(ENV['SIDEKIQ_SNITCH_URL']))

        #https://github.com/imme5150/sidekiq_snitch/commit/560b19422464f62676a966e2f503bbe22d08f6bd
        already_scheduled = Sidekiq::ScheduledSet.new.any? {|job| job.klass == "Sidekiq::Snitch" }
        # groundhog day!
        Snitch.perform_in(10.minutes) unless already_scheduled
      end
    end
  end
end
