/** Optional Photon image processing used for local image resizing. */
export type { PhotonImage as PhotonImageType } from "@silvia-odwyer/photon-node";

let photonModule: typeof import("@silvia-odwyer/photon-node") | null = null;
let loadPromise: Promise<typeof import("@silvia-odwyer/photon-node") | null> | null = null;

/** Load Photon from the installed Node package; image handling remains optional. */
export async function loadPhoton(): Promise<typeof import("@silvia-odwyer/photon-node") | null> {
	if (photonModule) return photonModule;
	if (loadPromise) return loadPromise;

	loadPromise = import("@silvia-odwyer/photon-node")
		.then((module) => (photonModule = module))
		.catch(() => null)
		.finally(() => { loadPromise = null; });
	return loadPromise;
}
