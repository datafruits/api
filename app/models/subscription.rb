class Subscription < ActiveRecord::Base
  has_paper_trail
  belongs_to :user

  attr_accessor :stripe_card_token, :coupon

  # might need this later
  #enum status: [:on_trial, :on_paid_plan, :trial_ended, :canceled]
  #
  enum tier: [:premium]

  def card_present?
    last_4_digits.present? && exp_month.present? && exp_year.present?
  end

  def save_without_payment
    save! if valid?
  end

  def save_with_free_trial!
    customer_attributes = { description: self.user.email, plan: self.plan.name }
    customer_attributes[:coupon] = coupon if coupon.present?
    if valid?
      customer = Stripe::Customer.create(customer_attributes)
      self.status = "on_trial"
      self.trial_ends_at = Time.at(customer.subscriptions.data.first.trial_end)
      self.stripe_customer_token = customer.id
      save!
    else
      raise ActiveRecord::RecordInvalid
    end
  rescue Stripe::InvalidRequestError => e
    logger.error "Stripe error while creating customer: #{e.message}"
    errors.add :base, "There was a problem with your credit card."
    raise e
  end

  def save_with_card(*)
    if valid?
      customer = Stripe::Customer.create(description: self.user.email, plan: plan_id, card: stripe_card_token)
      self.status = "on_paid_plan"
      self.stripe_customer_token = customer.id
      self.last_4_digits = customer.cards.first.last4
      self.exp_month = customer.cards.first.exp_month
      self.exp_year = customer.cards.first.exp_year
      save!
    end
  rescue Stripe::InvalidRequestError => e
    logger.error "Stripe error while creating customer: #{e.message}"
    errors.add :base, "There was a problem with your credit card."
    return false
  end

  def update_with_new_card attributes
    with_transaction_returning_status do
      assign_attributes(attributes)
      if valid?
        customer = Stripe::Customer.retrieve self.stripe_customer_token
        card = customer.sources.create source: stripe_card_token
        card.save
        customer.default_card = card.id
        customer.coupon = coupon if coupon.present?
        subscription = customer.subscriptions.first
        subscription.plan = self.plan.name
        customer.save
        subscription.save
        self.status = "on_paid_plan"
        self.stripe_customer_token = customer.id
        self.last_4_digits = customer.cards.first.last4
        self.exp_month = customer.cards.first.exp_month
        self.exp_year = customer.cards.first.exp_year
        save!
      end
    end
  rescue Stripe::InvalidRequestError => e
    logger.error "Stripe error while creating customer: #{e.message}"
    puts "Stripe error while creating customer: #{e.message}"
    errors.add :base, "There was an error saving your billing information: #{e.message}."
    return false
  end

  def cancel!
    self.canceled!
  end

  def cancel_stripe_subscription
    customer = Stripe::Customer.retrieve self.stripe_customer_token
    subscription = customer.subscriptions.data.first
    subscription.delete
  end
end
