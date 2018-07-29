export default Ember.Object.create({
  _posts: {},
  _users: {},
  _bindings: [],

  bind(component, topic) {
    this._bindings.push([
      this.store(topic, '_topics', 'id').id,
      this.store(component, '_components', 'elementId').elementId
    ])
    return this.topicForComponent(component)
  },

  unbind(component) {
    let componentBinding = _.find(this._bindings, ([x, elementId]) => { return elementId == component.elementId })
    this._bindings = _.without(this._bindings, componentBinding)
  },

  store(model, cache, field, force = false) {
    if (force || !this[cache][model[field]]) { this[cache][model[field]] = model }
    return this[cache][model[field]]
  }
})
