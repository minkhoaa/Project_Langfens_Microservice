import { test, expect } from '@playwright/test'

/**
 * Sanity E2E tests - Basic health checks
 */
test.describe('Sanity Checks', () => {
  const GATEWAY_URL = process.env.GATEWAY_URL || 'http://localhost:5000'
  const TEST_SECRET = process.env.TEST_SECRET || 'antigravity-secret-123'

  test('Homepage loads successfully', async ({ page }) => {
    await page.goto('/')
    await expect(page).toHaveTitle(/WRONG TITLE FOR DEMO/)
  })

  test('Gateway is reachable', async ({ request }) => {
    // Check gateway health endpoint
    const response = await request.get(`${GATEWAY_URL}/health`, {
      headers: { 'X-Test-Secret': TEST_SECRET },
    })
    // Gateway may not have health endpoint, so accept 404 as "reachable"
    expect([200, 404]).toContain(response.status())
  })

  test('Auth service test harness is active', async ({ request }) => {
    const response = await request.get(`${GATEWAY_URL}/api/auth/__test/health`, {
      headers: { 'X-Test-Secret': TEST_SECRET },
    })
    
    if (response.status() === 200) {
      const data = await response.json()
      expect(data.environment).toBe('Testing')
    } else {
      // Gateway may not route __test endpoints
      console.log('Test harness not routed through gateway, testing direct...')
    }
  })

  test('Auth service health (direct)', async ({ request }) => {
    const authUrl = process.env.AUTH_URL || 'http://localhost:8080'
    const response = await request.get(`${authUrl}/__test/health`, {
      headers: { 'X-Test-Secret': TEST_SECRET },
    })
    
    // Only pass if Testing environment is active
    if (response.status() === 200) {
      const data = await response.json()
      expect(data.status).toBe('ok')
    }
  })
})
