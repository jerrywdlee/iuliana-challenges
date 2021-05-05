require'csv'
require'open-uri'
require'tempfile'
require'zip'

class AozoraLoader
  class << self
    def load_aozora_data(zip_uri: nil, csv_parh: nil)
      if csv_parh
        read_aozora_data_csv(csv_parh) do |row|
          create_aozora_record(row)
        end
      else
        download_aozora_data_zip(uri: zip_uri) do |path|
          read_aozora_data_csv(path) do |row|
            create_aozora_record(row)
          end
        end
      end
    end

    def download_aozora_data_zip(uri: nil)
      if !uri
        uri = 'https://github.com/aozorabunko/aozorabunko/'
        uri += 'raw/master/index_pages/'
        uri += 'list_person_all_extended_utf8.zip'
      end

      Zip::File.open(open(uri)) do |zip|
        zip.each do |entry|
          if entry.name =~ /\.csv/
            puts "Extracting #{entry.name}"
            tf = Tempfile.open(entry.name)
            zip.extract(entry, tf.path) { true } # overwirte

            yield(tf.path)

            tf.close!
            break
          end
        end
      end
    end


    def read_aozora_data_csv(path)
      headers = {}.merge(book_header.invert, author_header.invert)
      opt = {
        headers: true,
        header_converters: lambda { |h| headers[h.to_s] || h.to_s },
      }

      cnt = 0
      CSV.foreach(path, opt) do |row|
        cnt += 1
        yield(row)
      end

      cnt
    end

    def create_aozora_record(row)
      ActiveRecord::Base.transaction do
        row_hash = row.to_hash
        row_hash[:book_uid] = row[0] # 「作品ID」にゴミが入っているので、正確にとれない
        book_params = row_hash.slice(*book_header.keys)
        author_params = row_hash.slice(*author_header.keys)
        book = AozoraBook.find_or_initialize_by(book_uid: book_params[:book_uid])
        book.assign_attributes(book_params)
        author = AozoraAuthor.find_or_initialize_by(author_uid: author_params[:author_uid])
        author.assign_attributes(author_params)
        author.set_full_name if author.id.blank?
        author.set_wiki_data if author.id.blank?

        book.save!
        author.save!

        book_author = AozoraBookAuthor.find_or_initialize_by(
          aozora_author_id: author.id,
          aozora_book_id: book.id,
          role: row_hash['役割フラグ']
        )
        book_author.save!
      end
    end

    def book_header
      {
        book_uid: "作品ID",
        title: "作品名",
        title_yomi: "作品名読み",
        title_sort: "ソート用読み",
        subtitle: "副題",
        subtitle_yomi: "副題読み",
        original_title: "原題",
        font_kana_type: "文字遣い種別",
        copyright: "作品著作権フラグ",
        release_date: "公開日",
        last_modified: "最終更新日",
        card_url: "図書カードURL",
        text_url: "テキストファイルURL",
        html_url: "XHTML/HTMLファイルURL",
        text_encoding: "テキストファイル符号化方式",
        html_encoding: "XHTML/HTMLファイル符号化方式",
      }
    end

    def author_header
      {
        author_uid: "人物ID",
        last_name: "姓",
        first_name: "名",
        last_name_yomi: "姓読み",
        first_name_yomi: "名読み",
        last_name_sort: "姓読みソート用",
        first_name_sort: "名読みソート用",
        last_name_roman: "姓ローマ字",
        first_name_roman: "名ローマ字",
        date_of_birth: "生年月日",
        date_of_death: "没年月日",
        copyright: "人物著作権フラグ",
      }
    end
  end
end
