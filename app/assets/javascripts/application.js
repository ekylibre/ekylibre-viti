// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require webpack_bridge
//= require modernizr
//= require jquery
//= require jquery-ui/widgets/datepicker
//= require jquery-ui/i18n/datepicker-fr
// require jquery-ui/i18n/datepicker-ar
// require jquery-ui/i18n/datepicker-ja
//= require jquery-ui/widgets/dialog
//= require jquery-ui/widgets/slider
//= require jquery-ui/widgets/accordion
//= require jquery-ui/widgets/sortable
//= require jquery-ui/widgets/droppable
//= require jquery_ujs
//= require jquery.remotipart
//= require jquery.turbolinks
//= require flatpickr/dist/flatpickr
//= require flatpickr/dist/plugins/confirmDate/confirmDate
//= require flatpickr/dist/l10n/ar
//= require flatpickr/dist/l10n/de
//= require flatpickr/dist/l10n/es
//= require flatpickr/dist/l10n/fr
//= require flatpickr/dist/l10n/it
//= require flatpickr/dist/l10n/ja
//= require flatpickr/dist/l10n/pt
//= require flatpickr/dist/l10n/zh
//= require turbolinks
//= require active_list.jquery
//= require knockout
//= require_self
//= require i18n
//= require i18n/translations
//= require i18n/locale
//= require i18n/ext
//= require wice_grid
//= require wice_grid/settings
//= require ekylibre
//= require formize/behave
//= require form/dialog
//= require formize/observe
//= require form/scope
//= require form/dependents
//= require form/toggle
//= require form/dates
//= require form/links
//= require cocoon
//= require jquery/ext
//= require selector
//= require ui
//= require jstz
//= require heatmap
//= require geographiclib
//= require leaflet.js.erb
//= require leaflet/draw
//= require leaflet/fullscreen
//= require leaflet/providers
//= require leaflet/heatmap
//= require leaflet/measure
//= require leaflet/easy-button
//= require leaflet/modal
//= require leaflet/label
//= require d3
//= require d3/tip
//= require timeline-chart.js
//= require autosize
//= require plugins
//= require_tree .
//= require tour
//= require bootstrap-slider

//= require vue
//= require sortablejs/Sortable.min.js
//= require vuedraggable/dist/vuedraggable.js
//= require chart.js/dist/Chart.min.js
//= require vue-chartjs/dist/vue-chartjs.min.js

//= require ext-plugins/vuejs/vue-chartjs

// FIX Browser interoperability
// href function seems to be ineffective
$.rails.href = function (element) {
  return $(element).attr('href');
}

Turbolinks.enableTransitionCache();
Turbolinks.enableProgressBar();

$(document).ready(function() {
  L.Icon.Default.imagePath = '/assets';
  $(".snippet-content > ul > li").click(function(e) {
    localStorage.scrollTop = $('.inner').scrollTop();
  });
  $('.inner').animate({ scrollTop: localStorage.scrollTop }, 0);
  $(".collapse").click(function(){
    localStorage.clear();
  });
});
