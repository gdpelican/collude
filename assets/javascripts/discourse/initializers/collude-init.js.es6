import { withPluginApi } from 'discourse/lib/plugin-api'
import { setupCollusion, teardownCollusion, canCollude } from '../lib/collude'
import { default as computed, on } from 'ember-addons/ember-computed-decorators'

const COLLUDE_ACTION = 'colludeOnTopic'

export default {
  name: 'collude-button',
  initialize: function() {
    withPluginApi('0.8.6', (api) => {
      const siteSettings = api.container.lookup('site-settings:main')
      if (!siteSettings.collude_enabled) { return }

      api.addPostMenuButton('collude', (post) => {
        if (canCollude(post)) {
          return {
            action:   COLLUDE_ACTION,
            icon:     'handshake-o',
            title:    'collude.button_title',
            position: 'first'
          }
        }
      })

      api.modifyClass('component:scrolling-post-stream', {
        colludeOnTopic() { this.appEvents.trigger('collude-on-topic') }
      })

      api.modifyClass('controller:topic', {
        init() {
          this._super()
          this.appEvents.on('collude-on-topic', () => {
            if (this.model.isColluding) {
              teardownCollusion(this.model)
            } else {
              setupCollusion(this.model).then((data) => {
                let collusion = data.collusion
                this.get("composer").open({
                  topic:       this.model,
                  action:      COLLUDE_ACTION,
                  draftKey:    this.model.draft_key,
                  topicBody:   collusion.value
                })
              })
            }
          })
        },

        willDestroy() {
          this._super()
          this.appEvents.off('collude-on-topic')
        }
      })
    })
  }
}
