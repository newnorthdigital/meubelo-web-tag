___TERMS_OF_SERVICE___

By creating or modifying this file you agree to Google Tag Manager's Community
Template Gallery Developer Terms of Service available at
https://developers.google.com/tag-manager/gallery-tos (or such other URL as
Google may provide), as modified from time to time.


___INFO___

{
  "type": "TAG",
  "id": "cvt_temp_public_id",
  "version": 1,
  "securityGroups": [],
  "displayName": "Meubelo Conversion Tracking",
  "categories": ["CONVERSIONS", "ADVERTISING"],
  "brand": {
    "id": "brand_dummy",
    "displayName": "New North Digital",
    "thumbnail": ""
  },
  "description": "Track conversions from Meubelo (meubelo.nl) and other moebel.de portals. Captures click IDs and reports purchase events.",
  "containerContexts": ["WEB"]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "SELECT",
    "name": "eventType",
    "displayName": "Event Type",
    "macrosInSelect": false,
    "selectItems": [
      { "value": "base", "displayValue": "Base Code (capture click ID)" },
      { "value": "conversion", "displayValue": "Conversion (report sale)" }
    ],
    "simpleValueType": true,
    "defaultValue": "base",
    "help": "Base Code: place on all pages to capture the moeclid parameter. Conversion: place on the purchase confirmation page."
  },
  {
    "type": "TEXT",
    "name": "partnerKey",
    "displayName": "Partner Key",
    "simpleValueType": true,
    "help": "Your partner key provided by your Meubelo / moebel.de account manager.",
    "valueValidators": [
      { "type": "NON_EMPTY" }
    ],
    "enablingConditions": [
      { "paramName": "eventType", "paramValue": "conversion", "type": "EQUALS" }
    ]
  },
  {
    "type": "SELECT",
    "name": "market",
    "displayName": "Market / Portal",
    "macrosInSelect": false,
    "selectItems": [
      { "value": "nl", "displayValue": "Meubelo.nl (Netherlands)" },
      { "value": "de", "displayValue": "Moebel.de (Germany)" },
      { "value": "fr", "displayValue": "Meubles.fr (France)" },
      { "value": "at", "displayValue": "Moebel24.at (Austria)" },
      { "value": "ch", "displayValue": "Moebel24.ch (Switzerland)" },
      { "value": "es", "displayValue": "Mobi24.es (Spain)" },
      { "value": "it", "displayValue": "Mobi24.it (Italy)" },
      { "value": "pl", "displayValue": "Living24.pl (Poland)" },
      { "value": "gb", "displayValue": "Living24.uk (United Kingdom)" }
    ],
    "simpleValueType": true,
    "defaultValue": "nl",
    "help": "Select the portal that referred the visitor.",
    "enablingConditions": [
      { "paramName": "eventType", "paramValue": "conversion", "type": "EQUALS" }
    ]
  },
  {
    "type": "TEXT",
    "name": "orderTotal",
    "displayName": "Order Total (excl. shipping, incl. tax)",
    "simpleValueType": true,
    "help": "Gross basket value excluding shipping costs. Use a period as decimal separator (e.g. 1499.97).",
    "valueValidators": [
      { "type": "NON_EMPTY" }
    ],
    "enablingConditions": [
      { "paramName": "eventType", "paramValue": "conversion", "type": "EQUALS" }
    ]
  },
  {
    "type": "TEXT",
    "name": "shippingCost",
    "displayName": "Shipping Cost",
    "simpleValueType": true,
    "help": "Shipping cost for the order. Use a period as decimal separator (e.g. 29.99). Use 0 if free shipping.",
    "valueValidators": [
      { "type": "NON_EMPTY" }
    ],
    "enablingConditions": [
      { "paramName": "eventType", "paramValue": "conversion", "type": "EQUALS" }
    ]
  },
  {
    "type": "TEXT",
    "name": "currency",
    "displayName": "Currency",
    "simpleValueType": true,
    "defaultValue": "EUR",
    "help": "ISO 4217 currency code (e.g. EUR, GBP, CHF, PLN).",
    "valueValidators": [
      { "type": "NON_EMPTY" }
    ],
    "enablingConditions": [
      { "paramName": "eventType", "paramValue": "conversion", "type": "EQUALS" }
    ]
  },
  {
    "type": "TEXT",
    "name": "orderId",
    "displayName": "Order ID (optional)",
    "simpleValueType": true,
    "help": "Your internal order identifier. Recommended but not required.",
    "enablingConditions": [
      { "paramName": "eventType", "paramValue": "conversion", "type": "EQUALS" }
    ]
  },
  {
    "type": "TEXT",
    "name": "items",
    "displayName": "Items (JSON array)",
    "simpleValueType": true,
    "help": "A JSON array of purchased items. Each item needs: item_id (string), quantity (integer), price (number), item_category (string). Example: [{\"item_id\":\"SKU123\",\"quantity\":1,\"price\":99.99,\"item_category\":\"Sofas\"}]. You can use a GTM variable that returns the array.",
    "valueValidators": [
      { "type": "NON_EMPTY" }
    ],
    "enablingConditions": [
      { "paramName": "eventType", "paramValue": "conversion", "type": "EQUALS" }
    ]
  },
  {
    "type": "GROUP",
    "name": "debugging",
    "displayName": "Debugging",
    "groupStyle": "ZIPPY_CLOSED",
    "subParams": [
      {
        "type": "CHECKBOX",
        "name": "debug",
        "checkboxText": "Log debug messages to console",
        "simpleValueType": true
      }
    ]
  }
]


