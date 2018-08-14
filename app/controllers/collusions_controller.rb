class CollusionsController < ApplicationController
  def show
    render json: CollusionSerializer.new(load_post.latest_collusion).as_json
  end

  def create
    if create_collusion.persisted?
      json = CollusionSerializer.new(create_collusion).as_json
      MessageBus.publish "/collusions/#{load_post.id}", json
      render json: json
    else
      render json: create_collusion.errors, status: :unprocessable_entity
    end
  end

  private

  def create_collusion
    @collusion ||= Collusion.create(
      user:      current_user,
      post:      load_post,
      version:   load_post.max_collusion_version + 1,
      changeset: next_changeset.to_json,
      value:     next_changeset.apply_to(load_post.latest_collusion.value)
    )
  end

  def next_changeset
    @next ||= load_post.latest_collusion.changeset.compose_with(changeset_param)
  end

  def load_post
    @post ||= Post.find_by(post_number: 1, topic_id: params.require(:id))
  end

  def changeset_param
    Changeset.new(params.require(:changeset))
  end
end
