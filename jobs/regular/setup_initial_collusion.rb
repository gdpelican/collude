module Jobs
  class SetupInitialCollusion < Jobs::Base
    def execute(args)
      return unless post = Post.find_by(id: args[:post_id])
      return unless post.can_collude?
      post.setup_initial_collusion!
    end
  end
end
