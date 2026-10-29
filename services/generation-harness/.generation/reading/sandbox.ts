import { spawnSync } from "node:child_process";
import { existsSync, lstatSync } from "node:fs";
import { isAbsolute, relative } from "node:path";
import type { ExtensionAPI } from "generation-harness-core";
import { policyError } from "./scopes.ts";
const quote = (text: string) => `'${text.replaceAll("'", "'\\''")}'`;

/** Tiny command language AND an OS read-only mount boundary, never arbitrary shell filtering. */
export function scopedBash(api: ExtensionAPI, root: string, pathFor: (raw: unknown, writing?: boolean, mustExist?: boolean) => string, cwd = root) {
  const bwrap = process.env.GENERATION_HARNESS_READING_BWRAP;
  let ready: boolean | undefined, problem = "BWRAP_NOT_CONFIGURED: Bubblewrap has no configured path";
  const mounts = ["/usr/lib", "/lib", "/lib64"].filter(existsSync);
  const args = (command: string[]) => ["--unshare-all", "--die-with-parent", "--new-session", "--clearenv", "--setenv", "LC_ALL", "C",
    ...mounts.flatMap(path => ["--ro-bind", path, path]), "--dir", "/bin",
    ...["pwd", "ls", "wc", "true"].flatMap(name => ["--ro-bind", `/bin/${name}`, `/bin/${name}`]),
    "--ro-bind", root, "/work", "--chdir", `/work/${relative(root, cwd)}`, "--", ...command];
  return (raw: unknown) => {
    const settings = api.getSettings();
    if (settings.shellCommandPrefix || (settings.shellPath && settings.shellPath !== "/bin/bash") ||
        process.env.BASH_ENV || process.env.ENV || Object.keys(process.env).some(key => key.startsWith("LD_") || key.startsWith("DYLD_") || key.startsWith("BASH_FUNC_"))) policyError("Unsupported shell configuration/environment");
    if (ready === undefined) {
      ready = false;
      if (process.platform !== "linux") problem = "BWRAP_UNSUPPORTED_PLATFORM: Linux namespaces are required";
      else if (bwrap) {
        if (!isAbsolute(bwrap)) problem = "BWRAP_INVALID_PATH: An absolute executable path is required";
        else try {
          const stat = lstatSync(bwrap);
          if (!stat.isFile() || stat.uid !== 0 || (stat.mode & 0o022) || !(stat.mode & 0o111)) problem = "BWRAP_UNSAFE_EXECUTABLE: Require a root-owned executable without group/world write access";
          else {
            const probe = spawnSync(bwrap, args(["/bin/true"]), { timeout: 3000, encoding: "utf8", env: {} });
            ready = probe.status === 0;
            problem = `BWRAP_PROBE_FAILED: ${String(probe.error?.message ?? probe.stderr ?? probe.status).replace(/[\x00-\x1f\x7f]/gu, " ").slice(0, 400)}`;
          }
        } catch (error) { problem = (error as NodeJS.ErrnoException).code === "ENOENT" ? `BWRAP_NOT_FOUND: ${bwrap}` : `BWRAP_UNAVAILABLE: ${String(error)}`; }
      }
    }
    if (!ready || !bwrap) policyError(`${problem}. Configure --reading-bwrap /absolute/path after installing/enabling Bubblewrap; no unsandboxed fallback.`);
    if (typeof raw !== "string") policyError("Invalid bash command");
    const match = /^(pwd|ls|wc)(?: ([a-zA-Z0-9_./-]+))?$/.exec(raw as string);
    if (!match || (match[1] === "pwd" && match[2]) || (match[1] === "wc" && !match[2])) policyError("Only pwd, ls [path], wc <file> are supported");
    const operation = match![1], path = pathFor(match![2] ?? ".", false, true);
    if (operation === "wc" && !lstatSync(path).isFile()) policyError("wc requires a regular file");
    const command = operation === "pwd" ? ["/bin/pwd"] : [`/bin/${operation}`, "--", `/work/${relative(root, path)}`];
    return [bwrap!, ...args(command)].map(quote).join(" ");
  };
}
