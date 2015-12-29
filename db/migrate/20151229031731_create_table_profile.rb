class CreateTableProfile < ActiveRecord::Migration
  def change
    create_table :profiles, {:id => false } do |t|
      t.integer :user_id, :null => false
      t.string :name
      t.string :name_ch
      t.string :email
      t.string :number
      t.string :address

      t.timestamps
    end
  end
end
