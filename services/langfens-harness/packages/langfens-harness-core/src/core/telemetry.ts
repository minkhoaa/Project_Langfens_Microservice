import type { SettingsManager } from "./settings-manager.ts";

/** The standalone subsystem never sends upstream installation telemetry. */
export function isInstallTelemetryEnabled(
	_settingsManager: SettingsManager,
	_telemetryEnv?: string,
): boolean {
	return false;
}
