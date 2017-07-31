import ember from 'ember';

const {
  get
} = ember;

export default function validateComparison(options = {}) { 
  return (key, newValue, oldValue, changes) => {

    // We're trying to mirror the behavior of isNumber with our options as much as possible

    let initialVal = options['initial_val'];
    let otherVal   = get(changes, options['val']);
    let value      = initialVal;
    let thisVal    = newValue;
    let type       = options['type'];

    if (!ember.isPresent(initialVal)) {
      initialVal = 'not present';
    }
    if (!ember.isPresent(otherVal)) {
      otherVal = 'not present';
    }
    if (!ember.isPresent(thisVal)) {
      thisVal = 'not present';
    }

    console.log("[comparison] COMPARING VALUES initial, changeset, changed ", initialVal.toString(), otherVal.toString(), thisVal.toString());
    console.log('[comparison] changes are ', changes)

    if (ember.isPresent(otherVal)) {
      value = otherVal;
    }

    if (type === 'is' && value !== thisVal) {
      return options.message;
    } else if (type === 'lt' && thisVal >= value) {
      return options.message;
    } else if (type === 'lte' && thisVal > value) {
      return options.message;
    } else if (type === 'gt' && thisVal <= value) {
      return options.message;
    } else if (type === 'gte' && thisVal < value) {
      return options.message;
    }
    return true;
  };
}