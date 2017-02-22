class CreateAddresses < ActiveRecord::Migration[5.0]
  def change
    create_table :addresses do |t|
      t.string :street_address
      t.string :post_code
      t.string :kommun
      t.string :city
      t.string :country, default: 'Sveriges', null: false
      t.references :region, foreign_key: true
    end
  end
end
