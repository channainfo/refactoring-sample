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

  def breaking_news
    @posts = Post.active.breaking.page(params[:page]).per(20)
  end

  def update
    redirect_to posts_path if !current_user.admin?

    @post = Post.active.find(params[:id])

    if @post.update(post_params)
      redirection_to :index
    else
      render :update
    end
  end

  def preview
    @post = Post.active.find(params[:id])
  end

  def post_params
    params[:post].permit!
  end

  private
  def not_found_error
    render "errors/404.html", status: :not_found
  end
end