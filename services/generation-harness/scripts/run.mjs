#!/usr/bin/env node
import { spawn } from "node:child_process";
import { runtimeLaunch } from "./runtime.mjs";

const launch = runtimeLaunch(process.argv.slice(2));
const child = spawn(launch.command, launch.args, { cwd: launch.cwd, env: launch.env, stdio: "inherit" });
for (const signal of ["SIGINT", "SIGTERM", "SIGHUP"]) process.on(signal, () => child.kill(signal));
child.on("error", (error) => { console.error(error.message); process.exitCode = 1; });
child.on("exit", (code, signal) => {
	process.exitCode = code ?? (signal === "SIGINT" ? 130 : signal === "SIGTERM" ? 143 : 1);
});
