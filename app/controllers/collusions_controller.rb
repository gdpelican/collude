class CollusionsController < ApplicationController
  def show
    render json: CollusionSerializer.new(load_post.latest_collusion).as_json
  end

  def create
    if create_collusion.persisted?
      data = CollusionSerializer.new(create_collusion, scope: current_user).as_json
      MessageBus.publish "/collusions/#{load_post.topic_id}", data
      Collude::Scheduler.new(load_post).schedule!
      render json: data.to_json
    else
      render json: create_collusion.errors, status: :unprocessable_entity
    end
  end

  def toggle
    load_post.custom_fields['collude'] = !load_post.custom_fields['collude']
    load_post.save
    render json: { success: :ok }
  end

  private

  def create_collusion
    @collusion ||= Collusion.spawn(post: load_post, user: current_user, changeset: Changeset.new(changeset_params))
  end

  def changeset_params
    params.require(:changeset).permit(:length_before, :length_after, changes: []).to_h.tap do |hash|
      hash[:length_before] = hash[:length_before].to_i
      hash[:length_after] = hash[:length_after].to_i
    end
  end

  def load_post
    @post ||= Post.find_by(post_number: 1, topic_id: params.require(:id))
  end
end
