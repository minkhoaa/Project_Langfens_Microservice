import { defineConfig, devices } from '@playwright/test'

/**
 * Playwright configuration for E2E tests
 * Tests run against real backend (Docker) via Gateway
 */
export default defineConfig({
  testDir: './e2e',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: 'html',
  
  use: {
    // Frontend URL (Next.js preview)
    baseURL: process.env.FRONTEND_URL || 'http://localhost:3000',
    
    // Backend Gateway URL
    extraHTTPHeaders: {
      'X-Test-Secret': process.env.TEST_SECRET || 'test-key',
    },
    
    // Recording settings for visual debugging
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
  },

  projects: [
    {
      name: 'chromium',
      use: { 
        ...devices['Desktop Chrome'],
        // SlowMo: set SLOW_MO env var to slow down actions (ms)
        launchOptions: {
          slowMo: parseInt(process.env.SLOW_MO || '0', 10),
        },
      },
    },
  ],

  // Web server to start before tests
  webServer: {
    command: 'npm run dev',
    url: 'http://localhost:3000',
    reuseExistingServer: !process.env.CI,
    timeout: 120 * 1000,
  },
})
