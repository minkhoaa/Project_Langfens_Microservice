/**
 * Emit per-type deref'd JSON Schema for LLM validators.
 *
 * Source: ../../docs/schemas/<slug>.schema.json  (21 per-type files).
 * Each per-type schema references shared $defs via cross-file $ref
 * like `_shared.schema.json#/$defs/Rubric`. Some LLM validators
 * (notably OpenAI structured output) do not follow cross-file refs
 * reliably, so we emit a single-file dereferenced copy per type.
 *
 * Output: ./dist/json/<slug>.deref.schema.json  (21 files).
 *
 * Run as the final step of `npm run build`.
 */
import { readFile, writeFile, mkdir } from 'node:fs/promises';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import $RefParser from '@apidevtools/json-schema-ref-parser';

const __dirname = dirname(fileURLToPath(import.meta.url));
const pkgRoot = join(__dirname, '..');
const schemasDir = join(pkgRoot, '..', '..', 'docs', 'schemas');
const outDir = join(pkgRoot, 'dist', 'json');

await mkdir(outDir, { recursive: true });

// Slug list comes from the registry (`docs/schemas/_registry.json`), which
// is the single source of truth. Each entry has `{ slug, file }`.
const registry = JSON.parse(await readFile(join(schemasDir, '_registry.json'), 'utf8'));
const entries = Array.isArray(registry.types) ? registry.types : [];

let count = 0;
for (const entry of entries) {
  const file = entry?.file;
  if (typeof file !== 'string' || !file.endsWith('.schema.json')) continue;

  const srcPath = join(schemasDir, file);
  const dstPath = join(outDir, file.replace(/\.schema\.json$/, '.deref.schema.json'));

  // Load source once; capture $id/$schema so we can restore them on the
  // deref'd output (some LLM validators key on $id).
  const raw = JSON.parse(await readFile(srcPath, 'utf8'));
  const originalId = raw.$id;
  const originalSchema = raw.$schema;

  // @apidevtools/json-schema-ref-parser uses the schema's $id as the base
  // for resolving refs. Our $id is `https://langfens.dev/schemas/...`,
  // which would force an online fetch of `_shared.schema.json`. We pass
  // the file path so the resolver treats cross-file refs as relative to
  // the local filesystem. `mutate: false` keeps the stripped input clean.
  // Circular refs are disabled; the schemas are acyclic by design.
  const stripped = { ...raw };
  delete stripped.$id;
  delete stripped.$schema;

  const deref = await $RefParser.dereference(srcPath, stripped, {
    mutateData: false,
    dereferenceCircularReferences: false,
  });

  if (deref && typeof deref === 'object') {
    if (originalId) deref.$id = originalId;
    if (originalSchema) deref.$schema = originalSchema;
  }

  await writeFile(dstPath, JSON.stringify(deref, null, 2) + '\n', 'utf8');
  count++;
}

console.log(`Wrote ${count} deref'd schema files to dist/json/`);
