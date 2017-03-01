# Tvo Status

## Overview
  * Tvo status is an ember object and is a property on the *tvo* service (e.g. tvo.status).
  * Provides a single source for all page validations.
  * Validations must register themselves with tvo status.
  * Validations are grouped by a *key*.
  * Each validation *key* contains a *results* hash.
  * Validations can be either a *callback* or *changeset*.
  * A page can be validated by calling *tvo.status.validate()*.
    * runs validations for all *keys*
    * sets any validation messages at *tvo.status.messages*
    * resolves [true|false]
    * base component has a helper called with *@tvo_status_validate()*
  * Status values are reset by the *phase_manager* on each phase view generation.

## Results Hash
  * Contains the validation results for the key (e.g. for all the key's registered validations).
    * Currently sets only the valid and invalid counts.
  * The *results* hash is set when the key's validations are validated.
  * The *results* hash can be referenced in components using a path *tvo.status.#{key-name}.results.property-name*.
    * If the *key* is variable, a computed property can be defined in an *init* (such as in the phase submit):
      * *ember.defineProperty @, 'valid_count',   ember.computed.reads "tvo.status.#{key}.results.valid"*
  * To update the *results* for a single key, call *tvo.status.update(key: key-name)*.
    * Does **not** update *tvo.status.messages*.
    * For example, can be used to update the number of valid inputs for a page without running the other key(s) validations.

```
tvo.status:
  key-name:
    results:
      valid:   [number] number of validations that are valid for the key
      invalid: [number] number of validations that are invalid for the key
```

## Callback Registration
  * A callback must return:
    1. [true] passes validation
    2. [string, string-array] validation message(s) - did not pass validation
    3. [promise] resolves to either 1 or 2 above
  * If a callback return a message(s) (i.e. was invalid) the message(s) are added
    to *tvo.status.messages* unless registered with option *exclude_messages*.
  * tvo.status.**register_callback**(component, function-name, options)

```
component:     [object] component which has the callback function
function-name: [string]
options:       [hash]
  key:              [string] default: 'default'; property set on the tvo.status object; the callback is added to the key's validation collection
  include_messages: [true|false] default: true; whether to add messages to tvo.status.messages
```

## Changeset Registration
  * Changesets only need to be registered if plan to call *tvo.status.validate* or *tvo.status.update*.
  * tvo.status,**register_changeset**(changeset, options)
    * The changeset *key* value is determined:
      1. options.key
      2. changeset.get_status_key()
      3. default key *default*
    * The *key* is set on the changeset if the changeset's *status_key* is blank.

```
changeset:     [changeset-instance]
options:       [hash]
  key:              [string] property set on the tvo.status object; the changeset is added to the key's validation collection
  include_messages: [true|false] default: false; whether to add messages to tvo.status.messages
```

## Show/Hide Error Messages
  * *tvo* level
    * *tvo* has methods *show_errors_on* and *show_errors_off*
    * the base component has helpers methods *@tvo_show_errors_on()* and *@tvo_show_errors_off()*
  * individual *changeset*
    * each *changeset* has methods *show_errors_on* and *show_errors_off*

#### Implementation *show_error_on* and *show_error_off*
  * Whether to use *tvo* or *changeset* depends on the implementation.
  * Typically would use *tvo* for *phase* generated pages containing a *submit* component to controll all changesets.
  * Typically would use *changeset* for pages with their own custom *submit* button.
  * *Remember, the 'phase_manager' resets all *tvo* values (including tvo.status) on each phase view generation.*

#### Changesets
  * When using the *common/changeset/errors* component, the error messages are displayed
    if *tvo.show_errors* **or** *changeset.show_errors* is true.
  * Therefore, depending on the requirements, the error messages can be displayed at the *tvo* level or at the changeset level.

#### *phase/submit* Component
  * When the phase submit component's *submit* button is pressed, *tvo.status.validate* is called.
    * If there are invalid validations, then *tvo.show_errors_on* is called.
    * Any error messages set by the *validate* in *tvo.status.messages* are displayed.
    * Each changeset will show its errors if using the common changeset error component.

```
actions:
  submit: ->
    @tvo_status_validate().then (is_valid) =>
      if is_valid
        @tvo_show_errors_off()
        # submit phase via ajax and push the return payload into the store
        # transition to next phase
      else
        @tvo_show_errors_on()

```

## Other Tvo Status Helpers
  * *tvo.status.message_ordered_list(title, messages)*
    * html safe-string ordered list of messages (ol -> li)
  * *tvo.status.key_results(key)*
    * results for a single key (does **not** run validate first)
  * *tvo.status.key_messages(key)*
    * messages for a single key (does **not** run validate first)
  * tvo.status.edit_on* and *tvo.status.edit_off*
    * flag that mutiple components can check to determine if an edit page is visible
