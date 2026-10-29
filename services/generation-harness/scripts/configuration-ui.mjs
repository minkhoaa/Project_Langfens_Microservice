// Standalone configuration screen using public native TUI components only.
// No AgentSession/ModelRuntime, login, or model catalog access.
import chalk from 'chalk';
import { Container, Input, Key, matchesKey, ProcessTerminal, SettingsList, Text, TuiMainScreen } from 'generation-tui';
import { dirname } from 'node:path';
import { preferences } from './configuration.mjs';

const styledTheme = {
  label: text => chalk.bold.white(text),
  value: text => chalk.cyan(text),
  description: text => chalk.dim(text),
  hint: text => chalk.yellow(text),
  cursor: chalk.green.bold('> ')
};

export function configurationPanel(controller, { onClose = () => {}, requestRender = () => {} } = {}) {
  const panel = new Container(), status = new Text('', 0, 0);
  const value = p => {
    const { preferences: current } = controller.show();
    const own = p.key.split('.').reduce((v, k) => v?.[k], controller.snapshot()[controller.scope]);
    return controller.safeText(own ?? current[p.key].value ?? '');
  };
  const persist = (key, raw) => {
    try {
      controller.update(key, raw);
      status.setText(chalk.green(`Saved ${key}. No model was called.`));
      return true;
    } catch (error) {
      status.setText(chalk.red(error.message));
      return false;
    } finally {
      requestRender();
    }
  };
  const items = preferences.map(p => ({
    id: p.key,
    label: p.label,
    currentValue: value(p),
    description: `${p.key} — saved in ${controller.scope} settings. Project overrides user settings.`,
    ...(p.values ? { values: p.values } : {
      submenu: (current, done) => {
        const input = new Input({ prompt: `${p.key}: ` });
        input.setValue(current);
        input.focused = true;
        const view = new Container();
        view.addChild(new Text(chalk.dim('Enter saves; Esc cancels. Use --unset to restore inheritance.'), 0, 0));
        view.addChild(input);
        view.handleInput = data => input.handleInput(data);
        Object.defineProperty(view, 'focused', { get: () => input.focused, set: v => { input.focused = v; } });
        input.onEscape = () => done();
        input.onSubmit = raw => { if (persist(p.key, raw)) done(raw); };
        return view;
      }
    })
  }));
  let list;
  list = new SettingsList(items, 10, styledTheme, (key, raw) => {
    if (!persist(key, raw)) list.updateValue(key, value(preferences.find(p => p.key === key)));
  }, onClose);

  const localCreds = controller.getAuthProviders?.().map(p => p.provider) || [];
  const header = `Langfens Harness — Configuration (${controller.scope})\n${chalk.dim(controller.safeText(controller.target))}\n${chalk.dim('Project Creds: ' + (localCreds.join(', ') || 'none') + ' (Storage: ' + controller.safeText(controller.paths.auth) + ')')}`;
  panel.addChild(new Text(header, 0, 0));
  panel.addChild(list);
  panel.addChild(status);
  panel.handleInput = data => {
    if (matchesKey(data, Key.ctrl('c'))) onClose();
    else list.handleInput(data);
  };
  panel.selectItem = key => list.selectItem(key);
  return panel;
}

export async function openConfiguration(controller, { terminal = new ProcessTerminal(), view = 'resources', onReady = () => {} } = {}) {
  const ui = new TuiMainScreen(terminal, false, dirname(controller.paths.user));
  const createPanel = view === 'settings'
    ? configurationPanel
    : (await import('./configuration-resources-ui.mjs')).resourceConfigurationPanel;
  let finish;
  const panel = await createPanel(controller, {
    onClose: () => finish?.(),
    requestRender: () => ui.requestRender(),
    height: () => terminal.rows
  });
  await new Promise((resolve, reject) => {
    let closed = false;
    const close = () => {
      if (closed) return;
      closed = true;
      ui.stop();
      process.off('SIGINT', close);
      process.off('SIGTERM', close);
      process.off('SIGHUP', close);
      resolve();
    };
    finish = close;
    ui.addChild(panel);
    ui.setFocus(panel);
    process.once('SIGINT', close);
    process.once('SIGTERM', close);
    process.once('SIGHUP', close);
    try {
      ui.start();
      onReady(panel);
    } catch (error) {
      reject(error);
      close();
    }
  });
}
