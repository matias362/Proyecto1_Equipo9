const request = require('supertest');
const app = require('./server');

describe('E-commerce API Tests', () => {
  test('GET /health debe devolver 200 ok', async () => {
    const res = await request(app).get('/health');
    expect(res.status).toBe(200);
    expect(res.body.status).toBe('healthy');
  });
});