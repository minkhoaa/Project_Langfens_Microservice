import { readdir, readFile, writeFile } from 'node:fs/promises';
import { join } from 'node:path';

const distDir = 'dist';
const entries = await readdir(distDir);
let count = 0;
for (const entry of entries) {
  if (!entry.endsWith('.js')) continue;
  const jsPath = join(distDir, entry);
  const mjsPath = join(distDir, entry.replace(/\.js$/, '.mjs'));
  let content = await readFile(jsPath, 'utf8');
  // Rewrite relative imports: from './foo' or '../foo' to './foo.mjs' / '../foo.mjs'
  content = content.replace(
    /(from\s+['"])(\.\.?\/[^'"]+?)(['"])/g,
    (match, prefix, spec, suffix) => {
      if (spec.endsWith('.mjs') || spec.endsWith('.js')) return match;
      return `${prefix}${spec}.mjs${suffix}`;
    }
  );
  await writeFile(mjsPath, content);
  count++;
}
console.log(`Mirrored ${count} .js files as .mjs`);
