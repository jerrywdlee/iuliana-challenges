class AozoraController < ApplicationController
  before_action :authenticate_user!

  def books
    query = params[:q] || {}
    if params[:book_title]
      attrs = book_title_attrs
      query["#{attrs.join('_or_')}_cont".to_sym] = params[:book_title]
    end
    if params[:author_name]
      attrs = author_name_attrs.map { |k| "aozora_authors_#{k}" }
      query["#{attrs.join('_or_')}_cont".to_sym] = params[:author_name]
    end
    if params[:role]
      query[:aozora_book_authors_role_cont] = params[:role]
    end

    @q = AozoraBook.includes(:aozora_book_authors, :aozora_authors).ransack(query)
    @books = @q.result(distinct: true).order(title_sort: :asc)
      .page(params[:page]).per(20)
  end

  def authors
    query = params[:q] || {}
    if params[:book_title]
      attrs = book_title_attrs.map { |k| "aozora_books_#{k}" }
      query["#{attrs.join('_or_')}_cont".to_sym] = params[:book_title]
    end
    if params[:author_name]
      attrs = author_name_attrs
      query["#{attrs.join('_or_')}_cont".to_sym] = params[:author_name]
    end

    @q = AozoraAuthor.includes(:aozora_book_authors, :aozora_books)
      .ransack(query)
    @authors = @q.result(distinct: true)
      .order(last_name_sort: :asc, first_name_sort: :asc)
      .page(params[:page]).per(20)
  end

  def show_author
    @author = AozoraAuthor.find(params[:aozora_id])
  end

  def show_book
    @book = AozoraBook.find(params[:aozora_id])
  end

  private

  def book_title_attrs
    %w[title title_yomi title_sort subtitle subtitle_yomi original_title]
  end

  def author_name_attrs
    %w[
      full_name last_name first_name last_name_yomi first_name_yomi
      last_name_sort first_name_sort last_name_roman first_name_roman
    ]
  end
end
