module Jobs
  class Collude < Jobs::Base
    sidekiq_options queue: 'normal'

    def execute(args)
      return unless @post = Post.find_by(id: args[:post_id])
      @post.update(raw: @post.latest_collusion.value)
      @post.publish_change_to_clients!(:revised)
      PostAlerter.new.after_save_post(@post)
    end
  end
end
