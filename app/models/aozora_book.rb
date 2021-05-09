class AozoraBook < ApplicationRecord
  has_many :aozora_book_authors
  has_many :aozora_authors, through: :aozora_book_authors

  enum copyright: {
    'あり' => true,
    'なし' => false,
  }

  def wiki_url
    "https://ja.wikipedia.org/wiki/#{title}"
  end
end
