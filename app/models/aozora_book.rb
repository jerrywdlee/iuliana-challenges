class AozoraBook < ApplicationRecord
  has_many :aozora_book_authors
  has_many :authors, through: :aozora_book_authors

  enum copyright: {
    'あり' => true,
    'なし' => false,
  }
end
