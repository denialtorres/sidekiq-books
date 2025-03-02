require "factory_bot"

namespace :dev do
  desc "Load a bunch of jobs into sidekiq"
  task load_sidekiq: :environment do
    products = 10.times.map { FactoryBot.create(:product) }

    1_000.times do |i|
      order = FactoryBot.create(:order, product: products.sample)

      CompleteOrderJob.perform_async(order.id)
      sleep(rand * 2)
    end
  end
end