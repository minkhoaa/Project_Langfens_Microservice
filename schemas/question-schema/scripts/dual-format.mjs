import { readdir, readFile, writeFile } from 'node:fs/promises';
import { join } from 'node:path';

const distDir = 'dist';
const entries = await readdir(distDir);
let count = 0;
for (const entry of entries) {
  if (!entry.endsWith('.js')) continue;
  const jsPath = join(distDir, entry);
  const mjsPath = join(distDir, entry.replace(/\.js$/, '.mjs'));
  const original = await readFile(jsPath, 'utf8');

  // Rewrite relative imports for the CJS .js bundle: from './foo' -> from './foo.js'.
  // Node 26 ESM-strict-mode (and ESM-with-require-conditions) rejects extension-less
  // relative specifiers in CJS files when they are resolved via the ESM resolver.
  const jsContent = original.replace(
    /(from\s+['"])(\.\.?\/[^'"]+?)(['"])/g,
    (match, prefix, spec, suffix) => {
      if (spec.endsWith('.mjs') || spec.endsWith('.js')) return match;
      return `${prefix}${spec}.js${suffix}`;
    }
  );
  if (jsContent !== original) {
    await writeFile(jsPath, jsContent);
  }

  // Emit the .mjs mirror with .mjs extensions on relative imports.
  // Derive from `original` (not `jsContent`) so the .js early-return above does
  // not suppress the .mjs rewrite.
  const mjsContent = original.replace(
    /(from\s+['"])(\.\.?\/[^'"]+?)(['"])/g,
    (match, prefix, spec, suffix) => {
      if (spec.endsWith('.mjs') || spec.endsWith('.js')) return match;
      return `${prefix}${spec}.mjs${suffix}`;
    }
  );
  await writeFile(mjsPath, mjsContent);
  count++;
}
console.log(`Mirrored ${count} .js files as .mjs (with .js extensions on relative imports)`);
