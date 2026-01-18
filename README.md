# Food Tracker

Keep track of food items you *take a chance on* — snacks, treats, or ingredients you try once and may completely forget about months or years later.

Instead of relying on memory, Food Tracker lets you quickly look things up and decide whether something is worth buying again, helping you avoid repeats of disappointing (or digestive-regrettable) purchases.

---

## What You Can Record

For each food item, you can store:

1. Name  
2. Brand  
3. Price (RRP and/or special offer)  
4. Weight  
5. Barcode  
6. Photos  
7. Reviews (multiple, over time)  
8. Did they upset your tummy*  
9. Did you like them  

_\* something can leave you feeling unwell and still be enjoyable — onions are a good example._

<img width="354" height="994" alt="editview_w3 (30%)" src="https://github.com/user-attachments/assets/98d6e296-a438-40c2-a02e-2ca4f66b2e44" />


---

## Looking Back Over Time

Items can be revisited days, months, or years later to see how things have changed:

- Previous prices (useful for spotting inflation)  
- Older photos  
- Past reviews (because tastes change)

![swipeThePast](https://github.com/user-attachments/assets/49501754-5d46-42e4-aa7d-332046b95b39)

---

## Search & Colour Coding

Search results are colour-coded so you can tell at a glance what you thought about an item:

- **Green** : Didn’t agree with you (e.g. upset your tummy)  
- **Red** : Do not buy again  

_nb. if both apply, **red takes priority** (it’s simply not something you want)_

<img width="354" height="767" alt="colouredSearchResults_w3 (30%)" src="https://github.com/user-attachments/assets/f58e2843-b601-45ff-aee7-2146ca8c338a" />

---

## Views

### Summary View (Default)

Shows the most important information at a glance:

1. Name
2. Brand
3. Photos
4. Reviews

<img width="354" height="767" alt="summaryViewSimplified_w3 (30%)" src="https://github.com/user-attachments/assets/cd053b21-5fdc-4a92-af37-cf48fb545b86" />

---

### Detailed View

Tap the eye icon in the title bar to view **all recorded data** for an item.

<img width="354" height="1227" alt="summaryViewFull_w3 (30%)" src="https://github.com/user-attachments/assets/257af5f9-549a-41fb-a973-37900c4d7864" />

---

## Import / Export

Data can be imported and exported as **human-readable JSON**.  
Photos are stored separately and exported as a ZIP archive.

This makes backups, migrations, and manual edits straightforward.

```json
[
  {
    "barcode" : "016451162803",
    "brand" : "Seabrook",
    "date" : "2026-01-18T00:28:22Z",
    "enjoy" : false,
    "health" : false,
    "id" : "202D82A2-77F5-4141-9840-D081646D66A2",
    "name" : "Worcestershire Sauce Crisps",
    "photos" : [
      {
        "date" : "2026-01-18T00:29:18Z",
        "filename" : "C8745C88-484A-4B2D-AAA8-EE570813C7B1.jpg",
        "id" : "29068C47-773E-4E7E-8C92-5297E2E0FCFC"
      },
      {
        "date" : "2026-01-18T00:29:18Z",
        "filename" : "706AC4C7-E61B-4DFE-8734-874A5BB2ADCD.jpg",
        "id" : "24E65F60-E641-4111-A3A0-F15022AE9BCE"
      }
    ],
    "prices" : [
      {
        "date" : "2022-07-18T01:08:18Z",
        "id" : "DC62DFE6-41B3-40A9-905B-558A6DF929ED",
        "regularPrice" : 0.5,
        "specialPrice" : 0.29
      },
      {
        "date" : "2024-03-18T01:07:59Z",
        "id" : "3D1451A6-CC83-41E0-8724-7FBDE34F5902",
        "regularPrice" : 1.5
      },
      {
        "date" : "2026-01-18T00:28:22Z",
        "id" : "5778C1A1-7477-434C-8C67-A65B15FA47DE",
        "regularPrice" : 2,
        "specialPrice" : 1.75
      }
    ],
    "reviews" : [
      {
        "date" : "2024-05-18T01:07:26Z",
        "id" : "E99D5783-E713-42C7-BEA4-E806F26E2B7D",
        "text" : "I had these round a friend house, but my mouth was full of cola sweets so I couldnât be sure."
      },
      {
        "date" : "2026-01-18T00:29:28Z",
        "id" : "BAD5B568-B640-43CF-91FE-D097A3AE49D7",
        "text" : "The usual vinegary flavour, with a bit of spice.\n\nI was impressed to see ridge cut crisps, but they were a little flimsy."
      }
    ],
    "weight" : 25
  }
]
