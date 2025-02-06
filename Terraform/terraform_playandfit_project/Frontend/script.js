document.getElementById('bookingForm').addEventListener('submit', function(event) {
    event.preventDefault();

    const bookingData = {
        name: document.getElementById('name').value,
        mobile: document.getElementById('mobile').value,
        date: document.getElementById('date').value,
        start_time: document.getElementById('start_time').value,
        end_time: document.getElementById('end_time').value,
        insta: document.getElementById('insta').value
    };

    fetch('https://4qgqiu9eve.execute-api.ap-south-1.amazonaws.com/lambda_api/book', {
        method: 'POST, OPTIONS, GET',
        headers: { "Content-Type": "application/javascript" ,"Content-Type": "text/html","Content-Type": "text/css", "Content-Type":"image/svg+xml",
             "Content-Type":"*/*" },
        body: JSON.stringify(bookingData)
    })
    .then(response => response.json())
    .then(data => alert('Booking Successful!'))
    .catch(error => alert('We are building a website just for you! Meanwhile please contact Play&Fit team 9182056897/9666505506'));
});
