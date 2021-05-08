json.extract! @book, :id, :book_uid, :title, :title_yomi,
  :subtitle, :subtitle_yomi, :original_title, :font_kana_type,
  :copyright, :release_date, :last_modified, :created_at, :updated_at,
  :card_url, :text_url, :text_encoding, :html_url, :html_encoding, :wiki_url
json.show_book_url aozora_show_book_url(@book.id, format: :json)
json.authors do
  json.array! @book.aozora_book_authors do |book_author|
    author = book_author.aozora_author
    json.role book_author.role
    json.extract! author, :id, :author_uid, :full_name, :last_name, :first_name,
      :last_name_yomi, :first_name_yomi, :last_name_roman, :first_name_roman,
      :date_of_birth, :date_of_death, :outline, :aozora_url, :wiki_url
    json.show_author_url aozora_show_author_url(author.id, format: :json)
  end
end
