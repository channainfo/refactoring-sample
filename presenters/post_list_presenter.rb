class PostListPresenter
  def initialize(@options)
    @options = options

    # @posts = Post.active.include(:author)

    # @posts_categories = []
    # @posts.each do |post|
    #   if get_categories.include?(post.category)
    #     @posts_categories << post.category
    #   end
    # end
    # if params[:before_date]
    #   @posts = Post.active.where("created_at > ?", params[:before_date])
    # end
    # if params[:q]
    #   @q = Posts.active.include(:author).ransack(params[:q])
    #   @posts = @q.result
    # end
    # @posts = @posts.page(params[:page]).per(20)
    # if @posts.count == 0
    #   redirect_to blog_index_path
    # end
  end

  def posts
    return @posts unless @posts.nil?

    # earger load category
    @posts = Post.active.includes(:author, :category)

    # @posts_categories = []
    # @posts.each do |post|
    #   if get_categories.include?(post.category)
    #     @posts_categories << post.category
    #   end
    # end

    # I would use q[created_at_gt] so we can avoiid this and use ransack instead.
    if @options[:before_date].present?
      @posts = Post.active.where("created_at > ?", params[:before_date])
    end

    
    @posts = @posts.ransack(params[:q]).result if params[:q].present?
    @posts = @posts.page(params[:page]).per(20)
  end

  def exists?
    posts.count > 0
  end

  def post_categories
    posts.select { |post| post.visible?}
  end
end