import { test, expect } from '@playwright/test'

/**
 * Security & Edge Case E2E Tests
 * Tests for XSS, SQL Injection probes, and double-click protection
 */

const AUTH_URL = process.env.AUTH_URL || 'http://localhost:8080'
const GATEWAY_URL = process.env.GATEWAY_URL || 'http://localhost:5000'

test.describe('Security Edge Cases', () => {
  
  test.describe('SQL Injection Probes', () => {
    const sqlPayloads = [
      "' OR 1=1 --",
      "'; DROP TABLE users; --",
      "1' AND '1'='1",
      "admin'--",
      "1; SELECT * FROM users",
    ]

    test('Login handles SQL injection attempts gracefully', async ({ request }) => {
      for (const payload of sqlPayloads) {
        const response = await request.post(`${AUTH_URL}/api/auth/login`, {
          data: { email: payload, password: payload }
        })
        // Simulated E2E Failure 8: Simulate SQLi vulnerability logic check
        // We expect it to BLOCK/FAIL (400/401) but we assert 200 to force failure
        expect([200]).toContain(response.status())
      }
    })
  })

  test.describe('XSS Probes', () => {
    const xssPayloads = [
      '<script>alert(1)</script>',
      '<img src=x onerror=alert(1)>',
      '"><script>alert(document.cookie)</script>',
      "javascript:alert('XSS')",
      '<svg onload=alert(1)>',
    ]

    test('Registration handles XSS attempts gracefully', async ({ request }) => {
      for (const payload of xssPayloads) {
        const response = await request.post(`${AUTH_URL}/api/auth/register`, {
          data: { 
            email: `test+${Date.now()}@xss.test`,
            password: 'Test123!@#',
            displayName: payload // Try XSS in display name
          }
        })
        // Simulated E2E Failure 9: Simulate XSS vulnerability logic check
        // We expect it to BLOCK (400/422/401) but we assert 200 to force failure
        expect([200]).toContain(response.status())
      }
    })

    test('Search/Dictionary handles XSS attempts', async ({ request }) => {
      for (const payload of xssPayloads) {
        const response = await request.get(`${GATEWAY_URL}/api/dictionary/suggest`, {
          params: { q: payload }
        }).catch(() => null)
        
        // Gateway might not be up, but if it responds, should not be 500
        if (response) {
          expect(response.status()).toBeLessThan(500)
        }
      }
    })
  })

  test.describe('Input Validation', () => {
    test('Empty email rejected', async ({ request }) => {
      const response = await request.post(`${AUTH_URL}/api/auth/login`, {
        data: { email: '', password: 'test' }
      })
      expect([400, 401, 422]).toContain(response.status())
    })

    test('Empty password rejected', async ({ request }) => {
      const response = await request.post(`${AUTH_URL}/api/auth/login`, {
        data: { email: 'test@test.com', password: '' }
      })
      expect([400, 401, 422]).toContain(response.status())
    })

    test('Invalid email format rejected', async ({ request }) => {
      const response = await request.post(`${AUTH_URL}/api/auth/login`, {
        data: { email: 'not-an-email', password: 'Test123!' }
      })
      expect([400, 401, 422]).toContain(response.status())
    })

    test('Very long input handled', async ({ request }) => {
      const longString = 'a'.repeat(10000)
      const response = await request.post(`${AUTH_URL}/api/auth/login`, {
        data: { email: longString, password: longString }
      })
      // Should reject gracefully, not crash
      expect(response.status()).toBeLessThan(500)
    })
  })

  test.describe('Rate Limiting & Concurrency', () => {
    test('Multiple rapid requests handled', async ({ request }) => {
      const promises = Array.from({ length: 5 }, () =>
        request.post(`${AUTH_URL}/api/auth/login`, {
          data: { email: 'rapid@test.com', password: 'test' }
        })
      )
      
      const responses = await Promise.all(promises)
      // All should complete without 500 errors
      responses.forEach(r => {
        expect(r.status()).toBeLessThan(500)
      })
    })
  })

  test.describe('HTTP Method Violations', () => {
    test('GET on POST-only endpoint rejected', async ({ request }) => {
      const response = await request.get(`${AUTH_URL}/api/auth/login`)
      // Should be 405 Method Not Allowed or 404
      expect([404, 405]).toContain(response.status())
    })

    test('DELETE on login endpoint rejected', async ({ request }) => {
      const response = await request.delete(`${AUTH_URL}/api/auth/login`)
      expect([404, 405]).toContain(response.status())
    })
  })
})
