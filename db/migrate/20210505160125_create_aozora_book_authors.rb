class CreateAozoraBookAuthors < ActiveRecord::Migration[5.2]
  def change
    create_table :aozora_book_authors do |t|
      t.integer :aozora_author_id
      t.integer :aozora_book_id
      t.string :role

      t.timestamps
    end
    add_index :aozora_book_authors, :aozora_author_id
    add_index :aozora_book_authors, :aozora_book_id
    add_index :aozora_book_authors, :role
  end
end
