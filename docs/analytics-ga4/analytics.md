# Google Analytics 4 and Google Tag Manager

This document describes the use of Google Tag Manager (GTM) with Google Analytics 4 (GA4) on GOV.UK Publishing.

No analytics code is initialised and no data is gathered without user consent.

## General approach

We pass three types of data to GA4.

- page views
- events
- search data

Page views happen when a page loads.

Events happen when a user interacts with certain things, for example clicking on an accordion, tab, or link.

Search data is gathered when users perform a search.

## Cookie consent

The analytics code is only loaded if users consent to cookies. This is managed by the `init-ga4.js` script.

If the page loads and cookie consent has already been given, the analytics code is initialised. This includes sending a page view and creating any event listeners for analytics code such as link tracking.

If the page loads and cookie consent has not been given, an event listener is created for the `cookie-consent` event, which is dispatched by the [cookie banner component](https://github.com/alphagov/govuk_publishing_components/pull/2041/commits/777a381d2ccb67f0a7e78ebf659be806d8d6442d). If triggered, the event listener will initialise the analytics code as described above. This allows analytics to begin on the page where the user consents to cookies.

## Code structure

It is important that no analytics code runs until cookie consent is given. Code to be initialised as part of cookie consent should be attached to the `window.GOVUK.analyticsGa4.analyticsModules` object and include an `init` function, using the structure shown below.

```JavaScript
window.GOVUK = window.GOVUK || {}
window.GOVUK.analyticsGa4 = window.GOVUK.analyticsGa4 || {}
window.GOVUK.analyticsGa4.analyticsModules = window.GOVUK.analyticsGa4.analyticsModules || {};

(function (analyticsModules) {
  'use strict'

  var ExampleCode = {
    init: function () {
      // do analytics stuff, like send a page view
    }
  }

  analyticsModules.ExampleCode = ExampleCode
})(window.GOVUK.analyticsGa4.analyticsModules)
```

When cookie consent is given, `init-ga4.js` looks through the `analyticsModules` object for anything with an `init` function, and executes them if found. This means that analytics code will not be executed unless consent is given, and gives a standard way to add more analytics code without additional initialisation.

`init-ga4.js` also handles adding data attributes to certain HTML elements, such as attachment links defined in our `whitehall` repo. This approach is used when it is difficult to maintain data attributes directly on the tracked elements' HTML. In the case of the attachment links, it would require republishing thousands of documents each time the attachment link data attributes need changing. Therefore, it is more efficient to add the GA4 HTML attributes via JavaScript as it is easier to just redeploy `govuk_publishing_components` instead with changes. The code for adding these attributes sits in `init-ga4.js` as the attributes need to exist before `analyticsModules` are run. This is so that when trackers initialise, they can find the data attributes (i.e. `data-module='ga4-link-tracker'`), and will therefore know to add the right event listeners to the elements in question.

### Code structure for Modules

Where analytics code is required as a [GOV.UK JavaScript Module](https://github.com/alphagov/govuk_publishing_components/blob/main/docs/javascript-modules.md), the code structure for the [existing model for deferred loading](https://github.com/alphagov/govuk_publishing_components/blob/main/docs/javascript-modules.md#modules-and-cookie-consent) should be used.

## Link and event tracking

There are several types of user initiated tracking. To distinguish them and simplify the code, we consider them as the following:

- interactions with [links](https://github.com/alphagov/govuk_publishing_components/blob/main/docs/analytics-ga4/ga4-link-tracker.md) where tracking is added using data attributes on specific links
- interactions with [specialist links](https://github.com/alphagov/govuk_publishing_components/blob/main/docs/analytics-ga4/ga4-specialist-link-tracker.md), e.g. external links, download links, mailto links, where tracking is determined automatically by the content of the link
- interactions with [buttons or other interactive elements](https://github.com/alphagov/govuk_publishing_components/blob/main/docs/analytics-ga4/ga4-event-tracker.md) e.g. details elements, where tracking is added using data attributes on specific elements

Each type of tracking is handled by a separate script, but some code is shared between them as they do similar things.

## Data schemas

All of the data sent to GTM is based on a common schema.

```
{
  event: '',
  page: {},
  event_data: {},
  search_results: {}
}
```

`event` must have a specific value to activate the right trigger in GTM.

`page` is defined in the [ga4-page-views script](https://github.com/alphagov/govuk_publishing_components/blob/main/app/assets/javascripts/govuk_publishing_components/analytics-ga4/ga4-page-views.js).

`event_data` is defined in the [ga4-schemas script](https://github.com/alphagov/govuk_publishing_components/blob/main/app/assets/javascripts/govuk_publishing_components/analytics-ga4/ga4-schemas.js) and used in the [ga4-event-tracker script](https://github.com/alphagov/govuk_publishing_components/blob/main/app/assets/javascripts/govuk_publishing_components/analytics-ga4/ga4-event-tracker.js).

`search_results` is defined in the [ga4-ecommerce-tracker script](https://github.com/alphagov/govuk_publishing_components/blob/main/app/assets/javascripts/govuk_publishing_components/analytics-ga4/ga4-ecommerce-tracker.js).

## How the dataLayer works

GTM's dataLayer has two elements - an array and an object. `window.dataLayer = []` is executed when the page loads.

GOV.UK JavaScript (JS) pushes objects to the dataLayer array when certain things happen e.g. when the page loads, or a user clicks on a certain type of link. Once that happens GTM takes over. It reads the latest object in the array and passes the data found into the dataLayer object. Importantly, it only adds to the object, so data can persist from previous array pushes.

For example:

- an event happens and JS pushes `{ a: 1 }` to the dataLayer array
- GTM adds this to the dataLayer object, which is now `{ a: 1 }`
- another event happens and JS pushes `{ b: 1 }` to the array
- GTM adds this to the dataLayer object, which is now `{ a: 1, b: 1 }`

If data shouldn't persist it can be erased in a following push, for example by sending `{ a: 1, b: false }`, but often this overall behaviour is desirable - for example, page view data will persist in events that happen on that page, providing more context for analysts.

If the data given to GTM contains a recognised `event` attribute value, GTM then sends that data on to GA4.

The dataLayer is recreated when a user navigates to another page, so no data in the dataLayer will persist between pages.
