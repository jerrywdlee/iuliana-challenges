json.books do
  json.array! @books do |book|
    json.extract! book, :id, :book_uid, :title, :title_yomi,
      :subtitle, :subtitle_yomi, :card_url, :text_url
    json.wiki_url book.wiki_url
    json.authors do
      json.array! book.aozora_book_authors do |book_author|
        json.author_uid book_author.aozora_author.author_uid
        json.name book_author.aozora_author.full_name
        json.role book_author.role
        json.wiki_url book_author.aozora_author.wiki_url
      end
    end
  end
end

json.total_pages @books.total_pages
json.current_page @books.current_page
json.limit_per_page @books.limit_value
json.total_count @books.total_count
