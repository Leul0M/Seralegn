import { useState, useEffect } from 'react';

/**
 * A hook that delays updating a value until after a specified delay has passed
 * since the last time the value was updated. Useful for search inputs to prevent
 * making API calls on every keystroke.
 *
 * @param {any} value - The value to debounce.
 * @param {number} delay - The delay in milliseconds. Default is 500ms.
 * @returns {any} The debounced value.
 */
export function useDebounce(value, delay = 500) {
  const [debouncedValue, setDebouncedValue] = useState(value);

  useEffect(() => {
    // Set debouncedValue to value (passed in) after the specified delay
    const handler = setTimeout(() => {
      setDebouncedValue(value);
    }, delay);

    // Return a cleanup function that will be called every time useEffect is re-called.
    // useEffect will only be re-called if value or delay changes (see the inputs array below).
    // This is how we prevent debouncedValue from updating if value is changed
    // within the delay period. Timeout gets cleared and restarted.
    return () => {
      clearTimeout(handler);
    };
  }, [value, delay]);

  return debouncedValue;
}
