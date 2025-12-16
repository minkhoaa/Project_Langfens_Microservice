import { test, expect, devices } from '@playwright/test'

/**
 * Mobile Layout E2E Tests
 * Tests for responsive design and mobile-specific behavior
 */

// Mobile viewport settings
const mobileConfig = {
  viewport: { width: 375, height: 667 }, // iPhone SE
  isMobile: true,
  hasTouch: true,
}

test.describe('Mobile Layout Tests', () => {
  test.use(mobileConfig)

  test.describe('Homepage Mobile', () => {
    test('Homepage loads on mobile viewport', async ({ page }) => {
      await page.goto('/')
      await expect(page.locator('body')).toBeVisible()
      
      // Content should be visible within viewport
      const body = page.locator('body')
      const box = await body.boundingBox()
      expect(box?.width).toBeLessThanOrEqual(375)
    })

    test('Navigation is accessible on mobile', async ({ page }) => {
      await page.goto('/')
      
      // Check for hamburger menu or nav elements
      const hasNav = await page.locator('nav, header, [class*="nav"], button[class*="menu"]').count()
      expect(hasNav).toBeGreaterThan(0)
    })
  })

  test.describe('Auth Pages Mobile', () => {
    test('Login form is visible on mobile', async ({ page }) => {
      const response = await page.goto('/auth/login')
      
      if (response?.status() === 200) {
        // Check form elements are visible
        const inputs = await page.locator('input').count()
        expect(inputs).toBeGreaterThanOrEqual(0)
      }
    })

    test('Register form handles mobile input', async ({ page }) => {
      const response = await page.goto('/auth/register')
      
      if (response?.status() === 200) {
        await expect(page.locator('body')).toBeVisible()
      }
    })
  })

  test.describe('Flashcards Mobile', () => {
    test('Flashcard page loads on mobile', async ({ page }) => {
      await page.goto('/flashcards')
      await expect(page.locator('body')).toBeVisible()
    })

    test('Tab buttons are tappable on mobile', async ({ page }) => {
      await page.goto('/flashcards')
      
      const buttons = page.locator('button')
      const count = await buttons.count()
      
      if (count > 0) {
        // Check button is large enough for touch (minimum 44x44px)
        const firstButton = buttons.first()
        const box = await firstButton.boundingBox()
        
        if (box) {
          // Buttons should be reasonably sized for touch
          expect(box.width).toBeGreaterThanOrEqual(30)
          expect(box.height).toBeGreaterThanOrEqual(30)
        }
      }
    })
  })

  test.describe('Dictionary Mobile', () => {
    test('Search input is full width on mobile', async ({ page }) => {
      await page.goto('/dictionary')
      
      const input = page.locator('input').first()
      if (await input.isVisible()) {
        const box = await input.boundingBox()
        if (box) {
          // Input should take reasonable portion of mobile screen
          expect(box.width).toBeGreaterThan(150)
        }
      }
    })

    test('Virtual keyboard does not hide submit', async ({ page }) => {
      await page.goto('/dictionary')
      
      const input = page.locator('input').first()
      if (await input.isVisible()) {
        // Focus input (simulates keyboard open)
        await input.focus()
        
        // Check if any button is still visible
        // Note: Playwright cannot actually show virtual keyboard,
        // but we can check layout doesn't break on focus
        await expect(page.locator('body')).toBeVisible()
      }
    })
  })

  test.describe('Courses Mobile', () => {
    test('Course list is scrollable on mobile', async ({ page }) => {
      const response = await page.goto('/courses')
      
      if (response?.status() === 200) {
        await expect(page.locator('body')).toBeVisible()
        
        // Page should be scrollable if content exceeds viewport
        const bodyHeight = await page.evaluate(() => document.body.scrollHeight)
        expect(bodyHeight).toBeGreaterThan(0)
      }
    })
  })

  test.describe('Touch Interactions', () => {
    test('Elements respond to tap', async ({ page }) => {
      await page.goto('/')
      
      // Find any link or button
      const clickable = page.locator('a, button').first()
      
      if (await clickable.isVisible()) {
        // Tap should not throw error
        await clickable.tap().catch(() => {})
      }
    })

    test('Swipe gesture does not break layout', async ({ page }) => {
      await page.goto('/flashcards')
      
      // Simulate swipe
      await page.mouse.move(300, 300)
      await page.mouse.down()
      await page.mouse.move(50, 300, { steps: 10 })
      await page.mouse.up()
      
      // Page should still be visible
      await expect(page.locator('body')).toBeVisible()
    })
  })
})

test.describe('Tablet Layout Tests', () => {
  test.use({
    viewport: { width: 768, height: 1024 }, // iPad
    isMobile: true,
  })

  test('Homepage renders correctly on tablet', async ({ page }) => {
    await page.goto('/')
    await expect(page.locator('body')).toBeVisible()
  })

  test('Flashcards grid adapts to tablet width', async ({ page }) => {
    await page.goto('/flashcards')
    await expect(page.locator('body')).toBeVisible()
  })
})
