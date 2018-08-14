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
  composer.set('changesets', {})

  let resolve = (data) => {
    console.log('resolving...')
    composer.set('changesets.performed', resolveChangeset(composer.changesets.performed, data.collusion.changeset))
    composer.set('changesets.submitted', resolveChangeset(composer.changesets.submitted, data.collusion.changeset))
    composer.set('changesets.confirmed', resolveChangeset(composer.changesets.confirmed, data.collusion.changeset))
    // TODO set composer.reply from composer.changesets.performed
  }

  messageBus().subscribe(`/collusions/${composer.get('topic.id')}`, resolve)
  ajax(`/collusions/${composer.get('topic.id')}`).then(resolve)
}

// push local changes to the server
let performCollusion = function(composer, changeset) {
  if (!composer.changesets) { return }

  console.log('performing change..')
  changeset = changeset || buildChangeset(composer.reply)
  composer.set('changesets.performed', resolveChangeset(composer.changesets.performed, changeset))

  Ember.run.debounce(this, () => {
    composer.set('changesets.submitted', composer.changesets.performed)

    ajax(`/collusions`, { type: 'POST', data: {
      id:        composer.get('topic.id'),
      changeset: changeset
    }}).then((confirmed) => {
      console.log('confirming change..')
      composer.set('changesets.confirmed', confirmed)
    })
  }, 1000)
}

let teardownCollusion = function(composer) {
  messageBus().unsubscribe(`/collusions/${composer.get('topic.id')}`)
}

let resolveChangeset = function(prev, next) {
  return next // TODO actually resolve changesets here
}

let buildChangeset = function(text) {
  return {
    length_before: 0,
    length_after: text.length,
    changes: text.split('')
  } // TODO I think this might be wrong
}

export { canCollude, setupCollusion, teardownCollusion, performCollusion }
