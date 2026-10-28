/**
 * Clean Langfens Harness title for the interactive header.
 * Replaces upstream Pi graphical half-block logo with a clean wordmark title.
 */

import { theme } from "../theme/theme.ts";

/**
 * Returns false so the header renders a clean text wordmark header instead of
 * graphical half-block ANSI art that can misalign across different terminal fonts.
 */
export function supportsLogo(): boolean {
	return false;
}

/**
 * Clean styled wordmark for the header: bold accent-colored title.
 */
export function harnessWordmark(): string {
	return theme.bold(theme.fg("accent", "Langfens Harness"));
}

/**
 * Fallback logo lines for two-line header alignment if logo rendering is ever requested.
 */
export function harnessLogoLines(): [string, string] {
	return [harnessWordmark(), ""];
}
