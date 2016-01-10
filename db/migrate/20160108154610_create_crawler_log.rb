class CreateCrawlerLog < ActiveRecord::Migration
  def change
    create_table :crawler_logs do |t|
      t.integer :trail_id
      t.string :url
      t.string :tag
      t.integer :iteration
      t.float :period
    end
  end
end
