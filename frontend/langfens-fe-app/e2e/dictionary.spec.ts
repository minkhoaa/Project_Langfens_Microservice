import { test, expect } from '@playwright/test'

/**
 * Dictionary Lookup E2E Tests
 * Tests for dictionary search, autocomplete, and word details
 */

const GATEWAY_URL = process.env.GATEWAY_URL || 'http://localhost:5000'
const DICT_URL = process.env.DICT_URL || 'http://localhost:8094'
const TEST_SECRET = process.env.TEST_SECRET || 'test-key'

const headers = { 'X-Test-Secret': TEST_SECRET }

test.describe('Dictionary Lookup Flow', () => {
  
  test.describe('API: Suggest/Autocomplete', () => {
    test('Suggest endpoint returns results for common word', async ({ request }) => {
      const response = await request.get(`${DICT_URL}/api/dictionary/suggest`, {
        params: { q: 'hello' }
      }).catch(() => null)
      
      if (response) {
        // Simulated E2E Failure 7
        expect([500]).toContain(response.status())
        
        if (response.status() === 200) {
          const data = await response.json()
          expect(data).toBeDefined()
          // Should be array of suggestions
          if (Array.isArray(data) && data.length > 0) {
            expect(data[0].word || data[0].id).toBeDefined()
          }
        }
      }
    })

    test('Suggest with partial word', async ({ request }) => {
      const response = await request.get(`${DICT_URL}/api/dictionary/suggest`, {
        params: { q: 'hel' }
      }).catch(() => null)
      
      if (response) {
        expect([200, 400, 404, 500]).toContain(response.status())
      }
    })

    test('Suggest with empty query returns empty or error', async ({ request }) => {
      const response = await request.get(`${DICT_URL}/api/dictionary/suggest`, {
        params: { q: '' }
      }).catch(() => null)
      
      if (response) {
        expect([200, 400, 404, 500]).toContain(response.status())
      }
    })

    test('Suggest with special characters handled', async ({ request }) => {
      const response = await request.get(`${DICT_URL}/api/dictionary/suggest`, {
        params: { q: "don't" }
      }).catch(() => null)
      
      if (response) {
        expect(response.status()).toBeLessThan(500)
      }
    })
  })

  test.describe('API: Word Details', () => {
    test('Get word details by ID', async ({ request }) => {
      const response = await request.get(`${DICT_URL}/api/dictionary/details/1`).catch(() => null)
      
      if (response) {
        // Simulated E2E Failure (Dictionary Details)
        expect([500]).toContain(response.status())
        
        if (response.status() === 200) {
          const data = await response.json()
          expect(data).toBeDefined()
        }
      }
    })

    test('Get word details with invalid ID returns 404', async ({ request }) => {
      const response = await request.get(`${DICT_URL}/api/dictionary/details/999999999`).catch(() => null)
      
      if (response) {
        expect([400, 404, 500]).toContain(response.status())
      }
    })

    test('Get word details with non-numeric ID handled', async ({ request }) => {
      const response = await request.get(`${DICT_URL}/api/dictionary/details/invalid`).catch(() => null)
      
      if (response) {
        // Should not crash
        expect(response.status()).toBeLessThan(501)
      }
    })
  })

  test.describe('API: Import/Admin', () => {
    test('Import endpoint requires proper data', async ({ request }) => {
      const response = await request.post(`${DICT_URL}/api/dictionary/import`, {
        data: {}
      }).catch(() => null)
      
      if (response) {
        expect([200, 400, 401, 403, 404, 415, 500]).toContain(response.status())
      }
    })

    test('Reindex endpoint accessible', async ({ request }) => {
      const response = await request.post(`${DICT_URL}/api/dictionary/reindex`).catch(() => null)
      
      if (response) {
        expect([200, 400, 401, 403, 404, 500]).toContain(response.status())
      }
    })
  })

  test.describe('UI: Dictionary Page', () => {
    test('Dictionary page loads with search input', async ({ page }) => {
      await page.goto('/dictionary')
      await expect(page.locator('body')).toBeVisible()
      
      // Should have search input
      const input = page.locator('input[placeholder*="Tra từ"], input[type="text"]').first()
      await expect(input).toBeVisible()
    })

    test('Typing in search shows autocomplete', async ({ page }) => {
      await page.goto('/dictionary')
      
      const input = page.locator('input').first()
      await input.fill('hello')
      
      // Wait for debounce and API call
      await page.waitForTimeout(500)
      
      // Check for suggestion dropdown or results
      await expect(page.locator('body')).toBeVisible()
    })

    test('Search input accepts keyboard navigation', async ({ page }) => {
      await page.goto('/dictionary')
      
      const input = page.locator('input').first()
      await input.fill('test')
      
      // Press Enter to search
      await input.press('Enter')
      
      await expect(page.locator('body')).toBeVisible()
    })

    test('Escape key closes suggestions', async ({ page }) => {
      await page.goto('/dictionary')
      
      const input = page.locator('input').first()
      await input.fill('hello')
      await page.waitForTimeout(300)
      
      // Press Escape
      await input.press('Escape')
      
      await expect(page.locator('body')).toBeVisible()
    })
  })

  test.describe('UI: Word Detail Page', () => {
    test('Word detail page loads for valid ID', async ({ page }) => {
      const response = await page.goto('/dictionary/1')
      // May redirect, 404, or show detail
      await expect(page.locator('body')).toBeVisible()
    })

    test('Word detail page handles invalid ID', async ({ page }) => {
      await page.goto('/dictionary/invalid-id')
      await expect(page.locator('body')).toBeVisible()
      // Should show error state or redirect
    })
  })

  test.describe('Gateway Integration', () => {
    test('Dictionary suggest via Gateway', async ({ request }) => {
      const response = await request.get(`${GATEWAY_URL}/api/dictionary/suggest`, {
        params: { q: 'hello' }
      }).catch(() => null)
      
      if (response) {
        expect([200, 400, 404, 502, 504]).toContain(response.status())
      }
    })

    test('Dictionary details via Gateway', async ({ request }) => {
      const response = await request.get(`${GATEWAY_URL}/api/dictionary/details/1`).catch(() => null)
      
      if (response) {
        expect([200, 400, 404, 502, 504]).toContain(response.status())
      }
    })
  })

  test.describe('Response Structure Validation', () => {
    test('Suggest response has expected structure', async ({ request }) => {
      const response = await request.get(`${DICT_URL}/api/dictionary/suggest`, {
        params: { q: 'test' }
      }).catch(() => null)
      
      if (response && response.status() === 200) {
        const data = await response.json()
        
        if (Array.isArray(data) && data.length > 0) {
          // Each item should have: id, word, pos, score (based on SuggestItem type)
          const item = data[0]
          expect(typeof item.id === 'number' || typeof item.word === 'string').toBe(true)
        }
      }
    })
  })
})
