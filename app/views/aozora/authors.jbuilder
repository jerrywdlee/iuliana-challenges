json.authors do
  json.array! @authors do |author|
    json.extract! author, :id, :author_uid,
      :full_name, :last_name, :first_name,
      :last_name_yomi, :first_name_yomi,
      :last_name_roman, :first_name_roman,
      :date_of_birth, :date_of_death, :outline, :wiki_url
    json.show_author_url aozora_show_author_url(author.id, format: :json)
    json.books do
      json.array! author.aozora_book_authors do |book_author|
        book = book_author.aozora_book
        json.extract! book, :id, :book_uid, :title, :card_url
        json.role book_author.role
        json.show_book_url aozora_show_book_url(book.id, format: :json)
      end
    end
  end
end

json.total_pages @authors.total_pages
json.current_page @authors.current_page
json.limit_per_page @authors.limit_value
json.total_count @authors.total_count