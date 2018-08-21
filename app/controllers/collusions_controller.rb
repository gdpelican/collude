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
    @collusion ||= Collusion.spawn(post: load_post, user: current_user, changeset: Changeset.new(changeset_params))
  end

  def changeset_params
    params.require(:changeset).permit(:length_before, :length_after, changes: []).to_h
  end

  def load_post
    @post ||= Post.find_by(post_number: 1, topic_id: params.require(:id))
  end
end
