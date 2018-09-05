import { withPluginApi } from 'discourse/lib/plugin-api'
import { default as computed, on, observes } from 'ember-addons/ember-computed-decorators'
import {
  setupCollusion,
  teardownCollusion,
  performCollusion
} from '../lib/collude'
import Composer from 'discourse/models/composer'

const COLLUDE_ACTION = 'colludeOnTopic'

export default {
  name: 'collude-button',
  initialize: function() {
    withPluginApi('0.8.6', (api) => {
      Composer.serializeOnCreate('collude')

      const siteSettings = api.container.lookup('site-settings:main')
      if (!siteSettings.collude_enabled) { return }

      api.includePostAttributes('collude')
      api.addPostMenuButton('collude', (post) => {
        if (!post.collude || !post.canEdit) { return }
        return {
          action:    COLLUDE_ACTION,
          icon:      'handshake-o',
          label:     'collude.collaborate',
          title:     'collude.button_title',
          className: 'collude create',
          position:  'last'
        }
      })

      api.modifyClass('component:scrolling-post-stream', {
        colludeOnTopic() { this.appEvents.trigger('collude-on-topic') }
      })

      api.modifyClass('model:composer', {
        creatingCollusion: Em.computed.equal("action", COLLUDE_ACTION)
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

        collapse() {
          if (this.get('model.action') == COLLUDE_ACTION) { return this.close() }
          return this._super()
        },

        close() {
          if (this.get('model.action') == COLLUDE_ACTION) { teardownCollusion(this.model) }
          return this._super()
        },

        @on('init')
        _listenForClose() {
          this.appEvents.on('composer:close', () => { this.close() })
        },

        @computed("model.whisper", "model.unlistTopic", "model.collude")
        whisperOrUnlistTopicText(whisper, unlistTopic, collude) {
          let _super   = this._super(whisper, unlistTopic)
          let _collude = collude && I18n.t('collude.option_indicator')
          return _.compact([_super, _collude]).join(', ')
        },

        @observes('model.reply')
        _handleCollusion() {
          if (this.get('model.action') == COLLUDE_ACTION) { performCollusion(this.model) }
        },

        _saveDraft() {
          if (this.get('model.action') == COLLUDE_ACTION) { return }
          return this._super()
        },

        actions: {
          makeCollusion() {
            this.set('model.collude', !this.model.collude)
          }
        }
      })

      api.addToolbarPopupMenuOptionsCallback(() => {
        return {
          action: "makeCollusion",
          icon: "handshake-o",
          label: "collude.option_title"
        };
      })
    })
  }
}
