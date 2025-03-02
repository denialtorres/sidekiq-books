class CompleteOrderJob
  include Sidekiq::Worker

  sidekiq_options queue: "high"

  def perform(order_id)
    sleep(rand * 2.0)
    order = Order.find(order_id)
    OrderCreator.new.complete_order(order)
  end
end