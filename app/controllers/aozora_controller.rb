class AozoraController < ApplicationController
  def books
    @q = AozoraBook.includes(:aozora_book_authors, :aozora_authors)
      .ransack(params[:q])
    @books = @q.result(distinct: true).order(title_sort: :asc)
      .page(params[:page]).per(20)
  end

  def authors
    @q = AozoraAuthor.includes(:aozora_book_authors, :aozora_books)
      .ransack(params[:q])
    @authors = @q.result(distinct: true)
      .order(last_name_sort: :asc, first_name_sort: :asc)
      .page(params[:page]).per(20)
  end
end
