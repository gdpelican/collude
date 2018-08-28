class CollusionsController < ApplicationController
  def show
    render json: CollusionSerializer.new(load_post.latest_collusion).as_json
  end

  def create
    if create_collusion.persisted?
      data = CollusionSerializer.new(create_collusion).as_json
      MessageBus.publish "/collusions/#{load_post.id}", data.to_json
      render json: data.to_json
    else
      render json: create_collusion.errors, status: :unprocessable_entity
    end
  end

  private

  def create_collusion
    @collusion ||= Collusion.spawn(post: load_post, user: current_user, changeset: Changeset.new(changeset_params))
  end

  def changeset_params
    params.require(:changeset).permit(:length_before, :length_after, changes: []).to_h.tap do |hash|
      hash[:length_before] = hash[:length_before].to_i
      hash[:length_after] = hash[:length_before].to_i
    end
  end

  def load_post
    @post ||= Post.find_by(post_number: 1, topic_id: params.require(:id))
  end
end
