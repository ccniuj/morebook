class Dashboard::Admin::BooksController < Dashboard::Admin::AdminController
  def index
    @books = @paginate = Book.includes(:tag).all.order('id DESC').paginate(:page => params[:page])
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
    params.require(:book).permit(:name, :descrition, :tag_id, :cover)
  end
end
