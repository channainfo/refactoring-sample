module Admin
  class PostPresenter
    def intialize(post)
      @post = post

      # @menu_post_create = true
      # @post = Post.find(params[:id])
      # @date = @post.created_at
      # @blocks = @post.blocks.order(:degree)
      # @branches = Branch.order(:degree)
      # @branches = @branches.delete_if{|x| !current_user.access_branches.include?(x.id)} if current_user.role == 'editor'
      # @sections = @post.branch.sections.order(:degree)
    end

    def menu_post_create
      true
    end

    def date
      @post.created_at
    end

    def blocks
      @blocks ||= @post.blocks.order(:degree)
    end

    def branches
      @branches ||= Branch.with_user(:current_user)
    end

    def sections
      @sections ||= @post.branch.sections.order(:degree)
    end
  end
end