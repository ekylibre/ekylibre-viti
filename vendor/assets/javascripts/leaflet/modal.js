/**
 * Leaflet modal control
 *
 * @license MIT
 * @author Alexander Milevski <info@w8r.name>
 * @preserve
 */

"use strict";

/**
 * "foo bar baz" -> ".foo.bar.baz"
 * @param  {String} classString
 * @return {String}
 */
Leaflet.DomUtil.classNameToSelector = function(classString) {
  return (' ' + classString).split(' ').join('.').replace(/^\s+|\s+$/g, '');
};

/**
 * Modal handler
 * @class   {Leaflet.Map.Modal}
 * @extends {Leaflet.Mixin.Events}
 * @extends {Leaflet.Handler}
 */
Leaflet.Map.Modal = Leaflet.Handler.extend( /** @lends {Leaflet.Map.Hadler.prototype} */ {

  includes: Leaflet.Mixin.Events,

  /**
   * @static
   * @type {Object}
   */
  statics: {
    BASE_CLS: 'leaflet-modal',
    HIDE: 'modal.hide',
    SHOW_START: 'modal.showStart',
    SHOW: 'modal.show',
    CHANGED: 'modal.changed'
  },

  /**
   * @type {Object}
   */
  options: {
    OVERLAY_CLS: 'overlay',
    MODAL_CLS: 'modal',
    MODAL_CONTENT_CLS: 'modal-content',
    INNER_CONTENT_CLS: 'modal-inner',
    SHOW_CLS: 'show',
    CLOSE_CLS: 'close',

    closeTitle: 'close',
    zIndex: 10000,
    transitionDuration: 300,

    wrapperTemplate: [
      '<div class="{OVERLAY_CLS}"></div>',
      '<div class="{MODAL_CLS}"><div class="{MODAL_CONTENT_CLS}">',
      '<span class="{CLOSE_CLS}" title="{closeTitle}">&times;</span>',
      '<div class="{INNER_CONTENT_CLS}">{_content}</div>',
      '</div></div>'
    ].join(''),

    template: '{content}',
    content: ''

  },

  /**
   * @constructor
   * @param  {Leaflet.Map}   map
   * @param  {Object=} options
   */
  initialize: function(map, options) {
    Leaflet.Handler.prototype.initialize.call(this, map);
    Leaflet.Util.setOptions(this, options);

    this._visible = false;

    var container = this._container =
      Leaflet.DomUtil.create('div', Leaflet.Map.Modal.BASE_CLS, map._container);
    container.style.zIndex = this.options.zIndex;
    container.style.position = 'absolute';
    this._map._controlContainer.appendChild(container);

    Leaflet.DomEvent
      .disableClickPropagation(container)
      .disableScrollPropagation(container);
    Leaflet.DomEvent.on(container, 'contextmenu', Leaflet.DomEvent.stopPropagation);

    this.enable();
  },

  /**
   * Add events and keyboard handlers
   */
  addHooks: function() {
    Leaflet.DomEvent.on(document, 'keydown', this._onKeyDown, this);
    this._map.on({
      modal: this._show
    }, this);
  },

  /**
   * Disable handlers
   */
  removeHooks: function() {
    Leaflet.DomEvent.off(document, 'keydown', this._onKeyDown, this);
    this._map.off({
      modal: this._show
    }, this);
  },

  /**
   * @return {Leaflet.Map.Modal}
   */
  hide: function() {
    this._hide();
    return this;
  },

  /**
   * @return {Boolean}
   */
  isVisible: function() {
    return this._visible;
  },

  /**
   * Show again, or just resize and re-position
   * @param  {Object=} options
   */
  update: function(options) {
    if (options) {
      this._show(options);
    } else {
      this._updatePosition();
    }
  },

  /**
   * @param {String} content
   */
  setContent: function(content) {
    this._getInnerContentContainer().innerHTML = content;
    this.update();
  },

  /**
   * Update container position
   */
  _updatePosition: function() {
    var content = this._getContentContainer();
    var mapSize = this._map.getSize();

    if (content.offsetHeight < mapSize.y) {
      content.style.marginTop = ((mapSize.y - content.offsetHeight) / 2) + 'px';
    } else {
      content.style.marginTop = '';
    }
  },

  /**
   * @param  {Object} options
   */
  _show: function(options) {
    if (this._visible) {
      this._hide();
    }
    options = Leaflet.Util.extend({}, this.options, options);

    this._render(options);
    this._setContainerSize(options);

    this._updatePosition();

    Leaflet.Util.requestAnimFrame(function() {
      var contentContainer = this._getContentContainer();
      Leaflet.DomEvent.on(contentContainer, 'transitionend', this._onTransitionEnd, this);
      Leaflet.DomEvent.disableClickPropagation(contentContainer);
      Leaflet.DomUtil.addClass(this._container, this.options.SHOW_CLS);

      if (!Leaflet.Browser.any3d) {
        Leaflet.Util.requestAnimFrame(this._onTransitionEnd, this);
      }
    }, this);

    var closeBtn = this._container.querySelector('.' + this.options.CLOSE_CLS);
    if (closeBtn) {
      Leaflet.DomEvent.on(closeBtn, 'click', this._onCloseClick, this);
    }

    var modal = this._container.querySelector('.' + this.options.MODAL_CLS);
    if (modal) {
      Leaflet.DomEvent.on(modal, 'mousedown', this._onMouseDown, this);
    }

    // callbacks
    if (typeof options.onShow === 'function') {
      this._map.once(Leaflet.Map.Modal.SHOW, options.onShow);
    }

    if (typeof options.onHide === 'function') {
      this._map.once(Leaflet.Map.Modal.HIDE, options.onHide);
    }

    // fire event
    this._map.fire(Leaflet.Map.Modal.SHOW_START, {
      modal: this
    });
  },

  /**
   * Show transition ended
   * @param  {TransitionEvent=} e
   */
  _onTransitionEnd: function(e) {
    var data = {
      modal: this
    };
    var map = this._map;
    if (!this._visible) {
      if (Leaflet.DomUtil.hasClass(this._container, this.options.SHOW_CLS)) {
        this._visible = true;
        map.fire(Leaflet.Map.Modal.SHOW, data);
      } else {
        map.fire(Leaflet.Map.Modal.HIDE, data);
      }
    } else {
      map.fire(Leaflet.Map.Modal.CHANGED, data);
    }
  },

  /**
   * @param  {Leaflet.MouseEvent} evt
   */
  _onCloseClick: function(evt) {
    Leaflet.DomEvent.stop(evt);
    this._hide();
  },

  /**
   * Render template
   * @param  {Object} options
   */
  _render: function(options) {
    this._container.innerHTML = Leaflet.Util.template(
      options.wrapperTemplate,
      Leaflet.Util.extend({}, options, {
        _content: Leaflet.Util.template(options.template, options)
      })
    );
    if (options.element) {
      var contentContainer = this._container.querySelector(
        Leaflet.DomUtil.classNameToSelector(this.options.MODAL_CONTENT_CLS));
      if (contentContainer) {
        contentContainer.appendChild(options.element);
      }
    }
  },

  /**
   * @return {Element}
   */
  _getContentContainer: function() {
    return this._container.querySelector(
      Leaflet.DomUtil.classNameToSelector(this.options.MODAL_CONTENT_CLS));
  },

  /**
   * Inner content, don't touch destroy button
   * @return {Element}
   */
  _getInnerContentContainer: function() {
    return this._container.querySelector(
      Leaflet.DomUtil.classNameToSelector(this.options.INNER_CONTENT_CLS))
  },

  /**
   * @param {Object} options
   * @param {Number} options.width
   * @param {Number} options.height
   */
  _setContainerSize: function(options) {
    var content = this._getContentContainer();

    if (options.width) {
      content.style.width = options.width + 'px';
    }

    if (options.height) {
      content.style.height = options.height + 'px';
    }
  },

  /**
   * Hide blocks immediately
   */
  _hideInternal: function() {
    this._visible = false;
    Leaflet.DomUtil.removeClass(this._container, this.options.SHOW_CLS);
  },

  /**
   * Hide modal
   */
  _hide: function() {
    if (this._visible) {
      this._hideInternal();

      if (!Leaflet.Browser.any3d) {
        Leaflet.Util.requestAnimFrame(this._onTransitionEnd, this);
      }
    }
  },

  /**
   * Mouse down on overlay
   * @param  {Leaflet.MouseEvent} evt
   */
  _onMouseDown: function(evt) {
    Leaflet.DomEvent.stop(evt);
    var target = (evt.target || evt.srcElement);
    if (Leaflet.DomUtil.hasClass(target, this.options.MODAL_CLS)) {
      this._hide();
    }
  },

  /**
   * Key stroke(escape)
   * @param  {KeyboardEvent} evt
   */
  _onKeyDown: function(evt) {
    var key = evt.keyCode || evt.which;
    if (key === 27) {
      this._hide();
    }
  }

});

// register hook
Leaflet.Map.addInitHook('addHandler', 'modal', Leaflet.Map.Modal);

Leaflet.Map.include( /** @lends {Leaflet.Map.prototype} */ {

  /**
   * @param  {Object} options
   * @return {Leaflet.Map}
   */
  openModal: function(options) {
    return this.fire('modal', options);
  },

  /**
   * @return {Leaflet.Map}
   */
  closeModal: function() {
    this.modal.hide();
    return this;
  }

});
