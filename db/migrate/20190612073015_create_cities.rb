class CreateCities < ActiveRecord::Migration[5.2]
  def change
    create_table :cities do |t|
      t.string :name

      t.timestamps
    end
    add_index :cities, :name
  end
end
