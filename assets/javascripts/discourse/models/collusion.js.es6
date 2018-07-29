import Topic from 'discourse/models/topic'

const Collusion = Topic.extend({
  changesets: {
    performed: [],
    submitted: [],
    confirmed: []
  }
})

export default Collusion
