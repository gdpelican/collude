import { headerHeight } from 'discourse/components/site-header'

let expandCollusion = function() {
  Ember.run.scheduleOnce('afterRender', () => {
    const $colluder = $('#reply-control.open')
    $colluder.height($(window).height() - headerHeight())
    $colluder.find('.save-or-cancel').remove()
    $colluder.find('.submit-panel > span').css('flex-basis', '50%')
  })
}

export { expandCollusion }
