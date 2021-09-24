module Admin
  class PostListPresenter

    # user:, :page
    def initialize(options)
      @options = options

      # @posts = Post.order("created_at DESC")
      # @posts = @posts.where('user_id = ?', current_user) unless current_user.role == 'admin'
      # @posts = @posts.paginate(:page => params[:page], :per_page => 20)
      # @posts_categories = []
      # @posts.each do |post|
      #   if get_categories.include?(post.category)
      #     @posts_categories << post.category
      #   end
      # end
      # @branches = Branch.order('degree')
      # @branches = @branches.delete_if{|x| !current_user.access_branches.include?(x.id)} if current_user.role == 'editor'
    end

    def posts
      return @posts unless @posts.nil?

      @posts = Post.includes(:category).order("created_at DESC")
      @posts = @posts.where('user_id = ?', @options[:user]) unless @options[:user].role == 'admin'
      @posts = @posts.paginate(page:  @options[:page], per_page: 20)
      @posts
    end

    def post_categories
      posts.select{|post| post.category.visible?}
    end


    def branches
      return @branches unless @branches.nil?

      @branches = Branch.order('degree')
     
      @branches = @branches.delete_if{|x| !@options[:user].access_branches.include?(x.id)}  if @options[:user].role == 'editor'
      @branches
    end
  end
end