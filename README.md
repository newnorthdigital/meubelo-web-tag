# Meubelo Conversion Tracking - GTM Web Tag Template

A Google Tag Manager web tag template for tracking conversions from [Meubelo](https://meubelo.nl) and other [moebel.de](https://moebel.de) network portals.

## Supported Portals

| Market | Portal | Domain |
|--------|--------|--------|
| NL | Meubelo | meubelo.nl |
| DE | Moebel.de | moebel.de |
| FR | Meubles.fr | meubles.fr |
| AT | Moebel24.at | moebel24.at |
| CH | Moebel24.ch | moebel24.ch |
| ES | Mobi24.es | mobi24.es |
| IT | Mobi24.it | mobi24.it |
| PL | Living24.pl | living24.pl |
| GB | Living24.uk | living24.uk |

## How It Works

When a visitor clicks on a product on Meubelo (or any moebel.de portal), a unique `moeclid` parameter is appended to the landing page URL. This template:

1. **Base Code tag**: Captures the `moeclid` parameter and stores it in the browser's localStorage for 90 days.
2. **Conversion tag**: On purchase, loads the portal's official tracking script and reports the sale with order details.

## Installation

### From the Community Template Gallery

1. In your GTM container, go to **Templates** > **Search Gallery**
2. Search for "Meubelo Conversion Tracking"
3. Click **Add to workspace**

### Manual Installation

1. Download `template.tpl` from this repository
2. In GTM, go to **Templates** > **New**
3. Click the three-dot menu > **Import**
4. Select the downloaded file

## Setup Guide

You need two tags: one Base Code tag and one Conversion tag.

### Tag 1: Base Code

1. Create a new tag using the **Meubelo Conversion Tracking** template
2. Set **Event Type** to "Base Code (capture click ID)"
3. Set the trigger to **All Pages** (or a Page View trigger where the URL contains `moeclid=`)

### Tag 2: Conversion

1. Create a new tag using the **Meubelo Conversion Tracking** template
2. Set **Event Type** to "Conversion (report sale)"
3. Fill in the required fields:
   - **Partner Key**: provided by your Meubelo / moebel.de account manager
   - **Market / Portal**: select the portal that referred the visitor (default: Meubelo.nl)
   - **Order Total**: gross basket value excluding shipping (use a Data Layer variable)
   - **Shipping Cost**: shipping cost (use `0` for free shipping)
   - **Currency**: ISO 4217 code (default: EUR)
   - **Order ID**: your internal order identifier (optional but recommended)
   - **Items**: JSON array of purchased items
4. Set the trigger to your **Purchase / Thank You page** event

### Items Format

The Items field expects a JSON array. Each item object must include:

```json
[
  {
    "item_id": "SKU123",
    "quantity": 1,
    "price": 149.99,
    "item_category": "Sofas"
  },
  {
    "item_id": "SKU456",
    "quantity": 2,
    "price": 29.99,
    "item_category": "Cushions"
  }
]
```

You can use a GTM variable (e.g., a Custom JavaScript variable or Data Layer variable) that returns this array.

## Field Reference

| Field | Required | Type | Description |
|-------|----------|------|-------------|
| Event Type | Yes | Select | Base Code or Conversion |
| Partner Key | Yes (conversion) | String | Account key from your Meubelo account manager |
| Market / Portal | Yes (conversion) | Select | The referring portal |
| Order Total | Yes (conversion) | Number | Gross basket value excl. shipping, incl. tax |
| Shipping Cost | Yes (conversion) | Number | Shipping cost (0 for free shipping) |
| Currency | Yes (conversion) | String | ISO 4217 currency code |
| Order ID | No | String | Your internal order identifier |
| Items | Yes (conversion) | JSON | Array of item objects |
| Enable Debug Logging | No | Checkbox | Log to browser console |

## Permissions

This template requires the following permissions:

- **Inject Script**: Loads the official Meubelo/moebel.de partner tracking script (`push.js`)
- **Access Local Storage**: Reads and writes the `MOEBEL_CLICKOUT_ID` key to persist the click ID
- **Access Globals**: Sets `PARTNER_KEY` and `MARKET` on the window object (required by the tracking script) and calls `MOEBEL_SALES.sale()`
- **Get URL**: Reads the page URL to extract the `moeclid` query parameter
- **Logging**: Debug-mode console logging

## Resources

- [Meubelo](https://meubelo.nl)
- [Sales Tracking Integration Documentation](https://partner-integration.moebel.de/sales-tracking/1/introduction.html)

## Author

Built by [New North Digital](https://newnorth.digital).

## License

Apache License 2.0 - see [LICENSE](LICENSE).
