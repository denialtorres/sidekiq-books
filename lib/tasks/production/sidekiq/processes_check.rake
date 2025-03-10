require "pry"

namespace :production do
  namespace :sidekiq do
    desc "Alert if Sidekiq isn't running"
    task processes_check: :environment do

      processes_set = Sidekiq::ProcessSet.new
      if processes_set.size == 0
        ErrorCatcherServiceWrapper.new.notify("Sidekiq is not running!")
      end
    end
  end
end