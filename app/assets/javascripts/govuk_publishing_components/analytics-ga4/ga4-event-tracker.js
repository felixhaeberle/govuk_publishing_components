//= require ../vendor/polyfills/closest.js
window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {};

(function (Modules) {
  'use strict'

  function Ga4EventTracker (module) {
    this.module = module
    this.trackingTrigger = 'data-ga4-event' // elements with this attribute get tracked
  }

  Ga4EventTracker.prototype.init = function () {
    var consentCookie = window.GOVUK.getConsentCookie()

    if (consentCookie && consentCookie.settings) {
      this.startModule()
    } else {
      this.startModule = this.startModule.bind(this)
      window.addEventListener('cookie-consent', this.startModule)
    }
  }

  // triggered by cookie-consent event, which happens when users consent to cookies
  Ga4EventTracker.prototype.startModule = function () {
    if (window.dataLayer) {
      this.module.addEventListener('click', this.trackClick.bind(this), true) // useCapture must be true
    }
  }

  Ga4EventTracker.prototype.trackClick = function (event) {
    var target = window.GOVUK.analyticsGa4.core.trackFunctions.findTrackingAttributes(event.target, this.trackingTrigger)
    if (target) {
      try {
        var data = target.getAttribute(this.trackingTrigger)
        data = JSON.parse(data)
      } catch (e) {
        // if there's a problem with the config, don't start the tracker
        console.error('GA4 configuration error: ' + e.message, window.location)
        return
      }

      var text = data.text || event.target.textContent
      data.text = window.GOVUK.analyticsGa4.core.trackFunctions.removeLinesAndExtraSpaces(text)
      data.index = window.GOVUK.analyticsGa4.core.trackFunctions.createIndexObject(data.index)

      var schemas = new window.GOVUK.analyticsGa4.Schemas()
      var schema = schemas.mergeProperties(data, 'event_data')

      /* Ensure it only tracks aria-expanded in an element with data-ga4-expandable on it. */
      if (target.closest('[data-ga4-expandable]')) {
        var ariaExpanded = this.getClosestAttribute(target, 'aria-expanded')
      }

      /*
        the details component uses an 'open' attribute instead of aria-expanded, so we need to check if we're on a details component.
        since details deletes the 'open' attribute when closed, we need this boolean, otherwise every element which
        doesn't contain an 'open' attr would be pushed to gtm as a closed element.
      */
      var detailsElement = target.closest('details')

      if (ariaExpanded) {
        schema.event_data.text = data.text || target.innerText
        schema.event_data.action = (ariaExpanded === 'false') ? 'opened' : 'closed'
      } else if (detailsElement) {
        schema.event_data.text = data.text || detailsElement.textContent
        var openAttribute = detailsElement.getAttribute('open')
        schema.event_data.action = (openAttribute == null) ? 'opened' : 'closed'
      }

      /* If a tab was clicked, grab the href of the clicked tab (usually an anchor # link) */
      var tabElement = event.target.closest('.gem-c-tabs')
      if (tabElement) {
        var aTag = event.target.closest('a')
        if (aTag) {
          var href = aTag.getAttribute('href')
          if (href) {
            schema.event_data.url = href
          }
        }
      }

      window.GOVUK.analyticsGa4.core.sendData(schema)
    }
  }

  // check if an attribute exists or contains the attribute
  Ga4EventTracker.prototype.getClosestAttribute = function (clicked, attribute) {
    var isAttributeOnElement = clicked.getAttribute(attribute)
    var containsAttribute = clicked.querySelector('[' + attribute + ']')

    if (isAttributeOnElement || isAttributeOnElement === '') { // checks for "" as some attribute names can contain no value making them falsy
      return isAttributeOnElement
    } else if (containsAttribute) {
      return containsAttribute.getAttribute(attribute)
    }
  }

  Modules.Ga4EventTracker = Ga4EventTracker
})(window.GOVUK.Modules)
