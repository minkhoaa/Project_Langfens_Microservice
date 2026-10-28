export function hasCloudflareWorkersAICredentials(): boolean {
	if (process.env.GENERATION_HARNESS_OFFLINE === "1") return false;
	return !!process.env.CLOUDFLARE_API_KEY && !!process.env.CLOUDFLARE_ACCOUNT_ID;
}

export function hasCloudflareAiGatewayCredentials(): boolean {
	if (process.env.GENERATION_HARNESS_OFFLINE === "1") return false;
	return (
		!!process.env.CLOUDFLARE_API_KEY && !!process.env.CLOUDFLARE_ACCOUNT_ID && !!process.env.CLOUDFLARE_GATEWAY_ID
	);
}
