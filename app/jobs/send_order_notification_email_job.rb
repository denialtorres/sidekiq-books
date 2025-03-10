class SendOrderNotificationEmailJob
  include Sidekiq::Worker

  def perform(order_id)
    order = Order.find(order_id)
    OrderCreator.new.send_notification_email(order)
  end
end