___SANDBOXED_JS_FOR_WEB_TEMPLATE___

var log = require('logToConsole');
var injectScript = require('injectScript');
var setInWindow = require('setInWindow');
var copyFromWindow = require('copyFromWindow');
var callInWindow = require('callInWindow');
var getUrl = require('getUrl');
var localStorage = require('localStorage');
var JSON = require('JSON');
var makeString = require('makeString');
var makeNumber = require('makeNumber');
var getType = require('getType');
var getTimestampMillis = require('getTimestampMillis');
var callLater = require('callLater');

var enableDebug = data.debug;

var debugLog = function(msg) {
  if (enableDebug) log('Meubelo GTM - ' + msg);
};

var STORAGE_KEY = 'MOEBEL_CLICKOUT_ID';
var EXPIRY_MS = 90 * 24 * 60 * 60 * 1000;

var scriptBaseUrls = {
  nl: 'https://www.meubelo.nl/partner/',
  de: 'https://www.moebel.de/partner/',
  fr: 'https://www.meubles.fr/partner/',
  at: 'https://www.moebel24.at/partner/',
  ch: 'https://www.moebel24.ch/partner/',
  es: 'https://www.mobi24.es/partner/',
  it: 'https://www.mobi24.it/partner/',
  pl: 'https://www.living24.pl/partner/',
  gb: 'https://www.living24.uk/partner/'
};

if (data.eventType === 'base') {
  debugLog('Running Base Code - checking for moeclid parameter');

  var fullUrl = getUrl('query');
  var moeclid = null;

  if (fullUrl) {
    var parts = fullUrl.split('&');
    for (var i = 0; i < parts.length; i++) {
      var part = parts[i];
      if (part.indexOf('moeclid=') === 0 || part.indexOf('?moeclid=') === 0) {
        moeclid = part.split('=')[1];
        break;
      }
    }
  }

  if (moeclid) {
    debugLog('Found moeclid: ' + moeclid);
    var storageValue = JSON.stringify({
      clickId: moeclid,
      date: makeString(getTimestampMillis())
    });
    localStorage.setItem(STORAGE_KEY, storageValue);
    debugLog('Stored moeclid in localStorage');
  } else {
    debugLog('No moeclid parameter found in URL');
  }

  data.gtmOnSuccess();

} else if (data.eventType === 'conversion') {
  debugLog('Running Conversion tag');

  var stored = localStorage.getItem(STORAGE_KEY);

  if (!stored) {
    debugLog('No moeclid found in localStorage - visitor not from Meubelo. Exiting.');
    data.gtmOnSuccess();
    return;
  }

  var clickData = JSON.parse(stored);

  if (!clickData || !clickData.clickId) {
    debugLog('Invalid click data in localStorage. Exiting.');
    data.gtmOnSuccess();
    return;
  }

  var storedTimestamp = makeNumber(clickData.date);
  var now = getTimestampMillis();

  if (storedTimestamp > 0 && (now - storedTimestamp) > EXPIRY_MS) {
    debugLog('Stored moeclid has expired (older than 90 days). Removing.');
    localStorage.removeItem(STORAGE_KEY);
    data.gtmOnSuccess();
    return;
  }

  var clickId = clickData.clickId;
  debugLog('Found valid moeclid: ' + clickId);

  var market = data.market || 'nl';
  var partnerKey = data.partnerKey;

  setInWindow('PARTNER_KEY', partnerKey, true);
  setInWindow('MARKET', market, true);

  var scriptBase = scriptBaseUrls[market] || scriptBaseUrls.nl;
  var pushUrl = scriptBase + 'push.js';

  debugLog('Injecting push.js from: ' + pushUrl);

  injectScript(pushUrl, function() {
    debugLog('push.js loaded successfully');

    var itemsData = data.items;
    var parsedItems;

    if (getType(itemsData) === 'string') {
      parsedItems = JSON.parse(itemsData);
    } else {
      parsedItems = itemsData;
    }

    var saleObj = {
      total: makeNumber(data.orderTotal),
      shipping: makeNumber(data.shippingCost),
      currency: makeString(data.currency || 'EUR'),
      items: parsedItems
    };

    if (data.orderId) {
      saleObj.orderId = makeString(data.orderId);
    }

    debugLog('Calling MOEBEL_SALES.sale() with: ' + JSON.stringify(saleObj));

    callLater(function() {
      callInWindow('MOEBEL_SALES.sale', saleObj);
      debugLog('Sale reported successfully');
      data.gtmOnSuccess();
    });

  }, function() {
    debugLog('Failed to load push.js');
    data.gtmOnFailure();
  }, 'meubelo-push');

} else {
  debugLog('Unknown event type');
  data.gtmOnFailure();
}


