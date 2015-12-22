class Dashboard::BooksController < Dashboard::DashboardController
  def index
    @books = @paginate = Book.joins(:tags).where(:user_id => current_user.id).uniq.order('id DESC').paginate(:page => params[:page])
  end

  def new
    @book = Book.new
  end

  def edit
    @book = Book.find(params[:id])
  end

  def create
    @book = Book.new(book_params)
    @book.user_id = current_user.id
    @book.save
    
    @book.save_image(params[:book][:image])

    params[:tags_id].size.times do |i|
      book_tag = BookTag.new(:book_id => @book.id,
                              :tag_id => params[:tags_id][i])
      book_tag.save
    end

    shelf_book = ShelfBook.new(:book_id => @book.id,
                                :shelf_id => params[:shelf_id])
    if shelf_book.save
      redirect_to dashboard_books_path
    else
      @book.destroy
    end
  end

  def update
    @book = Book.find(params[:id])
    
    BookTag.where(:book_id => @book.id).each {|bt|bt.destroy}
    params[:tags_id].size.times do |i|
      book_tag = BookTag.new(:book_id => @book.id,
                              :tag_id => params[:tags_id][i])
      book_tag.save
    end

    @shelf_book = ShelfBook.where(:book_id => @book.id).take
    if @book.update(book_params) && @shelf_book.update(:shelf_id => params[:shelf_id])
      redirect_to dashboard_books_path
    else
      render 'edit'
    end
  end

  def destroy
    @book = Book.find(params[:id])
    @book.destroy
    redirect_to dashboard_books_path
  end

  private
  def book_params
    params.require(:book).permit(:name, :description, :shelf_id, :author,
     :descripton, :isbn, :publisher, :publish_date, :language, :page)
  end
end
