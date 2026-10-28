/**
 * Test helper for API keys in tests.
 *
 * All global auth discovery (~/.pi/agent/auth.json or homedir) is strictly prohibited
 * to ensure offline isolation and avoid credential leakage or token consumption.
 * Tests use local in-memory mock fixtures only.
 */

const fixtureCredentials: Record<string, string> = {};

/** Set an in-memory fixture API key for a specific test/mock. */
export function setFixtureApiKey(provider: string, key: string | undefined): void {
	if (key === undefined) {
		delete fixtureCredentials[provider];
	} else {
		fixtureCredentials[provider] = key;
	}
}

/** Clear all in-memory fixture API keys. */
export function clearFixtureApiKeys(): void {
	for (const key of Object.keys(fixtureCredentials)) {
		delete fixtureCredentials[key];
	}
}

/**
 * Resolve API key for a provider in tests.
 * Returns only explicitly registered local test fixture keys.
 * Never accesses host filesystem, global configuration, or remote OAuth endpoints.
 */
export async function resolveApiKey(provider: string): Promise<string | undefined> {
	return fixtureCredentials[provider];
}
