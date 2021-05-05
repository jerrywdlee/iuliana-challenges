class CreateAozoraAuthors < ActiveRecord::Migration[5.2]
  def change
    create_table :aozora_authors do |t|
      t.string :author_uid
      t.string :last_name
      t.string :first_name
      t.string :full_name
      t.string :last_name_yomi
      t.string :first_name_yomi
      t.string :last_name_sort
      t.string :first_name_sort
      t.string :last_name_roman
      t.string :first_name_roman
      t.date :date_of_birth
      t.date :date_of_death
      t.boolean :copyright
      t.text :outline
      t.text :wiki_url

      t.timestamps
    end
    add_index :aozora_authors, :author_uid
    add_index :aozora_authors, :last_name
    add_index :aozora_authors, :first_name
    add_index :aozora_authors, :full_name
    add_index :aozora_authors, :last_name_yomi
    add_index :aozora_authors, :first_name_yomi
    add_index :aozora_authors, :last_name_sort
    add_index :aozora_authors, :first_name_sort
    add_index :aozora_authors, :last_name_roman
    add_index :aozora_authors, :first_name_roman
  end
end
