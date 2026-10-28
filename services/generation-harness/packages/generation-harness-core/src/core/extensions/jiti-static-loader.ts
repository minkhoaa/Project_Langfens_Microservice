// The Node esbuild bundle needs jiti's static entry so the Babel transform is bundled.
// The module itself remains lazy until an extension is loaded.
export { createJiti } from "jiti/static";
