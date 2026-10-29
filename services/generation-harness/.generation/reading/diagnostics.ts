import { Value } from "typebox/value";
import type { TSchema } from "typebox";

export function shape(value: unknown): string {
  if (value === undefined) return "missing";
  if (value === null) return "null";
  if (Array.isArray(value)) return `array(length=${value.length}; items=${[...new Set(value.map(shape))].join("|")})`;
  if (typeof value === "object") return `object(keys=${Object.keys(value).sort().join(",")})`;
  return typeof value; // Do not echo private answer values in schema diagnostics.
}
function at(value: unknown, pointer: string): unknown {
  for (const key of pointer.split("/").slice(1).map(k => k.replace(/~1/g, "/").replace(/~0/g, "~"))) {
    if (!value || typeof value !== "object" || !Object.hasOwn(value, key)) return undefined;
    value = (value as Record<string, unknown>)[key];
  }
  return value;
}
export function schemaIssues(schema: TSchema, value: unknown) {
  return [...Value.Errors(schema, value)].flatMap(e => {
    const required = (e.params as { requiredProperties?: string[] }).requiredProperties;
    const pointers = required?.length ? required.map(k => `${e.instancePath}/${k.replace(/~/g, "~0").replace(/\//g, "~1")}`) : [e.instancePath];
    return pointers.map(pointer => ({
      code: "INPUT_SCHEMA_INVALID", severity: "error" as const, category: "invalid-input" as const,
      path: pointer || "/", keyword: e.keyword,
      expected: `${e.message}; constraints=${JSON.stringify(e.params)}`,
      actual: shape(at(value, pointer)),
      message: e.message,
      repairGuidance: "Repair only the indicated field against the selected contract; do not coerce types or invent keys.",
    }));
  });
}
export function formatTypeBoxErrors(schema: TSchema, value: unknown): string {
  const errors = schemaIssues(schema, value);
  return errors.slice(0, 8).map(e => `at '${e.path}': [${e.keyword}] expected ${e.expected}; actual ${e.actual}. Repair guidance: ${e.repairGuidance}`).join("; ") +
    (errors.length > 8 ? `; ${errors.length - 8} further violations omitted` : "");
}
