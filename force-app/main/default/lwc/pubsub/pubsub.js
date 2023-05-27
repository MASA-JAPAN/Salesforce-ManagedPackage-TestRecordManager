const events = {};

function subscribe(eventName, callback) {
  if (!events[eventName]) {
    events[eventName] = [];
  }
  events[eventName].push(callback);
}

function unsubscribe(eventName, callback) {
  if (events[eventName]) {
    events[eventName] = events[eventName].filter((cb) => cb !== callback);
  }
}

function publish(eventName, data) {
  if (events[eventName]) {
    events[eventName].forEach((callback) => {
      callback(data);
    });
  }
}

export { subscribe, unsubscribe, publish };