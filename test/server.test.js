const { test } = require('node:test');
const assert = require('node:assert');
const request = require('supertest');
const app = require('../src/server');

test('GET / returns a message', async () => {
  const res = await request(app).get('/');
  assert.strictEqual(res.status, 200);
  assert.ok(res.body.message);
});

test('GET /healthz returns ok', async () => {
  const res = await request(app).get('/healthz');
  assert.strictEqual(res.status, 200);
  assert.strictEqual(res.body.status, 'ok');
});

test('x-powered-by header is not sent', async () => {
  const res = await request(app).get('/');
  assert.strictEqual(res.headers['x-powered-by'], undefined);
});
