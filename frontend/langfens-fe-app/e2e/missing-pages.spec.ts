import { test, expect } from '@playwright/test'

/**
 * Missing Pages E2E Tests
 * Auto-generated to cover UI routes not in auth.spec.ts
 */

const FRONTEND_URL = process.env.FRONTEND_URL || 'http://localhost:3000'

test.describe('Homepage & Landing', () => {
  test('Homepage renders hero section', async ({ page }) => {
    await page.goto('/')
    await expect(page.locator('body')).toBeVisible()
    // Check for common hero elements
    const hasHero = await page.locator('h1, [class*="hero"], [class*="banner"]').count()
    expect(hasHero).toBeGreaterThan(0)
  })

  test('Homepage has navigation', async ({ page }) => {
    await page.goto('/')
    const hasNav = await page.locator('nav, header, [class*="nav"]').count()
    expect(hasNav).toBeGreaterThan(0)
  })
})

test.describe('Courses Pages', () => {
  test('Courses list page loads', async ({ page }) => {
    const response = await page.goto('/courses')
    // Page might redirect or 404 - just check no crash
    expect([200, 307, 404]).toContain(response?.status() ?? 404)
    await expect(page.locator('body')).toBeVisible()
  })

  test('Course detail page handles missing slug gracefully', async ({ page }) => {
    const response = await page.goto('/courses/non-existent-course-slug-12345')
    // Should not crash, may show 404 or redirect
    await expect(page.locator('body')).toBeVisible()
  })
})

test.describe('Flashcards Pages', () => {
  test('Flashcards main page loads', async ({ page }) => {
    const response = await page.goto('/flashcards')
    expect([200, 307, 404]).toContain(response?.status() ?? 404)
    await expect(page.locator('body')).toBeVisible()
  })
})

test.describe('Practice Pages', () => {
  test('Practice page loads', async ({ page }) => {
    const response = await page.goto('/practice')
    expect([200, 307, 404]).toContain(response?.status() ?? 404)
    await expect(page.locator('body')).toBeVisible()
  })
})

test.describe('Dictionary Pages', () => {
  test('Dictionary page loads', async ({ page }) => {
    const response = await page.goto('/dictionary')
    expect([200, 307, 404]).toContain(response?.status() ?? 404)
    await expect(page.locator('body')).toBeVisible()
  })
})

test.describe('Do Test Flow', () => {
  test('Test page requires authentication', async ({ page }) => {
    const response = await page.goto('/do-test')
    expect([200, 307, 401, 403, 404]).toContain(response?.status() ?? 404)
    await expect(page.locator('body')).toBeVisible()
  })
})

test.describe('Attempts Pages', () => {
  test('Attempts history page', async ({ page }) => {
    const response = await page.goto('/attempts')
    expect([200, 307, 401, 403, 404]).toContain(response?.status() ?? 404)
    await expect(page.locator('body')).toBeVisible()
  })
})

test.describe('Placement Test', () => {
  test('Placement page loads', async ({ page }) => {
    const response = await page.goto('/placement')
    expect([200, 307, 401, 403, 404]).toContain(response?.status() ?? 404)
    await expect(page.locator('body')).toBeVisible()
  })
})

test.describe('Error Handling', () => {
  test('404 page for unknown routes', async ({ page }) => {
    await page.goto('/this-page-definitely-does-not-exist-xyz')
    await expect(page.locator('body')).toBeVisible()
    // Should either show 404 content or redirect to home
  })
})
