class Product < ActiveRecord::Base
end

class CreateProducts < ActiveRecord::Migration
  def self.up
    create_table :products do |t|
      t.string :name
    end
  end
  
  def self.down
    drop_table :orders
  end
end
