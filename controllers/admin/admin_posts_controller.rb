class Admin::AdminPostsController < InheritedResources::Base

  layout 'admin'
  before_filter :require_login
  load_and_authorize_resource

  def index
    @post_list = ::Admin::PostListPresenter(user: current_user, page: params[:page])
  end

  def show
    post = Post.find(params[:id])
    @post_presenter = ::Admin::PostPresenter(post)
  end

  def refresh
    @posts = Post.order("id DESC")
    render :layout => false
  end

  def new
    post = Post.new
    @post_presenter = ::Admin::PostPresenter(post)
  end

  def create
    @post = Post.new(params[:post].merge(user_id: current_user.id))
    @menu_post_create = true
    @branches = Branch.order(:degree)
    @branches = @branches.delete_if{|x| !current_user.access_branches.include?(x.id)} if current_user.role == 'editor'
    @sections = Branch.find(params[:post][:branch_id]).sections.order(:degree)
    if @post.save
      expire_page controller: 'static', action: 'index' if @post.status == 'published'
      redirect_to admin_post_path(@post)
    else
      render 'new'
    end
  end

  def update
    @post = Post.find(params[:id])
    @post.update_attributes(params[:post].merge(:created_at => "#{params[:date_year]}-#{params[:date_month]}-#{params[:date_day]} #{params[:date_hour]}:#{params[:date_minute]}:00"))
    if params[:text]
      params[:text].each do |itm|
        Blocktext.find(itm[0]).update_attributes( :text => itm[1] )
      end
    end
    @errors = @post.errors.full_messages
    respond_to do |format|
      format.html { redirect_to :back }
      format.js
    end
  end

  def destroy
    post = Post.find(params[:id])
    post.comment_threads.each do |itm|
      itm.delete
    end
    post.delete
    respond_to do |format|
      format.html { redirect_to admin_posts_path, :flash => { :success => "#{t 'articles.controllers.destroy.flash.success', :name => @post.name}"} }
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
  
  # def get_categories
  #   Category.visible.all
  # end

end