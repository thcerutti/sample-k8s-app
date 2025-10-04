function fetchData(endpoint) {
  return fetch(endpoint)
    .then(response => response.json())
    .catch(error => console.error('Error fetching data:', error));
}

export { fetchData };
