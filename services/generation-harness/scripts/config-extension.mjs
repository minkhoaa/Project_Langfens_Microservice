import { configuration } from "./configuration.mjs";
import { resourceConfigurationPanel } from "./configuration-resources-ui.mjs";
import { getHarnessAgents, getHarnessRoles, getHarnessTools } from "./configuration-harness-info.mjs";

const CONFIG_COMMAND_OPTIONS = [
  { value: "full", label: "full — Load and print complete configuration summary" },
  { value: "creds", label: "creds — Show project model credentials and storage path" },
  { value: "local", label: "local — Open configuration TUI in Project scope" },
];

export function buildFullConfigSummary(controller) {
  const show = controller.show();
  const roles = getHarnessRoles();
  const agents = getHarnessAgents(controller.root);
  const tools = getHarnessTools();
  const localCreds = controller.getAuthProviders?.() ?? [];
  const envCreds = controller.getEnvironmentProviders?.() ?? [];

  const lines = [
    `# 🛠️ Langfens Harness — Full Configuration`,
    ``,
    `**Scope:** \`${controller.scope}\``,
    `**Project Settings:** \`${controller.paths.project}\``,
    `**User Settings:** \`${controller.paths.user}\``,
    `**Project Credentials Storage:** \`${controller.paths.auth}\``,
    `**Isolation Policy:** \`PROJECT_LOCAL_ONLY (Isolated for Production & Distribution)\``,
    ``,
    `## 🔑 Model Credentials & Authentication (Project Local)`,
    localCreds.length
      ? localCreds.map(c => `- **\`${c.provider}\`** (${c.type}): Ready / Configured in project`).join('\n')
      : `_No credentials configured in project runtime yet._`,
  ];

  if (envCreds.length > 0) {
    lines.push(
      ``,
      `### Injected Environment Providers:`,
      ...envCreds.map(e => `- **\`${e.provider}\`** via \`${e.envVar}\``)
    );
  }

  lines.push(
    ``,
    `_To configure a model provider key: \`npm run config -- --set-key <provider> <key>\`_`,
    ``,
    `## ⚙️ Preferences & Engine Settings`,
    ...Object.entries(show.preferences).map(([k, v]) => `- \`${k}\`: **${v.value ?? 'null'}** _(source: ${v.source})_`),
    ``,
    `## 🎓 IELTS Generation Roles`,
    ...roles.map(r => `- **${r.name}** [${r.status}]: ${r.description} _(${r.scope})_`),
    ``,
    `## 🤖 Specialized Agent Roster`,
    ...agents.map(a => `- **${a.name}** (\`${a.file}\`): ${a.description}\n  _Tools: ${a.tools.join(', ') || 'none'} · Context: ${a.context}_`),
    ``,
    `## 🛠️ Complete Tools Inventory`,
    ...tools.flatMap(cat => [
      `### ${cat.category}`,
      ...cat.items.map(t => `- **\`${t.name}\`** [${t.scope}]: ${t.description}`)
    ]),
    ``,
    `_Run \`/config\` without arguments to open the interactive TUI._`
  );

  return lines.join('\n');
}

/** Native extension registering /config slash command for interactive sessions. */
export default function configExtension(api) {
  api.registerCommand("config", {
    description: "Open the Langfens Harness Configuration TUI or load full config summary (/config [full|creds|local])",
    getArgumentCompletions(prefix) {
      const clean = prefix.trim().toLowerCase();
      return CONFIG_COMMAND_OPTIONS
        .filter(opt => opt.value.startsWith(clean))
        .map(opt => ({ value: opt.value, label: opt.label }));
    },
    async handler(args, ctx) {
      const modeArg = args?.trim().toLowerCase() ?? '';
      const controller = configuration({
        root: ctx.cwd,
        scope: modeArg === "local" || modeArg === "--local" || modeArg === "-l" ? "project" : "user"
      });

      // 1. Creds display action
      if (modeArg === "creds" || modeArg === "--creds") {
        const localCreds = controller.getAuthProviders();
        const envCreds = controller.getEnvironmentProviders();
        const lines = [
          `# 🔑 Project Model Credentials`,
          `- **Storage:** \`${controller.paths.auth}\``,
          `- **Isolation:** \`PROJECT_LOCAL_ONLY\` (Production-ready / zero host discovery)`,
          ``,
          `### Configured Providers in Project:`,
          localCreds.length ? localCreds.map(c => `- **${c.provider}** (${c.type}): Ready`).join('\n') : '_None configured yet_',
        ];
        if (envCreds.length > 0) {
          lines.push(
            ``,
            `### Active Environment Providers:`,
            ...envCreds.map(e => `- **${e.provider}** (${e.envVar})`)
          );
        }
        lines.push(
          ``,
          `_Configure a provider: \`npm run config -- --set-key <provider> <key>\`_`
        );
        api.sendMessage?.({ customType: "generation:slash-text-result", content: lines.join('\n'), display: true, details: { viewOnly: true } });
        return;
      }

      // 2. Full summary action or non-TUI mode fallback
      if (modeArg === "full" || modeArg === "--full" || modeArg === "show" || modeArg === "--show" || ctx.mode !== "tui" || !ctx.hasUI) {
        const summary = buildFullConfigSummary(controller);
        api.sendMessage?.({ customType: "generation:slash-text-result", content: summary, display: true, details: { viewOnly: true } });
        if (ctx.mode !== "tui" || !ctx.hasUI) {
          ctx.ui.notify?.("Printed full configuration summary. Run 'npm run config' for interactive TUI.", "info");
        }
        return;
      }

      // 3. Interactive TUI overlay mode
      await ctx.ui.custom(async (tui, _theme, _kb, done) => {
        return await resourceConfigurationPanel(controller, {
          onClose: () => done(undefined),
          requestRender: () => tui.requestRender(),
          height: () => tui.terminal?.rows ?? 24
        });
      }, {
        overlay: true,
        overlayOptions: { anchor: "center", width: "95%", minWidth: 60, maxHeight: "90%", margin: 1 }
      });
    }
  });
}
