class CreateUserSubscriptions < ActiveRecord::Migration[5.0]
  def change
    create_table :user_subscriptions do |t|
      t.string :stripe_customer_token
      t.string :last_4_digits
      t.integer :exp_month
      t.integer :exp_year

      t.integer :amount
      t.integer :tier
      t.references :user, null: false, index: true
      #t.references :radio, null: false, index: true

      t.timestamps
    end
  end
end
