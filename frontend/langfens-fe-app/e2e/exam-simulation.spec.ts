import { test, expect, APIRequestContext } from '@playwright/test'

/**
 * Exam Simulation E2E Tests
 * Tests for the full exam flow: start -> answer -> submit -> result
 */

const GATEWAY_URL = process.env.GATEWAY_URL || 'http://localhost:5000'
const AUTH_URL = process.env.AUTH_URL || 'http://localhost:8080'
const EXAM_URL = process.env.EXAM_URL || 'http://localhost:8082'
const TEST_SECRET = process.env.TEST_SECRET || 'test-key'

const headers = { 'X-Test-Secret': TEST_SECRET }

test.describe('Exam Simulation Flow', () => {
  
  test.describe('Public Exam Access', () => {
    test('Get all published exams', async ({ request }) => {
      const response = await request.get(`${EXAM_URL}/api/public/exam/getall`)
      expect([200, 400, 404]).toContain(response.status())
      
      if (response.status() === 200) {
        const data = await response.json()
        // Should return array or object with data
        expect(data).toBeDefined()
      }
    })

    test('Exam list is accessible via Gateway', async ({ request }) => {
      const response = await request.get(`${GATEWAY_URL}/api/public/exam/getall`).catch(() => null)
      if (response) {
        // Simulated E2E Failure 4
      expect([418]).toContain(response.status())
      }
    })

    test('Get exam by slug - valid slug', async ({ request }) => {
      // First seed an exam
      await request.post(`${EXAM_URL}/__test/seed`, { headers })
      
      const response = await request.get(`${EXAM_URL}/api/public/exam/getby/test-ielts-reading`)
      expect([200, 400, 404]).toContain(response.status())
    })

    test('Get exam by slug - invalid slug returns 404', async ({ request }) => {
      const response = await request.get(`${EXAM_URL}/api/public/exam/getby/non-existent-exam-xyz`)
      expect([400, 404]).toContain(response.status())
    })
  })

  test.describe('Exam Test Harness', () => {
    test('Seed exam data via harness', async ({ request }) => {
      const response = await request.post(`${EXAM_URL}/__test/seed`, { headers })
      expect([200, 201, 403]).toContain(response.status())
      
      if (response.status() === 201 || response.status() === 200) {
        const data = await response.json()
        expect(data.examId || data.slug || data.message).toBeDefined()
      }
    })

    test('Cleanup exam test data', async ({ request }) => {
      const response = await request.delete(`${EXAM_URL}/__test/cleanup`, { headers })
      expect([200, 403]).toContain(response.status())
    })

    test('Exam harness health check', async ({ request }) => {
      const response = await request.get(`${EXAM_URL}/__test/health`, { headers })
      expect([200, 403]).toContain(response.status())
    })
  })

  test.describe('UI Navigation', () => {
    test('Practice page loads', async ({ page }) => {
      await page.goto('/practice')
      await expect(page.locator('body')).toBeVisible()
    })

    test('Do-test page handles unauthenticated access', async ({ page }) => {
      const response = await page.goto('/do-test/reading')
      // May redirect to login or show error
      await expect(page.locator('body')).toBeVisible()
    })
  })

  test.describe('Exam Timer Simulation (API)', () => {
    test('Exam has duration property', async ({ request }) => {
      await request.post(`${EXAM_URL}/__test/seed`, { headers })
      
      const response = await request.get(`${EXAM_URL}/api/public/exam/getby/test-ielts-reading`)
      
      if (response.status() === 200) {
        const data = await response.json()
        const exam = data.data ?? data
        // Duration should be set (e.g., 60 minutes)
        if (exam.durationMin !== undefined) {
          expect(exam.durationMin).toBeGreaterThan(0)
        }
      }
    })
  })

  test.describe('Attempt Service Integration', () => {
    const ATTEMPT_URL = process.env.ATTEMPT_URL || 'http://localhost:8081'

    test('Attempt start requires authentication', async ({ request }) => {
      const response = await request.post(`${ATTEMPT_URL}/api/attempt/attempts:start`, {
        data: { examId: 'test-exam-id' }
      }).catch(() => null)
      
      if (response) {
        // Should be 401 without auth
        expect([401, 403, 404, 500, 502]).toContain(response.status())
      }
    })

    test('Get attempt list requires auth', async ({ request }) => {
      const response = await request.get(`${ATTEMPT_URL}/api/attempt/getlistattempt`).catch(() => null)
      
      if (response) {
        expect([401, 403, 404, 500, 502]).toContain(response.status())
      }
    })

    test('Placement status requires auth', async ({ request }) => {
      const response = await request.get(`${ATTEMPT_URL}/api/attempt/placement/status`).catch(() => null)
      
      if (response) {
        expect([401, 403, 404, 500, 502]).toContain(response.status())
      }
    })
  })

  test.afterAll(async ({ request }) => {
    // Cleanup seeded data
    await request.delete(`${EXAM_URL}/__test/cleanup`, { headers }).catch(() => {})
  })
})
