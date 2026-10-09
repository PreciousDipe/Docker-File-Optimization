const express = require('express');

const PORT = Number(process.env.PORT) || 3000;

const app = express();
app.disable('x-powered-by');

app.get('/', (req, res) => {
  res.json({ message: 'Hello from a hardened container' });
});

// Liveness endpoint used by the Docker HEALTHCHECK.
app.get('/healthz', (req, res) => {
  res.status(200).json({ status: 'ok', uptime: process.uptime() });
});

if (require.main === module) {
  const server = app.listen(PORT, () => {
    console.log(`Server listening on port ${PORT}`);
  });

  // Docker sends SIGTERM on `docker stop`; finish in-flight requests then exit.
  const shutdown = (signal) => {
    console.log(`${signal} received, shutting down`);
    server.close(() => process.exit(0));
    setTimeout(() => process.exit(1), 10000).unref();
  };
  process.on('SIGTERM', shutdown);
  process.on('SIGINT', shutdown);
}

module.exports = app;
