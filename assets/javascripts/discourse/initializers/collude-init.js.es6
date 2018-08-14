import { withPluginApi } from 'discourse/lib/plugin-api'
import { default as computed, on, observes } from 'ember-addons/ember-computed-decorators'
import {
  setupCollusion,
  teardownCollusion,
  performCollusion,
  canCollude
} from '../lib/collude'

const COLLUDE_ACTION = 'colludeOnTopic'

export default {
  name: 'collude-button',
  initialize: function() {
    withPluginApi('0.8.6', (api) => {
      const siteSettings = api.container.lookup('site-settings:main')
      if (!siteSettings.collude_enabled) { return }

      api.addPostMenuButton('collude', (post) => {
        if (!canCollude(post)) { return }
        return {
          action:   COLLUDE_ACTION,
          icon:     'handshake-o',
          title:    'collude.button_title',
          position: 'first'
        }
      })

      api.modifyClass('component:scrolling-post-stream', {
        colludeOnTopic() { this.appEvents.trigger('collude-on-topic') }
      })

      api.modifyClass('controller:topic', {
        init() {
          this._super()
          this.appEvents.on('collude-on-topic', () => {
            this.get('composer').open({
              topic:       this.model,
              action:      COLLUDE_ACTION,
              draftKey:    this.model.draft_key
            })
          })
        },

        willDestroy() {
          this._super()
          this.appEvents.off('collude-on-topic')
        }
      })

      api.modifyClass('controller:composer', {
        open(opts) {
          this._super(opts).then(() => {
            if (opts.action == COLLUDE_ACTION) { setupCollusion(this.model) }
          })
        },

        close() {
          if (this.model.action == COLLUDE_ACTION) { teardownCollusion(this.model) }
          return this._super()
        },

        @observes('model.reply')
        _handleCollusion() {
          if (this.model.action == COLLUDE_ACTION) { performCollusion(this.model) }
        },

        _saveDraft() {
          if (this.model.action == COLLUDE_ACTION) { return }
          return this._super()
        }
      })
    })
  }
}
