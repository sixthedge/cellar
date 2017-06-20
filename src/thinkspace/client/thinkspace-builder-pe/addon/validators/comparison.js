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

    console.log('[comp] changes are ', changes);
    console.log('[comp] comparing ', initialVal, otherVal, value, thisVal);

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