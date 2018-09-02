export default {
  actions: {
    endCollusion() {
      this.appEvents.trigger('composer:close')
    }
  }
}
