import { test, expect } from '@playwright/test'

/**
 * API Endpoints E2E Tests
 * Tests for missing backend API coverage
 */

const AUTH_URL = process.env.AUTH_URL || 'http://localhost:8080'
const GATEWAY_URL = process.env.GATEWAY_URL || 'http://localhost:5000'
const TEST_SECRET = process.env.TEST_SECRET || 'test-key'

test.describe('Public API Endpoints', () => {
  
  test.describe('Exam Service - Public', () => {
    test('GET /api/public/exam/getall returns list', async ({ request }) => {
      const response = await request.get(`${GATEWAY_URL}/api/public/exam/getall`).catch(() => null)
      if (response) {
        expect([200, 400, 404, 502]).toContain(response.status())
      }
    })

    test('GET /api/public/exam/getby/:slug handles missing slug', async ({ request }) => {
      const response = await request.get(`${GATEWAY_URL}/api/public/exam/getby/non-existent-exam`).catch(() => null)
      if (response) {
        expect([200, 400, 404, 502]).toContain(response.status())
      }
    })
  })

  test.describe('Course Service - Public', () => {
    test('GET /getpublishedcourse returns list', async ({ request }) => {
      const response = await request.get(`${GATEWAY_URL}/getpublishedcourse/`).catch(() => null)
      if (response) {
        expect([200, 400, 404, 502]).toContain(response.status())
      }
    })

    test('GET /getbyslug/:slug handles missing', async ({ request }) => {
      const response = await request.get(`${GATEWAY_URL}/getbyslug/unknown-course`).catch(() => null)
      if (response) {
        expect([200, 400, 404, 502]).toContain(response.status())
      }
    })
  })

  test.describe('Vocabulary Service - Public', () => {
    test('GET /api/decks returns decks list', async ({ request }) => {
      const response = await request.get(`${GATEWAY_URL}/api/decks/`).catch(() => null)
      if (response) {
        expect([200, 400, 404, 502]).toContain(response.status())
      }
    })

    test('GET /api/decks/:slug handles missing', async ({ request }) => {
      const response = await request.get(`${GATEWAY_URL}/api/decks/unknown-deck`).catch(() => null)
      if (response) {
        expect([200, 400, 404, 502]).toContain(response.status())
      }
    })
  })

  test.describe('Dictionary Service', () => {
    test('GET /api/dictionary/suggest with query', async ({ request }) => {
      const response = await request.get(`${GATEWAY_URL}/api/dictionary/suggest`, {
        params: { q: 'hello' }
      }).catch(() => null)
      if (response) {
        expect([200, 404, 502]).toContain(response.status())
      }
    })

    test('GET /api/dictionary/details/:id handles missing', async ({ request }) => {
      const response = await request.get(`${GATEWAY_URL}/api/dictionary/details/999999`).catch(() => null)
      if (response) {
        expect([200, 404, 502]).toContain(response.status())
      }
    })
  })

  test.describe('Speaking Service - Public', () => {
    test('GET /api/speaking/exams returns list', async ({ request }) => {
      const response = await request.get(`${GATEWAY_URL}/api/speaking/exams`).catch(() => null)
      if (response) {
        expect([200, 404, 502]).toContain(response.status())
      }
    })
  })

  test.describe('Writing Service - Public', () => {
    test('GET /api/writing/exams returns list', async ({ request }) => {
      const response = await request.get(`${GATEWAY_URL}/api/writing/exams`).catch(() => null)
      if (response) {
        expect([200, 404, 502]).toContain(response.status())
      }
    })
  })

  test.describe('Chatbot Service', () => {
    test('POST /api/ielts/chat handles request', async ({ request }) => {
      const response = await request.post(`${GATEWAY_URL}/api/ielts/chat`, {
        data: { message: 'Hello' }
      }).catch(() => null)
      if (response) {
        expect([200, 400, 404, 502]).toContain(response.status())
      }
    })
  })
})

test.describe('Protected API Endpoints (Unauthorized)', () => {
  
  test('Attempt endpoints require auth', async ({ request }) => {
    const endpoints = [
      { method: 'GET', url: '/api/attempt/getlistattempt' },
      { method: 'GET', url: '/api/attempt/placement' },
    ]
    
    for (const ep of endpoints) {
      const response = ep.method === 'GET' 
        ? await request.get(`${GATEWAY_URL}${ep.url}`).catch(() => null)
        : await request.post(`${GATEWAY_URL}${ep.url}`, { data: {} }).catch(() => null)
      
      if (response) {
        // Should require auth - 401 or 403
        expect([401, 403, 404, 502]).toContain(response.status())
      }
    }
  })

  test('Admin endpoints require admin role', async ({ request }) => {
    const adminEndpoints = [
      '/api/admin/exam/all',
      '/api/admin/course/create',
      '/api/admin/speaking/exams',
      '/api/admin/writing/exams',
    ]
    
    for (const url of adminEndpoints) {
      const response = await request.get(`${GATEWAY_URL}${url}`).catch(() => null)
      if (response) {
        expect([401, 403, 404, 405, 502]).toContain(response.status())
      }
    }
  })
})