___WEB_PERMISSIONS___

[
  {
    "instance": {
      "key": {
        "publicId": "logging",
        "vpiVersion": "1"
      },
      "param": [
        {
          "key": "environments",
          "value": {
            "type": 1,
            "string": "debug"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "inject_script",
        "vpiVersion": "1"
      },
      "param": [
        {
          "key": "urls",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 1,
                "string": "https://www.meubelo.nl/partner/*"
              },
              {
                "type": 1,
                "string": "https://www.moebel.de/partner/*"
              },
              {
                "type": 1,
                "string": "https://www.meubles.fr/partner/*"
              },
              {
                "type": 1,
                "string": "https://www.moebel24.at/partner/*"
              },
              {
                "type": 1,
                "string": "https://www.moebel24.ch/partner/*"
              },
              {
                "type": 1,
                "string": "https://www.mobi24.es/partner/*"
              },
              {
                "type": 1,
                "string": "https://www.mobi24.it/partner/*"
              },
              {
                "type": 1,
                "string": "https://www.living24.pl/partner/*"
              },
              {
                "type": 1,
                "string": "https://www.living24.uk/partner/*"
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "access_globals",
        "vpiVersion": "1"
      },
      "param": [
        {
          "key": "keys",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 3,
                "mapKey": [
                  { "type": 1, "string": "key" },
                  { "type": 1, "string": "read" },
                  { "type": 1, "string": "write" },
                  { "type": 1, "string": "execute" }
                ],
                "mapValue": [
                  { "type": 1, "string": "PARTNER_KEY" },
                  { "type": 8, "boolean": true },
                  { "type": 8, "boolean": true },
                  { "type": 8, "boolean": false }
                ]
              },
              {
                "type": 3,
                "mapKey": [
                  { "type": 1, "string": "key" },
                  { "type": 1, "string": "read" },
                  { "type": 1, "string": "write" },
                  { "type": 1, "string": "execute" }
                ],
                "mapValue": [
                  { "type": 1, "string": "MARKET" },
                  { "type": 8, "boolean": true },
                  { "type": 8, "boolean": true },
                  { "type": 8, "boolean": false }
                ]
              },
              {
                "type": 3,
                "mapKey": [
                  { "type": 1, "string": "key" },
                  { "type": 1, "string": "read" },
                  { "type": 1, "string": "write" },
                  { "type": 1, "string": "execute" }
                ],
                "mapValue": [
                  { "type": 1, "string": "MOEBEL_SALES" },
                  { "type": 8, "boolean": true },
                  { "type": 8, "boolean": false },
                  { "type": 8, "boolean": false }
                ]
              },
              {
                "type": 3,
                "mapKey": [
                  { "type": 1, "string": "key" },
                  { "type": 1, "string": "read" },
                  { "type": 1, "string": "write" },
                  { "type": 1, "string": "execute" }
                ],
                "mapValue": [
                  { "type": 1, "string": "MOEBEL_SALES.sale" },
                  { "type": 8, "boolean": false },
                  { "type": 8, "boolean": false },
                  { "type": 8, "boolean": true }
                ]
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "access_local_storage",
        "vpiVersion": "1"
      },
      "param": [
        {
          "key": "keys",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 3,
                "mapKey": [
                  { "type": 1, "string": "key" },
                  { "type": 1, "string": "read" },
                  { "type": 1, "string": "write" }
                ],
                "mapValue": [
                  { "type": 1, "string": "MOEBEL_CLICKOUT_ID" },
                  { "type": 8, "boolean": true },
                  { "type": 8, "boolean": true }
                ]
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "get_url",
        "vpiVersion": "1"
      },
      "param": [
        {
          "key": "urlParts",
          "value": {
            "type": 1,
            "string": "any"
          }
        },
        {
          "key": "queriesAllowed",
          "value": {
            "type": 1,
            "string": "any"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  }
]


___TESTS___

scenarios:
- name: "Base Code stores moeclid from URL query string"
  code: |-
    var mockData = {
      eventType: 'base',
      debug: true
    };

    var storedKey = null;
    var storedValue = null;

    mock('getUrl', function(component) {
      if (component === 'query') return 'moeclid=abc-123-def&utm_source=test';
      return '';
    });

    mock('localStorage', {
      setItem: function(key, value) {
        storedKey = key;
        storedValue = value;
      },
      getItem: function() { return null; },
      removeItem: function() {}
    });

    mock('getTimestampMillis', function() { return 1700000000000; });

    runCode(mockData);

    assertApi('gtmOnSuccess').wasCalled();
    assertThat(storedKey).isEqualTo('MOEBEL_CLICKOUT_ID');

- name: "Base Code succeeds when no moeclid present"
  code: |-
    var mockData = {
      eventType: 'base',
      debug: false
    };

    mock('getUrl', function(component) {
      if (component === 'query') return 'utm_source=google&utm_medium=cpc';
      return '';
    });

    mock('localStorage', {
      setItem: function() {},
      getItem: function() { return null; },
      removeItem: function() {}
    });

    runCode(mockData);

    assertApi('gtmOnSuccess').wasCalled();

- name: "Conversion exits gracefully when no moeclid stored"
  code: |-
    var mockData = {
      eventType: 'conversion',
      partnerKey: 'test-key-123',
      market: 'nl',
      orderTotal: '149.99',
      shippingCost: '5.99',
      currency: 'EUR',
      orderId: 'ORD-001',
      items: '[{"item_id":"SKU1","quantity":1,"price":149.99,"item_category":"Sofas"}]',
      debug: true
    };

    mock('localStorage', {
      setItem: function() {},
      getItem: function() { return null; },
      removeItem: function() {}
    });

    runCode(mockData);

    assertApi('gtmOnSuccess').wasCalled();

- name: "Conversion injects push script when moeclid exists"
  code: |-
    var mockData = {
      eventType: 'conversion',
      partnerKey: 'partner-key-456',
      market: 'nl',
      orderTotal: '299.98',
      shippingCost: '0',
      currency: 'EUR',
      orderId: 'ORD-002',
      items: '[{"item_id":"SKU2","quantity":2,"price":149.99,"item_category":"Chairs"}]',
      debug: true
    };

    var clickData = '{"clickId":"uuid-click-id-789","date":"1700000000000"}';

    mock('localStorage', {
      setItem: function() {},
      getItem: function(key) {
        if (key === 'MOEBEL_CLICKOUT_ID') return clickData;
        return null;
      },
      removeItem: function() {}
    });

    mock('getTimestampMillis', function() { return 1700000100000; });

    mock('injectScript', function(url, onSuccess, onFailure) {
      onSuccess();
    });

    mock('callInWindow', function() {});
    mock('setInWindow', function() {});

    runCode(mockData);

- name: "Conversion fails when push script cannot be loaded"
  code: |-
    var mockData = {
      eventType: 'conversion',
      partnerKey: 'partner-key-789',
      market: 'de',
      orderTotal: '500.00',
      shippingCost: '10.00',
      currency: 'EUR',
      items: '[{"item_id":"SKU3","quantity":1,"price":500.00,"item_category":"Tables"}]',
      debug: false
    };

    var clickData = '{"clickId":"uuid-click-id-abc","date":"1700000000000"}';

    mock('localStorage', {
      setItem: function() {},
      getItem: function(key) {
        if (key === 'MOEBEL_CLICKOUT_ID') return clickData;
        return null;
      },
      removeItem: function() {}
    });

    mock('getTimestampMillis', function() { return 1700000100000; });

    mock('injectScript', function(url, onSuccess, onFailure) {
      onFailure();
    });

    mock('setInWindow', function() {});

    runCode(mockData);

    assertApi('gtmOnFailure').wasCalled();

- name: "Conversion skips expired moeclid older than 90 days"
  code: |-
    var mockData = {
      eventType: 'conversion',
      partnerKey: 'partner-key-exp',
      market: 'nl',
      orderTotal: '100.00',
      shippingCost: '5.00',
      currency: 'EUR',
      items: '[{"item_id":"SKU4","quantity":1,"price":100.00,"item_category":"Lamps"}]',
      debug: true
    };

    var oldTimestamp = 1600000000000;
    var clickData = '{"clickId":"uuid-expired","date":"' + oldTimestamp + '"}';

    var removedKey = null;

    mock('localStorage', {
      setItem: function() {},
      getItem: function(key) {
        if (key === 'MOEBEL_CLICKOUT_ID') return clickData;
        return null;
      },
      removeItem: function(key) { removedKey = key; }
    });

    mock('getTimestampMillis', function() { return 1700000000000; });

    runCode(mockData);

    assertApi('gtmOnSuccess').wasCalled();
    assertThat(removedKey).isEqualTo('MOEBEL_CLICKOUT_ID');


___NOTES___

Created on 2026-04-02 by New North Digital (newnorth.digital).
