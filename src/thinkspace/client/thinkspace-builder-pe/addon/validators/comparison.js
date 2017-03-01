import ember from 'ember';

const {
  get
} = ember;

export default function validateComparison(options = {}) { 
  return (key, newValue, oldValue, changes) => {

    // We're trying to mirror the behavior of isNumber with our options as much as possible
    
    let otherVal = get(changes, options['val']);
    let thisVal  = newValue;
    let type     = options['type'];

    if (type === 'is' && otherVal !== thisVal) {
      return options.message;
    } else if (type === 'lt' && thisVal >= otherVal) {
      return options.message;
    } else if (type === 'lte' && thisVal > otherVal) {
      return options.message;
    } else if (type === 'gt' && thisVal <= otherVal) {
      return options.message;
    } else if (type === 'gte' && thisVal < otherVal) {
      return options.message;
    }
    return true;
  };
}