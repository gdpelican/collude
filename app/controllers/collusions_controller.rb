class CollusionsController < ApplicationController
  def show
    render json: CollusionSerializer.new(load_post.latest_collusion).as_json
  end

  def create
    json = CollusionSerializer.new(create_collusion).as_json
    MessageBus.publish "/collusions/#{load_post.id}", json
    render json: json
  end

  private

  def create_collusion
    @collusion ||= Collusion.create!(
      user:      current_user,
      post:      load_post,
      version:   load_post.maximum_version + 1,
      changeset: next_changeset.to_s,
      length:    next_changeset.length,
      value:     next_changeset.markdown
    )
  end

  def next_changeset
    @next ||= Changeset.synth(load_post.latest_collusion.changeset, params.require(:changeset))
  end

  def load_post
    @post ||= Post.find(params.require(:post_id))
  end
end
