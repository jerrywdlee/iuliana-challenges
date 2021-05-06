json.authors do
  json.array! @authors do |author|
    json.extract! author, :id, :author_uid,
      :full_name, :last_name, :first_name,
      :last_name_yomi, :first_name_yomi,
      :last_name_roman, :first_name_roman,
      :date_of_birth, :date_of_death, :outline, :wiki_url

    json.books do
      json.array! author.aozora_book_authors do |book_author|
        json.book_uid book_author.aozora_book.book_uid
        json.name book_author.aozora_book.title
        json.card_url book_author.aozora_book.card_url
        json.role book_author.role
      end
    end
  end
end

json.total_pages @authors.total_pages
json.current_page @authors.current_page
json.limit_per_page @authors.limit_value
json.total_count @authors.total_count
