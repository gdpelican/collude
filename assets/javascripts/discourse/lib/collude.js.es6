import Collusion from '../models/collusion'
import { ajax } from 'discourse/lib/ajax'

let messageBus = function() {
  return Discourse.__container__.lookup('message-bus:main')
}

// returns whether a user may collaboratively edit this document
let canCollude = function(post) {
  return post.post_number == 1 // TODO: make this correct
}

// connect to server and request initial document
let setupCollusion = function(topic) {
  let post = firstPostFor(topic)
  if (!post) { return }

  return ajax(`/collusions/${post.id}`).then((data) => {
    topic.set('isColluding', true)
    messageBus().subscribe(`/collusions/${post.id}`, (changeset) => { makeChange(topic, changeset) })
    return new Collusion(data)
  })
}

// enter new text into the text field
let makeChange = function(topic, changeset) {
  let resolved = changeset // TODO: actually resolve from changesets.performed
  topic.set('changesets.performed', resolved)
}

// push local changes to the server
let submitChange = function(topic) {
  let post = firstPostFor(topic)
  if (!post) { return }

  topic.set('changesets.submitted', topic.changesets.performed)
  return ajax(`/collusions`, { type: 'POST', data: {
    post_id:   post.id,
    changeset: changeset
  }}).then((data) => {
    topic.set('changesets.confirmed', data)
  })
}

let teardownCollusion = function(topic) {
  let post = firstPostFor(topic)
  if (!post) { return }
  topic.set('isColluding', false)
  messageBus().unsubscribe(`/collusions/${post.id}`)
}

let firstPostFor = function(topic) {
  let post = topic.get('postStream.posts.0')
  if (post && post.post_number == 1) { return post }
}

export { canCollude, setupCollusion, teardownCollusion, makeChange, submitChange }
