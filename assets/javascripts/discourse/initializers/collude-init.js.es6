import { withPluginApi } from 'discourse/lib/plugin-api'
import { isColluding, loadCollusion, canCollude } from '../lib/collude'
import { default as computed, on } from 'ember-addons/ember-computed-decorators'

const COLLUDE_ACTION = 'colludeOnTopic'

export default {
  name: 'collude-button',
  initialize: function() {
    withPluginApi('0.8.6', (api) => {
      const siteSettings = api.container.lookup('site-settings:main')
      if (!siteSettings.collude_enabled) { return }

      api.addPostMenuButton('collude', (post) => {
        if (canCollude(post) && !isColluding(post)) {
          return {
            action: 'colludeOnTopic',
            icon: (isColluding(post) ? 'hand-paper-o' : 'handshake-o'),
            title: 'collude.button_title',
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
            loadCollusion(this.model).then((collusion) => {
              this.get("composer").open({
                topic:       collusion,
                action:      COLLUDE_ACTION,
                draftKey:    collusion.draftKey,
                topicBody:   collusion.body()
              })
            })
          })
        },

        willDestroy() {
          this._super()
          this.appEvents.off('collude-on-topic')
        }
      })

      api.decorateWidget('post-contents:after-cooked', (helper) => {
        let post = helper.getModel()
        return isColluding(post) ? helper.attach('collude-textarea', { post }) : null
      })
    })
  }
}
