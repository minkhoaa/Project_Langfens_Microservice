export function areExperimentalFeaturesEnabled(): boolean {
	return process.env.GENERATION_HARNESS_EXPERIMENTAL === "1";
}
