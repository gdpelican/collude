PostsController.class_eval do
  def collude
    # responds with current state of document
  end

  def perform_collusion
    # note revision number of passed changeset
    # create a new changeset
    # broadcast new changeset to all clients
    # add changeset to list of revisions by requestor
    # respond with ACK to requestor
  end
end
