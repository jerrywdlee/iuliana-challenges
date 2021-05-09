class CreateAozoraBooks < ActiveRecord::Migration[5.2]
  def change
    create_table :aozora_books do |t|
      t.string :book_uid
      t.string :title
      t.string :title_yomi
      t.string :title_sort
      t.string :subtitle
      t.string :subtitle_yomi
      t.string :original_title
      t.string :font_kana_type
      t.boolean :copyright
      t.date :release_date
      t.date :last_modified
      t.string :card_url
      t.string :text_url
      t.string :html_url
      t.string :text_encoding
      t.string :html_encoding

      t.timestamps
    end
    add_index :aozora_books, :book_uid
    add_index :aozora_books, :title
    add_index :aozora_books, :title_yomi
    add_index :aozora_books, :title_sort
    add_index :aozora_books, :subtitle
    add_index :aozora_books, :subtitle_yomi
    add_index :aozora_books, :original_title
  end
end
