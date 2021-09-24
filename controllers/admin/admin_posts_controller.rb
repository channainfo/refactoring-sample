class Admin::AdminPostsController < InheritedResources::Base

  layout 'admin'
  before_filter :require_login
  load_and_authorize_resource

  def index
    @post_list = ::Admin::PostListPresenter.new(user: current_user, page: params[:page])
  end

  def show
    post = Post.find(params[:id])
    @post_presenter = ::Admin::PostPresenter.new(post)
  end

  def refresh
    @posts = Post.order("id DESC")
    render :layout => false
  end

  def new
    post = Post.new
    @post_presenter = ::Admin::PostPresenter.new(post)
  end

  def create
    post = Post.new(params[:post].merge(user_id: current_user.id))
    if post.save
      expire_page controller: 'static', action: 'index' if post.status == 'published'

      redirect_to admin_post_path(post), notice: 'Post created successfully'
    else
      flash.now[:error] = "Failed to create post"
      @post_presenter =  ::Admin::PostPresenter.new(post)
      render 'new'
    end
  end

  def update
    @post_updater = PostUpdater.call(update_params)

    # can be just @post_updater.post.errors.full_messages
    @errors = @post_updater.post.errors.full_messages
    
    respond_to do |format|
      format.html { redirect_to :back }
      format.js
    end
  end

  def destroy
    destroyer = PostDestroyer.call(params[:id])
    respond_to do |format|
      format.html { redirect_to admin_posts_path, :flash => { :success => "#{t 'articles.controllers.destroy.flash.success', :name => destroyer.post.name}"} }
      format.js
    end
  end

  def upload
    @post = Post.find(params[:id])
    if @post.update_attributes( :photo => params[:file] )
      render :json => { 'success' => true, 'url' => "#{@post.photo.url(:middle)}#{@post.photo.updated_at}" }
    else
      render :json => { 'error' => @post.errors }
    end
  end

  def remove
    Post.find(params[:id]).update_attributes( :photo => nil )
    render :text => nil
  end

  def flush
    params[:items].each do |itm|
      Post.find(itm).destroy
    end
    render :text => 'success'
  end

  def search
    @posts = Post.where('name LIKE ?', '%'+params[:request]+'%')
    @posts = @posts.where('user_id = ?', current_user) unless current_user.role == 'admin'
    if @posts.size < 1
      render :text => 0
    else
      render :layout => false
    end
  end

  def selector
    @posts = Post.order("id DESC")
    @posts = @posts.where('user_id = ?', current_user) unless current_user.role == 'admin'
    @posts = @posts.where("status = ?", params[:status]) if params[:status] != 'all'
    @posts = @posts.where("branch_id = ?", params[:branch]) if  params[:branch] != 'all'
    render :layout => false
  end

  private

  def update_params
    # should add whitelisted params in the permit
    filter_params = params.require[:post].permit!

    created_at = Time.zone.local(params[:date_year], params[:date_month], params[:date_day], params[:date_hour], params[:date_minute], 0)
    filter_params.merge(created_at: created_at, id: params[:id])
  end
  
  # def get_categories
  #   Category.visible.all
  # end

end