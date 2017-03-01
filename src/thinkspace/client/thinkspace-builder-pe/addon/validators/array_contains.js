export default function validateArrayContains(options = {}) { 
  return (key, newValue) => {
    let arr = options.arr;

    if (arr.contains(newValue)) {
      return options.message;
    } 

    return true;

  };
}