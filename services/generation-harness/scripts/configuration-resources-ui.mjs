import chalk from 'chalk';
import { Input, Key, matchesKey, truncateToWidth, visibleWidth } from 'generation-tui';
import { inspectResources, resourceRows, toggleResource } from './configuration-resources.mjs';
import { configurationPanel } from './configuration-ui.mjs';
import { getHarnessAgents, getHarnessRoles, getHarnessTools } from './configuration-harness-info.mjs';
import { renderRoundedBox, renderSearchBox } from './configuration-box.mjs';

const labels = { extensions: 'Extensions', skills: 'Skills', prompts: 'Prompts', themes: 'Themes' };
const TABS = [
  { id: 'resources', key: 'F1', label: 'Resources (Exts & Skills)', short: 'F1 Resources' },
  { id: 'settings', key: 'F2', label: 'Config', short: 'F2 Config' },
  { id: 'roles', key: 'F3', label: 'Roles & Agents', short: 'F3 Roles/Agents' },
  { id: 'tools', key: 'F4', label: 'Tools', short: 'F4 Tools' },
];
const TAB_ORDER = ['resources', 'settings', 'roles', 'tools'];

export async function resourceConfigurationPanel(initial, {
  onClose = () => {},
  requestRender = () => {},
  height = 24,
  inspect = inspectResources,
  sessionTools,
  activeTools=[]
} = {}) {
  let controller = initial;
  let catalog = await inspect(controller);
  let rows = [];
  let selected = 0;
  let status = '';
  let busy = false;
  let settings = null;
  let pending = Promise.resolve();
  let activeTab = 'resources';
  let rolesScroll = 0;
  let toolsScroll = 0;

  let tabBounds = [];
  let rowStartOffset = 0;
  let startVisibleRowIndex = 0;
  let visibleRowCount = 0;
  let flatRows = [];

  const rolesData = getHarnessRoles();
  const agentsData = getHarnessAgents(controller.root,controller.runtime);
  const toolsData = getHarnessTools(controller.root,{runtimeTools:sessionTools,activeTools});

  const terminalHeight = () => typeof height === 'function' ? height() : height;
  const search = new Input({ prompt: '> ' });
  search.focused = true;
  const query = () => search.getValue().toLocaleLowerCase();
  const filtered = () => rows.filter(row => [row.name, row.group, row.type, row.path].some(v => v.toLocaleLowerCase().includes(query())));

  const rebuild = () => {
    rows = resourceRows(controller, catalog);
    for (const pkg of catalog.packages.filter(pkg => controller.scope === 'project' || pkg.scope === 'user')) {
      if (rows.some(row => row.metadata.source === pkg.source && row.metadata.scope === pkg.scope)) continue;
      rows.push({
        id: `package:${pkg.scope}:${pkg.source}`,
        type: 'status',
        group: `${pkg.source} (${pkg.scope})`,
        name: pkg.installedPath ? 'No resources discovered (check version/filter/manifest)' : 'Not installed / unavailable offline',
        path: pkg.installedPath ?? pkg.source,
        notice: true,
        metadata: { source: pkg.source, scope: pkg.scope }
      });
    }
    selected = Math.min(selected, Math.max(0, filtered().length - 1));
  };

  const settingsPanel = () => configurationPanel(controller, {
    requestRender,
    onClose: () => {
      settings = null;
      activeTab = 'resources';
      requestRender();
    }
  });

  const run = operation => {
    if (busy) return;
    busy = true;
    status = 'Reading native resource metadata…';
    requestRender();
    pending = (async () => {
      try {
        status = (await operation()) ?? 'Saved. Applies on next launch/reload; no resource was executed.';
      } catch (error) {
        status = error.message;
      } finally {
        busy = false;
        rebuild();
        requestRender();
      }
    })();
  };

  const switchScope = () => {
    run(async () => {
      controller = controller.forScope(controller.scope === 'user' ? 'project' : 'user');
      catalog = await inspect(controller);
      selected = 0;
      if (settings) settings = settingsPanel();
      return 'Scope changed; settings were not modified.';
    });
  };

  const switchTab = targetId => {
    if (targetId === activeTab) return;
    activeTab = targetId;
    if (activeTab === 'settings') {
      settings = settingsPanel();
    } else {
      settings = null;
    }
    if (activeTab === 'roles') rolesScroll = 0;
    if (activeTab === 'tools') toolsScroll = 0;
    requestRender();
  };

  const nextTab = () => {
    const idx = TAB_ORDER.indexOf(activeTab);
    switchTab(TAB_ORDER[(idx + 1) % TAB_ORDER.length]);
  };

  const prevTab = () => {
    const idx = TAB_ORDER.indexOf(activeTab);
    switchTab(TAB_ORDER[(idx - 1 + TAB_ORDER.length) % TAB_ORDER.length]);
  };

  rebuild();

  function renderTopTabs(width) {
    if (width < 32) return [];
    tabBounds = [];
    const isNarrow = width < 70;
    const elements = [];
    let currentX = 2;

    for (const tab of TABS) {
      const labelText = isNarrow ? tab.short : `${tab.key}: ${tab.label}`;
      const isActive = tab.id === activeTab;
      const formatted = isActive
        ? chalk.bgCyan.black.bold(` ${labelText} `)
        : chalk.dim(`[${labelText}]`);
      const len = visibleWidth(formatted);
      tabBounds.push({ id: tab.id, startX: currentX, endX: currentX + len });
      currentX += len + 2;
      elements.push(formatted);
    }

    const strip = elements.join('  ');
    const innerW = Math.max(1, width - 4);
    const truncated = truncateToWidth(strip, innerW);
    const titleText = ' Langfens Harness ';
    const rightDashes = Math.max(0, width - 4 - visibleWidth(titleText));
    return [
      truncateToWidth(chalk.cyan('╭─') + chalk.bold.cyan(titleText) + chalk.cyan('─'.repeat(rightDashes) + '╮'), width),
      truncateToWidth(chalk.cyan('│ ') + truncated + ' '.repeat(Math.max(0, innerW - visibleWidth(truncated))) + chalk.cyan(' │'), width),
      truncateToWidth(chalk.cyan('╰' + '─'.repeat(Math.max(0, width - 2)) + '╯'), width)
    ];
  }

  function renderCredentialsCard(ctrl, width) {
    const localCreds = ctrl.getAuthProviders?.() ?? [];
    const envCreds = ctrl.getEnvironmentProviders?.() ?? [];
    const lines = [];

    lines.push(chalk.dim('Creds Storage:  ') + chalk.cyan(ctrl.safeText(ctrl.paths.auth)));
    lines.push(chalk.dim('Models Config:  ') + chalk.dim(ctrl.safeText(ctrl.paths.models)));
    lines.push(chalk.dim('Isolation Mode: ') + chalk.green.bold('PROJECT_LOCAL_ONLY') + chalk.dim(' (local storage only; not a filesystem sandbox)'));
    lines.push('');

    lines.push(chalk.bold.yellow('Configured Model Providers (Project Runtime):'));
    if (localCreds.length === 0) {
      lines.push(chalk.yellow('  [!] No credentials configured in project runtime yet.'));
      lines.push(chalk.dim("  ▸ Save a provider key: 'npm run config -- --set-key <provider> <key>'"));
    } else {
      for (const c of localCreds) {
        const typeBadge = chalk.dim(`[${c.type}]`);
        lines.push(`  ${chalk.green('●')} ${chalk.bold.cyan(c.provider)} ${typeBadge} · ${chalk.green('Configured / Ready')}`);
      }
    }

    if (envCreds.length > 0) {
      lines.push('');
      lines.push(chalk.bold.yellow('Active Injected Environment Providers:'));
      for (const e of envCreds) {
        lines.push(`  ${chalk.cyan('▸')} ${chalk.bold.white(e.provider)} ${chalk.dim(`(${e.envVar})`)}`);
      }
    }

    return renderRoundedBox('Model Credentials & Authentication', lines, width, {
      borderColor: chalk.cyan,
      titleColor: chalk.bold.cyan,
      bottomHint: 'Set key: npm run config -- --set-key <prov> <key> · Esc: Back'
    });
  }

  function renderRolesView(width) {
    const lines = [];
    const headerTitle = 'Roles & Agents — F1 resources · F2 config · F3 roles/agents · F4 tools · esc back';
    lines.push(truncateToWidth(headerTitle, width));
    lines.push(...renderTopTabs(width));

    const content = [];
    content.push(chalk.bold.yellow('═══ IELTS GENERATION ROLES ═══'));
    for (const r of rolesData) {
      const icon = r.status === 'Active' ? chalk.green('●') : chalk.dim('○');
      const badge = r.status === 'Active' ? chalk.bgGreen.black.bold(' ACTIVE ') : chalk.dim('[AVAILABLE IF LOADED]');
      content.push(`${icon} ${chalk.bold.cyan(r.name)} ${badge} ${chalk.dim('· ' + r.scope)}`);
      content.push(`   ${r.description}`);
    }
    content.push('');

    content.push(chalk.bold.yellow('═══ IELTS AGENT ROSTER (.generation/agents/) ═══'));
    for (const ag of agentsData) {
      content.push(`${chalk.green('●')} ${chalk.bold.white(ag.name)} ${chalk.dim(`(${ag.file})`)}`);
      content.push(`   ${ag.description}`);
      if (ag.tools?.length) {
        content.push(chalk.dim('   Tools: ') + ag.tools.map(t => chalk.cyan(t)).join(', '));
      }
    }
    content.push('');

    content.push(chalk.bold.yellow('═══ CAPABILITIES & NATIVE AGENT DETAILS ═══'));
    for(const r of rolesData)if(r.contracts)content.push(chalk.dim(r.contracts));
    for (const r of rolesData.filter(x => x.pipeline)) {
      content.push(chalk.bold.cyan(`▶ ${r.name} Multi-Agent Pipeline:`));
      for (const step of r.pipeline) {
        content.push(`   ${chalk.cyan('▸')} ${step}`);
      }
      content.push(chalk.dim(`   Contracts: ${r.contracts}`));
      content.push('');
    }
    for (const ag of agentsData) {
      content.push(chalk.bold.white(`▶ Agent Policy: ${ag.name}`));
      if (ag.excludeTools?.length) {
        content.push(chalk.dim('   Excluded: ') + ag.excludeTools.map(t => chalk.red(t)).join(', '));
      }
      content.push(chalk.dim(`   Context: ${ag.context} · Mode: ${ag.promptMode}`));
      if (ag.summary) {
        content.push(chalk.dim(`   Instruction: ${truncateToWidth(ag.summary, Math.max(10, width - 20))}`));
      }
      content.push('');
    }

    const avail = Math.max(5, terminalHeight() - lines.length - 4);
    const maxScroll = Math.max(0, content.length - avail);
    rolesScroll = Math.max(0, Math.min(rolesScroll, maxScroll));
    const visibleContent = content.slice(rolesScroll, rolesScroll + avail);

    const boxed = renderRoundedBox(
      'Roles & Agents Overview',
      visibleContent,
      width,
      {
        borderColor: chalk.cyan,
        titleColor: chalk.bold.cyan,
        bottomHint: `Scroll: ↑/↓/W/S · Tabs: ←/→/A/D · Showing ${rolesScroll + 1}-${Math.min(content.length, rolesScroll + avail)} of ${content.length} · Esc: Back`
      }
    );
    lines.push(...boxed);
    return lines.map(l => truncateToWidth(l, width));
  }

  function renderToolsView(width) {
    const lines = [];
    const headerTitle = 'Tools — F1 resources · F2 config · F3 roles/agents · F4 tools · esc back';
    lines.push(truncateToWidth(headerTitle, width));
    lines.push(...renderTopTabs(width));

    const content = [];
    for (const cat of toolsData) {
      content.push(chalk.bold.yellow(`═══ ${cat.category} ═══`));
      for (const item of cat.items) {
        content.push(`${chalk.cyan('◆')} ${chalk.bold.green(item.name)} ${chalk.dim(`[${item.scope}]`)} · ${item.description}`);
      }
      content.push('');
    }

    content.push(chalk.bold.yellow('═══ TOOL PARAMETERS & SPECIFICATIONS ═══'));
    for (const cat of toolsData) {
      for (const item of cat.items) {
        content.push(chalk.bold.green(`▶ Tool: ${item.name}`));
        if (item.parameters) content.push(chalk.dim(`   Parameters: ${item.parameters}`));
        if (item.policy) content.push(chalk.dim(`   Policy: ${item.policy}`));
        content.push('');
      }
    }

    const avail = Math.max(5, terminalHeight() - lines.length - 4);
    const maxScroll = Math.max(0, content.length - avail);
    toolsScroll = Math.max(0, Math.min(toolsScroll, maxScroll));
    const visibleContent = content.slice(toolsScroll, toolsScroll + avail);

    const boxed = renderRoundedBox(
      'Harness & Domain Tools Inventory',
      visibleContent,
      width,
      {
        borderColor: chalk.cyan,
        titleColor: chalk.bold.cyan,
        bottomHint: `Scroll: ↑/↓/W/S · Tabs: ←/→/A/D · Showing ${toolsScroll + 1}-${Math.min(content.length, toolsScroll + avail)} of ${content.length} · Esc: Back`
      }
    );
    lines.push(...boxed);
    return lines.map(l => truncateToWidth(l, width));
  }

  function handleMouseInternal(event) {
    if (!event) return undefined;

    // Mouse wheel scrolling
    if (event.type === 'scroll-up' || (event.type === 'wheel' && event.wheelDelta < 0)) {
      if (activeTab === 'resources') {
        selected = Math.max(0, selected - 1);
      } else if (activeTab === 'roles') {
        rolesScroll = Math.max(0, rolesScroll - 2);
      } else if (activeTab === 'tools') {
        toolsScroll = Math.max(0, toolsScroll - 2);
      }
      requestRender();
      return { handled: true };
    }
    if (event.type === 'scroll-down' || (event.type === 'wheel' && event.wheelDelta > 0)) {
      if (activeTab === 'resources') {
        selected = Math.min(filtered().length - 1, selected + 1);
      } else if (activeTab === 'roles') {
        rolesScroll += 2;
      } else if (activeTab === 'tools') {
        toolsScroll += 2;
      }
      requestRender();
      return { handled: true };
    }

    // Mouse clicks & presses
    if (event.type === 'click' || event.type === 'press') {
      const clickY = event.y ?? event.screenY ?? 0;
      const clickX = event.x ?? event.screenX ?? 0;

      // Click on top header (row 0)
      if (clickY === 0) {
        if (clickX <= 22) {
          switchScope();
          return { handled: true };
        }
        if (clickX >= (event.width || 80) - 16) {
          if (activeTab !== 'resources') {
            activeTab = 'resources';
            settings = null;
          } else {
            onClose();
          }
          requestRender();
          return { handled: true };
        }
      }

      // Click on top tab bar (rows 2, 3, 4)
      if (clickY >= 2 && clickY <= 4 && tabBounds.length) {
        const clicked = tabBounds.find(t => clickX >= t.startX && clickX <= t.endX);
        if (clicked) {
          switchTab(clicked.id);
          return { handled: true };
        }
      }

      // Click on resource list items (in resources tab)
      if (activeTab === 'resources' && rowStartOffset > 0) {
        if (clickY >= rowStartOffset && clickY < rowStartOffset + visibleRowCount) {
          const rowRel = clickY - rowStartOffset;
          const matchEntry = flatRows[startVisibleRowIndex + rowRel];
          if (matchEntry && matchEntry.index !== undefined) {
            selected = matchEntry.index;
            const targetRow = filtered()[selected];
            if (targetRow && !targetRow.notice && !targetRow.locked) {
              run(async () => {
                toggleResource(controller, catalog, targetRow);
                catalog = await inspect(controller);
              });
            }
            requestRender();
            return { handled: true };
          }
        }
      }
    }

    return undefined;
  }

  function parseSgrMouseEvent(data) {
    if (typeof data !== 'string') return null;
    const match = data.match(/^\x1b\[<(\d+);(\d+);(\d+)([Mm])$/);
    if (!match) return null;
    const b = parseInt(match[1], 10);
    const x = parseInt(match[2], 10) - 1;
    const y = parseInt(match[3], 10) - 1;
    const isRelease = match[4] === 'm';
    if (b === 64) return { type: 'scroll-up', x, y };
    if (b === 65) return { type: 'scroll-down', x, y };
    if (isRelease) return { type: 'release', button: b, x, y };
    return { type: 'click', button: b, x, y };
  }

  const panel = {
    get focused() { return activeTab === 'resources' ? search.focused : true; },
    set focused(value) { if (activeTab === 'resources') search.focused = value; },
    invalidate() {
      search.invalidate();
      settings?.invalidate?.();
    },
    handleMouse: handleMouseInternal,

    render(width) {
      if (activeTab === 'settings' && settings) {
        const header = truncateToWidth('Settings — tab switch scope · F2 resources · esc back', width);
        const topTabs = renderTopTabs(width);
        const settingsLines = settings.render(width);
        const boxedSettings = renderRoundedBox(
          `Configuration (${controller.scope})`,
          settingsLines,
          width,
          {
            borderColor: chalk.cyan,
            titleColor: chalk.bold.cyan,
            bottomHint: 'Tab: Scope · Enter: Edit · Esc: Back · No host credential discovery'
          }
        );
        const credsCard = renderCredentialsCard(controller, width);
        return [header, ...topTabs, ...boxedSettings, '', ...credsCard].map(line => truncateToWidth(line, width));
      }

      if (activeTab === 'roles') {
        return renderRolesView(width);
      }

      if (activeTab === 'tools') {
        return renderToolsView(width);
      }

      // Resources View (Extensions & Skills)
      const title = controller.scope === 'user' ? 'Global Resources' : 'Project Resources';
      const hints = 'tab switch mode · space toggle · F2 settings · esc close';
      const header = visibleWidth(title) + visibleWidth(hints) + 2 <= width
        ? title + ' '.repeat(width - visibleWidth(title) - visibleWidth(hints)) + hints
        : `${title} · ${hints}`;

      const targetPath = controller.safeText(controller.target);
      const topTabs = renderTopTabs(width);
      const searchBox = renderSearchBox(search.getValue(), width);

      const matches = filtered();
      flatRows = [];
      let group, lastType;

      matches.forEach((row, index) => {
        if (row.group !== group) {
          group = row.group;
          lastType = null;
          const groupLabel = group.startsWith('npm:')
            ? chalk.magenta.bold(`  ${controller.safeText(group)}`)
            : group.startsWith('git:')
              ? chalk.cyan.bold(`  ${controller.safeText(group)}`)
              : chalk.blue.bold(`  ${controller.safeText(group)}`);
          flatRows.push({ text: `  ${controller.safeText(group)}`, styled: groupLabel });
        }
        if (row.type !== lastType) {
          lastType = row.type;
          flatRows.push({
            text: `    ${labels[row.type] ?? 'Status'}`,
            styled: chalk.yellow.bold(`    ${labels[row.type] ?? 'Status'}`)
          });
        }
        const check = row.notice
          ? '[?]'
          : controller.scope === 'project' && row.state !== 'inherit'
            ? row.state === 'load' ? '[+]' : '[-]'
            : row.enabled ? '[x]' : '[ ]';

        const styledCheck = row.notice
          ? chalk.red.bold('[?]')
          : controller.scope === 'project' && row.state !== 'inherit'
            ? row.state === 'load' ? chalk.green.bold('[+]') : chalk.yellow.bold('[-]')
            : row.enabled ? chalk.green.bold('[x]') : chalk.dim('[ ]');

        const suffix = row.notice
          ? ''
          : row.locked
            ? ' [fixed CLI]'
            : controller.scope === 'project'
              ? row.state === 'inherit' ? ' (inherit / native filter)' : ' (project override)'
              : '';

        const styledSuffix = row.notice
          ? ''
          : row.locked
            ? chalk.dim(' [fixed CLI]')
            : controller.scope === 'project'
              ? row.state === 'inherit' ? chalk.dim(' (inherit / native filter)') : chalk.cyan(' (project override)')
              : '';

        const nameStr = controller.safeText(row.name);
        const cursor = index === selected ? '> ' : '  ';
        const styledCursor = index === selected ? chalk.green.bold('> ') : '  ';
        const styledName = index === selected ? chalk.bold.white(nameStr) : nameStr;

        flatRows.push({
          index,
          text: `${cursor}    ${check} ${nameStr}${suffix}`,
          styled: `${styledCursor}    ${styledCheck} ${styledName}${styledSuffix}`
        });
      });

      const fixedOverhead = 2 + topTabs.length + searchBox.length + 5;
      const available = Math.max(3, terminalHeight() - fixedOverhead);
      const at = flatRows.findIndex(entry => entry.index === selected);
      startVisibleRowIndex = Math.max(0, Math.min(Math.max(0, at - Math.floor(available / 2)), flatRows.length - available));
      const visibleRows = flatRows.slice(startVisibleRowIndex, startVisibleRowIndex + available);
      visibleRowCount = visibleRows.length;
      rowStartOffset = 2 + topTabs.length + searchBox.length + 1; // 1 for card top border

      const treeLines = [];
      for (const entry of visibleRows) {
        treeLines.push(entry.styled ?? entry.text);
      }
      if (!matches.length) {
        treeLines.push(chalk.dim('  No matching resources.'));
      }

      const counterLine = `  (${matches.length ? selected + 1 : 0}/${matches.length}) · configured entries, not a running-session audit`;
      treeLines.push(chalk.dim(counterLine));

      if (controller.scope === 'project') {
        treeLines.push(chalk.dim('  Space cycles inherit / load / unload; inherited Global resources stay visible.'));
      }
      if (catalog.blockedProbes) {
        treeLines.push(chalk.dim('  Probes outside project/runtime were blocked. No host config was read.'));
      }
      if (status) {
        treeLines.push(chalk.cyan(`  ${controller.safeText(status)}`));
      }

      const cardTitle = `${title} (${controller.scope})`;
      const bottomHint = 'Tab: Scope · Space: Toggle · Arrows/WASD: Navigate · Click/Wheel: Mouse · Esc: Close';
      const boxedContent = renderRoundedBox(cardTitle, treeLines, width, {
        borderColor: chalk.cyan,
        titleColor: chalk.bold.cyan,
        bottomHint
      });

      return [
        truncateToWidth(header, width),
        truncateToWidth(targetPath, width),
        ...topTabs,
        ...searchBox,
        ...boxedContent
      ].map(line => truncateToWidth(line, width));
    },

    handleInput(data) {
      if (matchesKey(data, Key.ctrl('c'))) {
        onClose();
        return;
      }

      // Intercept SGR mouse sequences if passed directly in handleInput
      const sgrMouse = parseSgrMouseEvent(data);
      if (sgrMouse) {
        const mouseResult = handleMouseInternal(sgrMouse);
        if (mouseResult?.handled) return;
      }

      // Tab switcher function keys
      if (matchesKey(data, 'f1')) {
        switchTab('resources');
        return;
      }
      if (matchesKey(data, 'f2')) {
        if (activeTab === 'settings') {
          switchTab('resources');
        } else {
          switchTab('settings');
        }
        return;
      }
      if (matchesKey(data, 'f3')) {
        switchTab('roles');
        return;
      }
      if (matchesKey(data, 'f4')) {
        switchTab('tools');
        return;
      }

      // Text editing owns its keystrokes; WASD must not switch tabs or drop letters.
      if (activeTab === 'settings' && settings) {
        if(settings.editing?.()){settings.handleInput(data);requestRender();return;}
        if (matchesKey(data, Key.escape)) {
          switchTab('resources');
          return;
        }
        if (matchesKey(data, Key.tab)) {
          switchScope();
          return;
        }
        if (matchesKey(data, Key.left) || data.toLowerCase() === 'a') {
          prevTab();
          return;
        }
        if (matchesKey(data, Key.right) || data.toLowerCase() === 'd') {
          nextTab();
          return;
        }
        if (data.toLowerCase() === 'w') {
          settings.handleInput('\x1b[A');
          requestRender();
          return;
        }
        if (data.toLowerCase() === 's') {
          settings.handleInput('\x1b[B');
          requestRender();
          return;
        }
        settings.handleInput(data);
        requestRender();
        return;
      }

      // Handle input in Roles view (supports WASD, arrows, Tab, Esc)
      if (activeTab === 'roles') {
        if (matchesKey(data, Key.escape)) {
          switchTab('resources');
          return;
        }
        if (matchesKey(data, Key.up) || data.toLowerCase() === 'w') {
          rolesScroll = Math.max(0, rolesScroll - 1);
        } else if (matchesKey(data, Key.down) || data.toLowerCase() === 's') {
          rolesScroll++;
        } else if (matchesKey(data, Key.left) || data.toLowerCase() === 'a' || matchesKey(data, Key.shift('tab'))) {
          prevTab();
          return;
        } else if (matchesKey(data, Key.right) || data.toLowerCase() === 'd' || matchesKey(data, Key.tab)) {
          nextTab();
          return;
        } else if (matchesKey(data, Key.pageUp)) {
          rolesScroll = Math.max(0, rolesScroll - 10);
        } else if (matchesKey(data, Key.pageDown)) {
          rolesScroll += 10;
        } else if (matchesKey(data, Key.home)) {
          rolesScroll = 0;
        }
        requestRender();
        return;
      }

      // Handle input in Tools view (supports WASD, arrows, Tab, Esc)
      if (activeTab === 'tools') {
        if (matchesKey(data, Key.escape)) {
          switchTab('resources');
          return;
        }
        if (matchesKey(data, Key.up) || data.toLowerCase() === 'w') {
          toolsScroll = Math.max(0, toolsScroll - 1);
        } else if (matchesKey(data, Key.down) || data.toLowerCase() === 's') {
          toolsScroll++;
        } else if (matchesKey(data, Key.left) || data.toLowerCase() === 'a' || matchesKey(data, Key.shift('tab'))) {
          prevTab();
          return;
        } else if (matchesKey(data, Key.right) || data.toLowerCase() === 'd' || matchesKey(data, Key.tab)) {
          nextTab();
          return;
        } else if (matchesKey(data, Key.pageUp)) {
          toolsScroll = Math.max(0, toolsScroll - 10);
        } else if (matchesKey(data, Key.pageDown)) {
          toolsScroll += 10;
        } else if (matchesKey(data, Key.home)) {
          toolsScroll = 0;
        }
        requestRender();
        return;
      }

      // Handle input in Resources view
      if (matchesKey(data, Key.escape)) {
        onClose();
        return;
      }
      if (busy) return;

      if (matchesKey(data, Key.tab)) {
        switchScope();
        return;
      }
      if (matchesKey(data, Key.shift('tab'))) {
        prevTab();
        return;
      }

      // Alt+WASD navigation shortcuts
      if (data === '\x1bw' || matchesKey(data, Key.alt('w'))) {
        selected = Math.max(0, selected - 1);
        requestRender();
        return;
      }
      if (data === '\x1bs' || matchesKey(data, Key.alt('s'))) {
        selected = Math.min(filtered().length - 1, selected + 1);
        requestRender();
        return;
      }
      if (data === '\x1ba' || matchesKey(data, Key.alt('a'))) {
        prevTab();
        return;
      }
      if (data === '\x1bd' || matchesKey(data, Key.alt('d'))) {
        nextTab();
        return;
      }

      // Left/Right arrow tab navigation when search is empty
      if (search.getValue() === '') {
        if (matchesKey(data, Key.left)) {
          prevTab();
          return;
        }
        if (matchesKey(data, Key.right)) {
          nextTab();
          return;
        }
      }

      const matches = filtered();
      if (matchesKey(data, Key.up) || matchesKey(data, Key.down)) {
        selected = Math.max(0, Math.min(matches.length - 1, selected + (matchesKey(data, Key.up) ? -1 : 1)));
      } else if (matchesKey(data, Key.pageUp) || matchesKey(data, Key.pageDown)) {
        selected = Math.max(0, Math.min(matches.length - 1, selected + (matchesKey(data, Key.pageUp) ? -1 : 1) * Math.max(1, terminalHeight() - 12)));
      } else if (matchesKey(data, 'space') || matchesKey(data, Key.enter)) {
        const row = matches[selected];
        if (row?.notice) {
          status = 'No resource to toggle; packages are never installed by config.';
          requestRender();
        } else if (row) {
          run(async () => {
            toggleResource(controller, catalog, row);
            catalog = await inspect(controller);
          });
          return;
        }
      } else {
        search.handleInput(data);
        selected = 0;
      }
      requestRender();
    },

    whenIdle: () => pending,
    selectResource(id) {
      const index = filtered().findIndex(row => row.id === id);
      if (index >= 0) selected = index;
    },
    currentScope: () => controller.scope
  };

  return panel;
}
