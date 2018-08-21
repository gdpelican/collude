import { ajax } from 'discourse/lib/ajax'

let messageBus = function() {
  return Discourse.__container__.lookup('message-bus:main')
}

// returns whether a user may collaboratively edit this document
let canCollude = function(post) {
  return post.post_number == 1 // TODO: make this correct
}

// connect to server and request initial document
let setupCollusion = function(composer) {
  composer.set('changesets', {
    performed: emptyChangeset(),
    submitted: emptyChangeset(),
    confirmed: emptyChangeset()
  })

  let resolve = (data) => {
    composer.set('changesets.confirmed', data.collusion.changeset)
    composer.set('changesets.performed', resolveChangeset(composer.changesets.performed, composer.changesets.confirmed))
    composer.set('reply', buildText(composer.changesets.performed))
  }

  messageBus().subscribe(`/collusions/${composer.get('topic.id')}`, resolve)
  ajax(`/collusions/${composer.get('topic.id')}`).then(resolve)
}

// push local changes to the server
let performCollusion = function(composer) {
  if (!composer.changesets) { return }

  composer.set('changesets.performed', resolveChangeset(composer.changesets.performed, {
    length_before: 0,
    length_after:  composer.reply.length,
    changes:       composer.reply.split('')
  }))

  Ember.run.debounce(this, () => {
    composer.set('changesets.submitted', composer.changesets.performed)

    ajax(`/collusions`, { type: 'POST', data: {
      id:        composer.topic.id,
      changeset: composer.changesets.submitted
    }}).then((data) => {
      composer.set('changesets.confirmed', data.collusion.changeset)
    })
  }, 3000)
}

let teardownCollusion = function(composer) {
  messageBus().unsubscribe(`/collusions/${composer.get('topic.id')}`)
}

let resolveChangeset = function(prev, next) {
  return {
    length_before: prev.changes.length,
    length_after:  next.changes.length,
    changes:       _.range(next.changes.length).map((index) => {
      return (next.changes[index] == prev.changes[index] && index)           ||
             (typeof next.changes[index] == 'string' && next.changes[index]) ||
             (typeof prev.changes[index] == 'string' && prev.changes[index]) ||
             index
    })
  }
}

let buildText = function(changeset) {
  return changeset.changes.join('') // TODO this is also potentially quite wrong
}

let emptyChangeset = function() {
  return { length_before: 0, length_after: 0, changes: [] }
}

export { canCollude, setupCollusion, teardownCollusion, performCollusion }
