class PostController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :not_found_error

  def show
    @post = Post.active.find_by!(slug: params[:slug])

    # no need to retain so many view var
    # @author = @post.author

    redirect_to posts_path if @post.author.inactive?
  end

  def index
    post_list = PostListPresenter.new(params)
    redirect_to blog_index_path if post_list.exist? 
  end

  def update
    redirect_to posts_path if !current_user.admin?
    @post = Post.active.find(params[:id])


    if @post.update(post_params)
      redirection_to :index, notice: 'Update successfully'
    else
      flash.now[:error] = "Failed to update"
      render :update
    end
  end

  # GET /posts/preview
  def preview
    @post = Post.active.find(params[:id])
  end

  # GET /posts/breaking_news
  def breaking_news
    @posts = Post.active.breaking.page(params[:page]).per(20)
  end

  private
  def not_found_error
    render "errors/404.html", status: :not_found
  end

  # it should whitelist the params for example: user_id is dangerous and bad client might send the wrong user_id
  def post_params
    filters = params.require(:post).permit!
    filters[:user_id] = current_user.id
  end
end