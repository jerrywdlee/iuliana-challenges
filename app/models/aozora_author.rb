require 'open-uri'
require 'nokogiri'

class AozoraAuthor < ApplicationRecord
  has_many :aozora_book_authors
  has_many :aozora_books, through: :aozora_book_authors

  enum copyright: {
    'あり' => true,
    'なし' => false,
  }

  def set_full_name
    reg = /[ァ-ヴー]+/
    self.full_name = if last_name =~ reg && first_name =~ reg
      "#{first_name}・#{last_name}"
    else
      "#{last_name}#{first_name}"
    end
  end

  def set_wiki_data
    url = "https://www.aozora.gr.jp/index_pages/person#{author_uid.to_i}.html"

    charset = 'utf-8'
    html = open(url) { |f| f.read }

    doc = Nokogiri::HTML.parse(html, nil, charset)

    data_cell = doc.at_css('[summary="作家データ"] tr:last td:last')
    link = doc.at_css('[summary="作家データ"] tr:last td:last a:last')

    self.outline = data_cell&.text&.gsub("「#{link&.text}」", '').presence
    self.wiki_url = link&.attribute('href')&.value
  end
end
