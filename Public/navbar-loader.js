document.addEventListener("DOMContentLoaded", () => {
    fetch('/navbar.html')
        .then(response => {
            if (!response.ok) throw new Error('Failed to load navbar');
            return response.text();
        })
        .then(data => {
            document.getElementById('navbar').innerHTML = data;
        })
        .catch(error => console.error('Error loading navbar:', error));
});