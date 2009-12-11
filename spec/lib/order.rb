class Order < ActiveRecord::Base
  belongs_to :ship_method
  belongs_to :cart
  has_many :products
end

class CreateOrders < ActiveRecord::Migration
  def self.up
    create_table :orders do |t|
      t.integer :ship_method_id
      t.binary  :frozen_ship_method
      t.binary  :frozen_products
      t.binary  :cart_id
    end
  end
  
  def self.down
    drop_table :orders
  end
end
