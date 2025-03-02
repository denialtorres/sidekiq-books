class RequestOrderFulfillmentJob
  include Sidekiq::Worker

  def perform(order_id)
    order = Order.find(order_id)
    OrderCreator.new.request_order_fulfillment(order)
  end
end