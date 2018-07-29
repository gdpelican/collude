import registry from './collude-registry'
import Collusion from '../models/collusion'
import { ajax } from 'discourse/lib/ajax'

// returns whether a user may collaboratively edit this document
let canCollude = function(post) {
  return post.post_number == 1
}

// returns whether a user is currently editing this document
let isColluding = function(post) {
  return registry._posts[post.id]
}

// connect to server and request initial document
let loadCollusion = function(topic) {
  let post = topic.get('postStream.posts')[0]
  if (!post || post.post_number != 1) { return }
  return ajax(`/posts/${post.id}/collude`).then((data) => {
    return new Collusion(data)
  })
}

// enter new text into the text field
let makeChange = function(changeset) {

}

// push local changes to the server
let submitChange = function(changeset) {

}

// receive server acknoledgement that the pushed changes have been applied
let confirmChange = function(changeset) {

}

// apply changes from other clients to the server
let acknowledgeChange = function(changeset) {

}

// disconnect from the editing engine
let desist = function(post) {
  delete registry._posts[post.id]
}

export { canCollude, isColluding, loadCollusion, makeChange, submitChange, confirmChange, acknowledgeChange, desist }
