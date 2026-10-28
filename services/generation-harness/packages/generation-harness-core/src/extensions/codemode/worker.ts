/**
 * Worker entry bundled as a separate Node esbuild entrypoint because the dependency worker is not
 * available as a physical file in the bundle; `getCodemodeWorkerSpecifier()` resolves it.
 */
import "generation-codemode/worker";
