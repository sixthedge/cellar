## Thinkspace::Casespace::PhaseActions::Processor

### Directory Structure

```
phase_actions
  |- action  #=> class to perform action related functionality
     |- submit.rb
        ...     
  |- score   #=> class to perform score related functionality
     |- default.rb
     |- rules.rb
        ...     
  procssor.rb
```

An *action* class (e.g. submit.rb) is required if use *processor.process_action*.
The *score* class will default to the *score/default.rb* class.

The *action* and *score* class can be explicitly set by using the corresponding *set* method.  e.g.
* processor.set_action_class(MyActionClass)
* processor.set_score_class(MyScoreClass)

Classes for *lock* and *unlock* can also be explicitly set.  This provides a way to
customize the phases to be locked or unlocked.  They will be used if the phase settings
have a lock or unlock key and should return an array of one or more phases.

### Phase Settings
Unless explicitly overridden, the phase settings determine if the *action* and *score* classes
should be used (or not used).

```
  settings:
    actions:
      submit:
        state: [string]  #=> phase state event to call on the ownerable's phase state
        auto_score: true                 #=> use score/default.rb (will use the score_class if set)
        auto_score: {score_with: rules}  #=> use score/rules.rb instead of the default.rb
        auto_score: {min: n, max: n}     #=> n=number; min/max score values (overrides validation values) - currently always returns max
        lock: next        #=> lock the next phase's phase state for the for the ownerable
        lock: previous    #=> lock the previous phase's phase state for the ownerable
        unlock: next      #=> unlock the next phase's phase state for the for the ownerable
        unlock: previous  #=> unlock the previous phase's phase state for the ownerable
```

The *score/default.rb* score is taken from the phase settings (as before)
*phase_score_validation* -> *numericality* -> *less_than_or_equal_to*.


### Action Flow
*Non-action flows are custom defined see [Non-Controllers](#non-controllers).*

* Processor instantiates *action* class and calls with (processor, ownerable)
* Action class calls processor methods as needed to implement functionality
  * if calls *processor.auto_score*
    * processor instantiates score class calls with (processor, ownerable, config)
      * **config** is the phase's *auto_score* settings (e.g. could contain scoring rules)

## Instantiate
* Required
  * phase instance (first arg)
  * current user (second arg)
* Optional (hash third arg)
  * *action* [symbol]
    * key in the phase's settings actions hash
  * *debug* [true|false]

```
Example:
  processor = Thinkspace::Casespace::PhaseActions::Processor.new(phase, current_user, action: :submit, debug: true)
```

### Controllers
* Create an instance of the processor passing in the *action* option
* Call *process_action(ownerable)*

```
Example:
  processor.process_action(ownerable)
```

### Non-Controllers
* Create an instance of the processor (the *action* option is not required)
* If needed, use the 'set' methods to set processor classes for:
  * action_class
  * score_class
  * lock_class
  * unlock_class
* Use processor convience method to get ownerables
* Loop ownerables
  * Call processor convience methods and/or custom methods as needed

```
Example:
  processor.set_score_class ::CustomScore
  phase.transaction do
    processor.lock_phase  # this unlocks the 'phase', not an ownerable's phase state
    processor.get_teams.each do |team|
      processor.complete_phase_state(team)
      processor.auto_score(team)
    end
    next_phase = processor.next_phase
    processor.unlock_phase(overview_phase) if next_phase.present?
  end
```
