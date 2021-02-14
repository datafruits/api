class CreateUserFollows < ActiveRecord::Migration[5.0]
  def change
    create_table :user_follows do |t|
      t.references :user, null: false
      t.references :followee, null: false

      t.timestamps
    end
  end
end
