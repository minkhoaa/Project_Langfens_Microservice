export function areExperimentalFeaturesEnabled(): boolean {
	return process.env.LANGFENS_HARNESS_EXPERIMENTAL === "1";
}
