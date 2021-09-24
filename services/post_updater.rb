class PostUpdater
  attr_accessor :post

  # post_params
  def initialize(options)
    @options = options
  end

  def call
    ActiveRecord::Base.transaction do
      @post = Post.find(params[:id])
      @post.update_attributes(@options)

      block_texts = options[:text] || []

      block_texts.each do |itm|
        unless Blocktext.find(itm[0]).update_attributes( :text => itm[1] )
          raise ActiveRecord::Rollback, "Failed to update"
        end
      end
    end
  end

  def self.call(fitler_update_params)
    updater = new(fitler_update_params)
    updater.call
    updater
  end
end