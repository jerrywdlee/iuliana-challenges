json.books do
  json.array! @books do |book|
    json.extract! book, :id, :book_uid, :title, :title_yomi,
      :subtitle, :subtitle_yomi, :card_url, :text_url, :wiki_url
    json.show_book_url aozora_show_book_url(book.id, format: :json)
    json.authors do
      json.array! book.aozora_book_authors do |book_author|
        author = book_author.aozora_author
        json.extract! author, :id, :author_uid, :full_name
        json.role book_author.role
        json.wiki_url author.wiki_url
        json.show_author_url aozora_show_author_url(author.id, format: :json)
      end
    end
  end
end

json.total_pages @books.total_pages
json.current_page @books.current_page
json.limit_per_page @books.limit_value
json.total_count @books.total_count
