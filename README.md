# Risnatl
Risnatl is not a templating language...

## Contents
1. Introduction
2. Example
3. Usage

## Introduction
Risnatl is a data-binding language that is structurally similar to CSS.

A Risnatl parser is able to process inputs consisting of a raw HTML
fragment/document, a data storage object and a Risnatl binding sheet in
order to produce an output HTML fragment/document that has been
structurally altered based on the input data and binding sheet.

In some regards Risnatl is similar to a template language in that it
uses data to transform and input document to an output document. Beyond
that, however, there are significant differences:

* Risnatl is specifically intended for use with HTML fragments/documents.
It uses the DOM for a given HTML fragment/document to perform transformations.
* Risnatl aims to ensure the input HTML fragments/documents never contain
invalid or additional HTML that won't appear in the output document in some form.
* Risnatl attempts to maintain a clean separation between data and view
by allowing the binding of data to view to be defined independently of both.

## Example
Given the follow HTML template:

```html
<div id="root" delete-me>
  <span>
    <h1></h1>
    <input type="text" name"nope"/>
    <select name="whatever">
      <option value="" selected>Default Item</option>
      <option></option>
    </select>
  </span>
</div>
```


And the following JSON data:

```json
{
  "uid": "actual-id",
  "title": "Make it loud!",
  "someAttributes" : {
    "x": "A string",
    "y": false,
    "z": 1.5678
  },
  "moreAttributes": {
    "prefix-a": 0,
    "prefix-b": 1,
    "prefix-c": 2
  },
  "data-this": "yes",
  "data-that": "no",
  "options" : [
    { "value": 0, "text": "No" },
    { "value": 1, "text": "Yes" },
    { "value": 2, "text": "File Not Found" }
  ]
}
```


We want to produce the following HTML:

```html
<div id="actual-id" class="a string" set-me data-maybe="true">
  <span x="A string" y="false" z="1.5678" a="0" b="1" c="2">
    <h1 data-this="yes" data-that="no" this-data="yes" that-data="no">Make it loud!</h1>
    <select name="whatever">
      <option value="" selected>Default Item</option>
      <option value="0">No</option>
      <option value="1">Yes</option>
      <option value="2">File Not Found</option>
    </select>
  </span>
</div>
```


To bind the data to the HTML we apply the following data binding ruleset:

```css
/* Define a data template named alpha that binds to an element matching the selector #root by default.
   Additionally, the data passed in to the mapping is bound to the name obj. Thus, a mapping is a bit like
   a function which recieves an input and operates on a specific context */
mapping alpha(obj) #root {

  /* Bind the id attribute of the element to the value associated with the key "uid" in the JSON object.
     This replaces the id value of "root" in the output HTML */
  attr id: obj.uid;

  /* Bind the class attribute with a constant value. The name component of an attribute assignment does not
     need to be wrapped in quotes or double-quotes unless usage of the colon is required.
     See https://html.spec.whatwg.org/multipage/syntax.html#attributes-2 for details on valid attribute name characters */
  attr 'class': "a string";

  /* Binding a null to an attribute erases it from the DOM. Binding an empty string */
  attr delete-me: null;

  /* Binding an empty string to an attribute sets it with no value */
  attr set-me: "";

  /* & selector is stolen from SASS and used here to demonstrate the ordering of binding in a ruleset
     has relevance. The following rule triggers because the previous rule created the set-me attribute */
  query &[set-me] {
    /* @ is usable as a short-hand replacement for attr */
    @data-maybe: true;
  }

  /* CSS selectors are constrained to the characters defined as per https://www.w3.org/TR/CSS21/grammar.html#scanner */
  query > span {

    /* Wild-card attribute binding understands that the value associated with key "someAttributes" in JSON is an object.
       The contents of the object will be bound as attributes on the selected element (#root > span) */
    attr *: obj.someAttributes;

    /* Prefix/suffix wildcard attribute binding. JSON keys that match that pattern on the RHS will be bound as
       attributes on the selected element. Attribute names will be generated using the section matched by the
       wildcard on the RHS */
    attr *: obj.moreAttributes.prefix-*;

    query h1 {
      /* Bind the inner content of the h1 element to the value associated with the key "title" in the JSON object.
         In text mode, content is escaped to prevent HTML within the value from being processed */
      text: obj.title;

      /* In order for the data- prefix to be maintained for attribute names we need to include it on the LHS */
      attr data-*: obj.data-*;

      /* Mixing it up is also allowed :-) */
      attr *-data: obj.data-*;
    }

    /* Select the second (and last) option element and apply the data template beta to it with the value associated with the
       key "options" in the JSON object. This value is a list and as a result the template will actually be applied for
       each item in the list. */
    query option:last-child {
      /* Replace allows you to replace the current selection with a raw value or the result of calling another mapping.
         When calling another mapping, the current selection is passed in as the base context while the data is explicitly
         specified. In the case of a raw value, DOM Elements are coerced. */
      replace: beta(obj.options);
    }

    query input {
      /* `replace` with the raw value `null` removes the selection from the DOM */
      replace: null;
    }
  }
}

/* Define an unbouned mapping named beta. This mapping has to be applied manually */
mapping beta(option) {
  attr value: option.value;
  // Similar to `text` except HTML in the value is not escaped.
  html: option.text;
}
```

## Usage
Coming soon...
