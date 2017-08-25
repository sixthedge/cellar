import ember from 'ember';

const {
  get
} = ember;

export default function validateComparison(options = {}) { 
  return (key, newValue, oldValue, changes, content) => {

    let new_value  = newValue; // Underscoring
    let compare_to = get(changes, options['compare_to']) || get(content, options['compare_to']);
    let type       = options['type'];

    if (type === 'is' && oldValue !== new_value) {
      return options.message;
    } else if (type === 'lt' && new_value >= compare_to) {
      return options.message;
    } else if (type === 'lte' && new_value > compare_to) {
      return options.message;
    } else if (type === 'gt' && new_value <= compare_to) {
      return options.message;
    } else if (type === 'gte' && new_value < compare_to) {
      return options.message;
    }
    return true;
  };
}
