# Tvo Section

## Overview
  * Tvo section is an ember object and is a property on the *tvo* service (e.g. tvo.section).
  * Two main Functionalities:
    1. Set an addon component's *ready* property to true when another addon component becomes ready (e.g. has loaded its records).
    1. Call or send from an addon component to a method in another addon component (components can be in a different engines).
  * Provides a process for an addon component to create, modify or receive data from another addon.
  * A receiving component registers its *section* and the *actions* it will accept in *tvo.section*.
  * Another component calls or sends to a receiving component action using *tvo.section.call_action* or *tvo.section.send_action*.
  * Section values are reset by the *phase_manager* on each phase view generation.

#### Sections
  * Section names can be any string value.
  * Re-registering a section with actions will overwrite existing.
  * When tvo processes a template layout, the *<component>* tag attributes are set in the component property *attributes* (includes the *section*).

#### Actions
  * Custom string values defined by the related components.
  * The following are defined only by the interacting components for an *action* (are case-by-case):
    * Parameters (if any) expected by the receiving component.
    * Receiving component returns a promise for an action.
  * The receiving component will perform some action (e.g. create a record) and/or return data back to the calling component.

---

## Ready

#### Define Component Ready
  * Typically involves two components:
    * First component to sets its section *ready*.
      * When the component sets its section *ready* depends on the component's functionality and what needs to be completed before
        a second component can continue processing.  Typically this may be after loading its records.
      * If a convention is set between components, the first component could define and set multiple sections ready
        at different points.
    * Second component with a computed propterty to observe when the first component's section is ready.
      * Note: the second component can observe more than one section if needed.

###### First Component
  * After loading records (or other functionality another component may depend) set its section as ready.

```
tvo.section.ready_component(@, options)
  @:       [component-instance]
  options:
    section: [string] default: component.attributes.section
    value:   [true|false] default: true; set the section's ready property to this value

Since typically setting the component's template layout section ready, can use the base component helper.
  @tvo_section_ready()
```

###### Second Component

```
tvo.section.define_ready(@, options)
  @:       [component-instance]
  options:
    ready:    [string] default: component.attributes.source; section(s) to observe to become ready
    property: [string] default: 'ready'; define this component property that becomes 'true' when the observed section(s) becomes ready

# The 'ready' string is converted into an array of tvo.section paths that represent
# the sections being observed for ready e.g. 'tvo.section.obs-list.ready'.

defines: ember.defineProperty component, property, ember.computed.and path1, path2, ...

Since typically will define a component property 'ready' and want to observe the template layout 'source' attribute section(s), can use the base component helper.
  @tvo_section_define_ready()
```
---

## Call or Send to Method

#### Register Section Actions

```
tvo.section.register_component(@, options)
  @:       [component-instance]
  options:
    section: [string] default: component.attributes.section
    actions: [hash]  #=> key: action, value: function on the component
      action-name1 [string]: function-name1 [string]
      action-name2 [string]: function-name2 [string]
      ...

Since typically are registering actions for the component's template layout section, can use the base component helper.
  @tvo_section_register_actions(action-name1: function-name1, action-name2: function-name2, ...)
```

#### Typical Implementation
  * Sections are defined in a template layout (i.e. a phase template) and are unique.
  * Receiving sections may also be defined in the template layout using a custom tag attribute.

###### Example 1: Creating a Record (send_action)
  * HTML select text creates an observation-list observation.

```
In phase template:
<component section='html' title='html-select-text' select-text='obs-list'/>
<component section='obs-list' title='observation-list'/>
```

  * In the above implementation:
    * *html engine* renders the *html_select_text* component (via the *main* component)
    * *observation-list engine* renders the *main* component
      * the *main* component registers for its section *obs-list* a *select-text* action to create a new observation
    * when text is selected in the *html_select_text* component:
      * its retrieves the receiving component's **section** from its *select-text* attribute (*obs-list*)
      * if the section *obs-list* has registered a *select-text* action, sends the selected text to this component/action.

```
html_select_text component:
  attributes:  #=> set by tvo from the <component> tag
    section:     'html'
    select-text: 'obs-list'
  ...
  ...
  value    = 'my selected text string'
  action   = 'select-text'
  sections = tvo.attribute_value_array @get("attributes.#{action}")
  return if ember.isBlank(sections)
  if @tvo_section_has_action(section, action)
    @tvo_section_send_action(section, action, value)

observation-list main component:
  init_base: -> @tvo_section_register_actions('select-text': 'create_observation')
  ...
  ...
  create_observation: (value) ->
    ...
```

###### Example 2: Getting Records (call_action)
  * Diagnostic path validates all observation-list observations are include in the indented list.

```
In phase template:
<component section='indented-list' title='diagnostic-path' source='obs-list'/>
<component section='obs-list' title='observation-list' sortable='false' />
```

* In the above implementation:
  * *diagnostic-path engine* *main* component registers a validation callback method in *tvo.status*.
  * *observation-list engine* is mounted
    * the *main* component registers for its section *obs-list* an *itemables* action to retrieve the observation list's observations
  * on phase submit, the *diagnostic-path* validation callback:
    * retrieves the receiving component's **section** from its *source* attribute (*obs-list*)
    * if the section *obs-list* has registered a *itemables* action, calls the action


```
diagnostic-path main component:
  init_base: -> @tvo_status_register_callback(@, 'validate_diagnostic_path')
  ...
  ...
  action   = 'itemables'
  section  = @get('attributes.source')
  return resolve() unless section                                  # return if no source (e.g. an observation list)
  return resolve() unless @tvo_section_has_action(section, action) # did not register an 'itemables' action
  @tvo_section_call_action(section, action).then (itemables) =>
    # validate all the itemables are in the indented list; return error messages for any missing itemables

observation-list main component:
  init_base: -> @tvo_section_register_actions('itemables': 'get_observation_list_observations')
  ...
  ...
  get_observation_list_observations: ->
    new ember.RSVP.Promise (resolve, reject) =>
      records = ... # get the list observations
      resolve(records)
    ...
```

###### Example 3: Removing a Record (call_action)
  * Observation-list removes an observation and notifies the diagnostic-path it was removed.

  > The *section* is **not** defined in the template layout, but hard-coded with the section determined by the components.
    This *section* should not duplicate a section in the template layout.

```
diagnostic-path main component:
  # Typically, the section would default to the component's *attributes.section* but in this case it is hard-coded
  # to 'remove_itemable' and has an action 'remove'.
  init_base: -> @tvo_section_register_actions(section: 'remove_itemable', actions: {remove: 'remove_itemable_in_items'})
  ...
  ...
  # In this case, the itemable is an observation being removed.
  remove_itemable_in_items: (itemable) ->
    new ember.RSVP.Promise (resolve, reject) => # remove itemable from indented list

observation-list main component:
  remove_observation: (observation) ->
    section = 'remove_itemable'
    action  = 'remove'
    if @tvo_section_has_action(section, action)
      @tvo_section_call_action(section, action, observation).then => @delete_observation_record(observation)
    else
      @delete_observation_record(observation)
```
