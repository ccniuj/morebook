class Dashboard::Admin::BooksController < Dashboard::Admin::AdminController
  def index
    @books = @paginate = Book.includes(:tags).all.order('id DESC').paginate(:page => params[:page])
  end

  def new
    @book = Book.new
  end

  def edit
    @book = Book.find(params[:id])
  end

  def create
    @book = Book.new(book_params)
    @book.save
    redirect_to dashboard_admin_books_path
  end

  def update
    @book = Book.find(params[:id])

    BookTag.where(:book_id => @book.id).each {|bt|bt.destroy}
    params[:tags_id].size.times do |i|
      book_tag = BookTag.new(:book_id => @book.id,
                              :tag_id => params[:tags_id][i])
      book_tag.save
    end

    if @book.update(book_params)
      redirect_to dashboard_admin_books_path
    else
      render 'edit'
    end
  end

  def destroy
    @book = Book.find(params[:id])
    @book.destroy
    redirect_to dashboard_admin_books_path
  end

  private
  def book_params
    params.require(:book).permit(:name, :description, :tag_id, :cover,
     :author, :descripton, :isbn, :publisher, :publish_date, :language, :page)
  end
end
