class Dashboard::BooksController < Dashboard::DashboardController
  def index
    @books = @paginate = Book.kept_by(current_user).uniq.order('id DESC').paginate(:page => params[:page])
  end

  def new
    @book = Book.new
  end

  def edit
    @book = Book.find(params[:id])
    @book_tag_list = @book.hierarchy_tag_hash.to_json

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
    shelves_id = params[:shelves_id]

    @book_tag_list = JSON.parse(params[:book_tag_list])
    tags_id = book_tag_filter(@book_tag_list)


    BookTag.where(:book_id => @book.id).each {|bt|bt.destroy}
    tags_id.each do |tag_id|
      book_tag = BookTag.new(:book_id => @book.id, :tag_id => tag_id)
      book_tag.save
    end

    Book.add_book_to_shelf(current_user, @book, shelves_id)

    if @book.update(book_params)
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

  def book_tag_filter(hash_arr)
    results = []
    queue = []
    hash_arr.each do |h|
      queue.push(h)
    end

    while queue.any?
      current = queue.shift

      children = current['nodes']
      unless children.nil?
        children.each do |children|
          queue.push(children)
        end
      end

      if current['state']['checked']
        results << current['tag_id']
      end
    end
    results
  end
end
