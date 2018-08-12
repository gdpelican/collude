import Topic from 'discourse/models/topic'

export default Topic.extend({
  changesets: {
    performed: [],
    submitted: [],
    confirmed: []
  }
})
