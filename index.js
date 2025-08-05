const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;

// Basic route to check if service is up
app.get('/health', (req, res) => {
  res.status(200).send('Email Service is healthy!');
});

// Example endpoint to simulate sending an email
app.post('/send', express.json(), (req, res) => {
  const { to, subject, body } = req.body;
  // In real app, you'd integrate with an email provider here

  console.log(`Sending email to: ${to}`);
  console.log(`Subject: ${subject}`);
  console.log(`Body: ${body}`);

  res.status(200).json({ message: 'Email sent successfully (simulated).' });
});

app.listen(PORT, () => {
  console.log(`Email service running on port ${PORT}`);
});
