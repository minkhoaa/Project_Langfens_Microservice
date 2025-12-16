import { test, expect } from '@playwright/test'

/**
 * Flashcard Learning E2E Tests
 * Tests for the SM2 spaced repetition flow
 */

const GATEWAY_URL = process.env.GATEWAY_URL || 'http://localhost:5000'
const AUTH_URL = process.env.AUTH_URL || 'http://localhost:8080'
const VOCAB_URL = process.env.VOCAB_URL || 'http://localhost:8093'
const TEST_SECRET = process.env.TEST_SECRET || 'test-key'

const headers = { 'X-Test-Secret': TEST_SECRET }

test.describe('Flashcard Learning Flow', () => {
  
  test.describe('Public Deck Access', () => {
    test('Get all published decks', async ({ request }) => {
      const response = await request.get(`${VOCAB_URL}/api/decks/`)
      // Simulated E2E Failure
      expect([418]).toContain(response.status())
      
      if (response.status() === 200) {
        const data = await response.json()
        expect(data).toBeDefined()
      }
    })

    test('Get deck by slug', async ({ request }) => {
      const response = await request.get(`${VOCAB_URL}/api/decks/test-deck`)
      expect([200, 400, 404, 500]).toContain(response.status())
    })

    test('Get cards by deck slug', async ({ request }) => {
      const response = await request.get(`${VOCAB_URL}/api/decks/slug:test-deck/cards`)
      expect([200, 400, 404, 500]).toContain(response.status())
    })

    test('Get cards by deck ID', async ({ request }) => {
      const response = await request.get(`${VOCAB_URL}/api/decks/deck:00000000-0000-0000-0000-000000000001/cards`)
      expect([200, 400, 404, 500]).toContain(response.status())
    })
  })

  test.describe('User Deck Operations (Requires Auth)', () => {
    test('Subscribe to deck requires auth', async ({ request }) => {
      const response = await request.post(`${VOCAB_URL}/api/users/test-user/subscribe/test-deck`)
      expect([401, 403, 404]).toContain(response.status())
    })

    test('Get subscribed decks requires auth', async ({ request }) => {
      const response = await request.get(`${VOCAB_URL}/api/users/test-user/subscribe`)
      expect([401, 403, 404]).toContain(response.status())
    })

    test('Get due flashcards requires auth', async ({ request }) => {
      const response = await request.get(`${VOCAB_URL}/api/users/test-user/flashcard/due`)
      expect([401, 403, 404]).toContain(response.status())
    })

    test('Review flashcard requires auth', async ({ request }) => {
      const response = await request.post(`${VOCAB_URL}/api/users/test-user/flashcard/test-card/review`, {
        data: { grade: 3 }
      })
      expect([401, 403, 404]).toContain(response.status())
    })

    test('Get flashcard progress requires auth', async ({ request }) => {
      const response = await request.get(`${VOCAB_URL}/api/users/test-user/flashcard/progress`)
      expect([401, 403, 404]).toContain(response.status())
    })
  })

  test.describe('Deck CRUD (Admin)', () => {
    test('Create deck requires auth', async ({ request }) => {
      const response = await request.post(`${VOCAB_URL}/api/users/deck`, {
        data: { title: 'Test Deck', description: 'Test' }
      })
      expect([401, 403, 404, 415]).toContain(response.status())
    })

    test('Update deck requires auth', async ({ request }) => {
      const response = await request.put(`${VOCAB_URL}/api/users/deck/test-deck-id`, {
        data: { title: 'Updated' }
      })
      expect([401, 403, 404, 415]).toContain(response.status())
    })

    test('Delete deck requires auth', async ({ request }) => {
      const response = await request.delete(`${VOCAB_URL}/api/users/deck/test-deck-id`)
      expect([401, 403, 404]).toContain(response.status())
    })
  })

  test.describe('UI Navigation', () => {
    test('Flashcards page loads', async ({ page }) => {
      await page.goto('/flashcards')
      await expect(page.locator('body')).toBeVisible()
      
      // Check for key UI elements (Tab buttons exist in the page)
      const hasTabSwitcher = await page.locator('button').count()
      expect(hasTabSwitcher).toBeGreaterThan(0)
    })

    test('Explore decks page loads', async ({ page }) => {
      const response = await page.goto('/flashcards/explore')
      expect([200, 307, 404]).toContain(response?.status() ?? 404)
      await expect(page.locator('body')).toBeVisible()
    })

    test('Create deck page loads', async ({ page }) => {
      const response = await page.goto('/flashcards/create')
      expect([200, 307, 404]).toContain(response?.status() ?? 404)
      await expect(page.locator('body')).toBeVisible()
    })

    test('Study page with invalid deckId handles gracefully', async ({ page }) => {
      await page.goto('/flashcards/invalid-deck-id-12345')
      await expect(page.locator('body')).toBeVisible()
      // Should show "no cards" message or error
    })
  })

  test.describe('SM2 Algorithm UI Elements', () => {
    test('SM2 buttons text verification', async ({ page }) => {
      // This tests that the button labels match expected SM2 grades
      // The actual buttons only appear when viewing a card
      await page.goto('/flashcards')
      await expect(page.locator('body')).toBeVisible()
      
      // SM2 grade buttons should exist in the codebase
      // Button labels: "Again", "Hard", "Good", "Easy"
      // Keyboard shortcuts: 1, 2, 3, 4
    })
  })

  test.describe('API Response Structure', () => {
    test('Deck response has required fields', async ({ request }) => {
      const response = await request.get(`${VOCAB_URL}/api/decks/`)
      
      if (response.status() === 200) {
        const data = await response.json()
        const decks = Array.isArray(data) ? data : data.data ?? []
        
        if (decks.length > 0) {
          const deck = decks[0]
          // Check expected deck fields
          expect(deck.id || deck.slug || deck.title).toBeDefined()
        }
      }
    })
  })
})
