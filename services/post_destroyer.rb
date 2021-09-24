class PostDestroyer
  attr_accessor :post

  def self.call(post_id)
    destroyer = new(post_id)
    destroyer.call
    destroyer
  end

  def initialize(post_id)
    @post_id = post_id
  end

  def call
    ActiveRecord::Base.transaction do
      @post = Post.find(@post_id)
      @post.comment_threads.delete_all
      raise ActiveRecord::Rollback, "Failed to delete post" if @post.delete == 0
    end
  end
end