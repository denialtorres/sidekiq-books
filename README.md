For this class

```ruby
class OrderCreator

  CONFIRMATION_EMAIL_TEMPLATE_ID = "order-confirmation"

  def create_order(order)
    if order.save
      payments_response = charge(order)
      if payments_response.success?

        email_response       = send_email(order)
        fulfillment_response = request_fulfillment(order)

        order.update!(
          charge_id: payments_response.charge_id,
          charge_completed_at: Time.zone.now,
          charge_successful: true,
          email_id: email_response.email_id,
          fulfillment_request_id: fulfillment_response.request_id)
      else
        order.update!(
          charge_completed_at: Time.zone.now,
          charge_successful: false,
          charge_decline_reason: payments_response.explanation
        )
      end
    end
    order
  end

private

  def charge(order)
    charge_metadata = {}
    charge_metadata[:order_id] = order.id
    # If you place idempotency_key into the metadata, it
    # will pass it to the service.
    #
    #   idempotency_key: "idempotency_key-#{order.id}",
    #
    payments.charge(
      order.user.payments_customer_id,
      order.user.payments_payment_method_id,
      order.quantity * order.product.price_cents,
      charge_metadata
    )
  end

  def send_email(order)
    email_metadata = {}
    email_metadata[:order_id] = order.id
    email_metadata[:subject] = "Your order has been received"
    email.send_email(
      order.email,
      CONFIRMATION_EMAIL_TEMPLATE_ID,
      email_metadata
    )
  end

  def request_fulfillment(order)
    fulfillment_metadata = {}
    fulfillment_metadata[:order_id] = order.id
    fulfillment.request_fulfillment(
      order.user.id,
      order.address,
      order.product.id,
      order.quantity,
      fulfillment_metadata
    )
  end

  def payments    = PaymentsServiceWrapper.new
  def email       = EmailServiceWrapper.new
  def fulfillment = FulfillmentServiceWrapper.new

end
```


The methods `charge`, `send_email` and `request_fulfillment` wrap the calls to those threes services


We can think about the process as having two parts,

1. The first validates the order and create it
2. The second part is to handle payments, email and order fulfillment (and the user does not have to wait for that)


Lets change the logic of second part by moving this to a background job `CompleteOrderJob`

```ruby
 class CompleteOrderJob
 include Sidekiq::Job

 def perform(order_id)
  order = Order.find(order_id)
  OrderCreator.new.complete_order(order)
end
```