#---
# Excerpted from "Ruby on Rails Background Jobs with Sidekiq",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/dcsidekiq for more book information.
#---
require "test_helper"

class OrderCreatorTest < ActiveSupport::TestCase
  setup do
    @order_creator = OrderCreator.new
  end

  test "create_order charge succeeds" do
    order = Order.create!(
      email: "pat@example.com",
      address: "123 Main St",
      quantity: 2,
      product: create(:product, quantity_remaining: 3),
      user: create(:user),
    )

    resulting_order = @order_creator.create_order(order)
    assert_equal order, resulting_order, "should return the same order"
    Sidekiq::Job.drain_all
    resulting_order.reload
    assert resulting_order.charge_successful
    assert_nil resulting_order.charge_decline_reason
    refute_nil resulting_order.charge_id
    refute_nil resulting_order.email_id
    refute_nil resulting_order.fulfillment_request_id
  end

  test "send_notification_email uses existing email" do
    email_service_wrapper = EmailServiceWrapper.new

    order = Order.create!(
      email: "pat@example.com",
      address: "123 Main St",
      quantity: 1,
      product: create(:product),
      user: create(:user),
    )

    # pretent the email was sent in a previous job
    previously_sent_email = email_service_wrapper.send_email(
      order.email,
      OrderCreator::CONFIRMATION_EMAIL_TEMPLATE_ID,
      {
        order_id: order.id
      }
    )

    email_id = previously_sent_email.email_id
    refute_nil email_id, "expected an email to have been send"

    # Grab a count of the emails matching before running the test
    matching_emails = email_service_wrapper.search_emails(
      order.email,
      OrderCreator::CONFIRMATION_EMAIL_TEMPLATE_ID
    )

    num_matching_emails = matching_emails.count

    # Test starts here
    @order_creator.send_notification_email(order)
    order.reload

    assert_equal email_id, order.email_id,
      "A different email was sent thant the previosly-sent one"

    # Re-fetch the emails so we can count them
    matching_emails = email_service_wrapper.search_emails(
      order.email,
      OrderCreator::CONFIRMATION_EMAIL_TEMPLATE_ID
    )

    assert_equal num_matching_emails, matching_emails.count, "An email was sent that should have been"
  end
end
