// Beautiful rounded border and TUI layout utilities.
// Uses box-drawing characters: ╭ ╮ ╰ ╯ ─ │ ├ ┤
import chalk from 'chalk';
import { truncateToWidth, visibleWidth } from 'generation-tui';

/**
 * Render a rounded-border card enclosing the given content lines.
 * Guarantees every output line has visibleWidth <= width.
 */
export function renderRoundedBox(title, contentLines, width, {
  borderColor = chalk.cyan,
  titleColor = chalk.bold.cyan,
  bottomHint = '',
  paddingX = 1
} = {}) {
  if (width < 24) {
    return contentLines.map(l => truncateToWidth(l, width));
  }
  const innerWidth = Math.max(1, width - 2 - paddingX * 2);
  const padStr = ' '.repeat(paddingX);
  const result = [];

  // Top border with optional title
  if (title) {
    const titleText = ` ${title} `;
    const tW = visibleWidth(titleText);
    if (tW + 4 <= width) {
      const rightDashes = Math.max(0, width - 2 - 2 - tW);
      result.push(truncateToWidth(
        borderColor('╭─') + titleColor(titleText) + borderColor('─'.repeat(rightDashes) + '╮'),
        width
      ));
    } else {
      result.push(truncateToWidth(borderColor('╭' + '─'.repeat(Math.max(0, width - 2)) + '╮'), width));
    }
  } else {
    result.push(truncateToWidth(borderColor('╭' + '─'.repeat(Math.max(0, width - 2)) + '╮'), width));
  }

  // Content lines with left/right borders and padding
  for (const line of contentLines) {
    const truncated = truncateToWidth(line, innerWidth);
    const vW = visibleWidth(truncated);
    const rightPad = Math.max(0, innerWidth - vW);
    const row = borderColor('│') + padStr + truncated + ' '.repeat(rightPad) + padStr + borderColor('│');
    result.push(truncateToWidth(row, width));
  }

  // Bottom border with optional shortcut hint
  if (bottomHint) {
    const hintText = ` ${bottomHint} `;
    const hW = visibleWidth(hintText);
    if (hW + 4 <= width) {
      const rightDashes = Math.max(0, width - 2 - 2 - hW);
      result.push(truncateToWidth(
        borderColor('╰─') + chalk.dim(hintText) + borderColor('─'.repeat(rightDashes) + '╯'),
        width
      ));
    } else {
      result.push(truncateToWidth(borderColor('╰' + '─'.repeat(Math.max(0, width - 2)) + '╯'), width));
    }
  } else {
    result.push(truncateToWidth(borderColor('╰' + '─'.repeat(Math.max(0, width - 2)) + '╯'), width));
  }

  return result;
}

/**
 * Render a navigation tab strip with rounded corners.
 */
export function renderTabBar(tabs, activeTabId, width) {
  if (width < 30) {
    const active = tabs.find(t => t.id === activeTabId);
    return [truncateToWidth(`[${active?.label ?? activeTabId}]`, width)];
  }
  const tabElements = tabs.map(tab => {
    const isActive = tab.id === activeTabId;
    if (isActive) {
      return chalk.bgCyan.black.bold(` ${tab.key}: ${tab.label} `);
    }
    return chalk.dim(`[${tab.key}: ${tab.label}]`);
  });
  const barText = tabElements.join('  ');
  const innerWidth = Math.max(1, width - 4);
  const truncated = truncateToWidth(barText, innerWidth);
  const pad = Math.max(0, innerWidth - visibleWidth(truncated));
  return [
    truncateToWidth(chalk.cyan('╭─ ') + chalk.bold('Langfens Generation Harness') + chalk.cyan(' ─' + '─'.repeat(Math.max(0, width - 35)) + '╮'), width),
    truncateToWidth(chalk.cyan('│ ') + truncated + ' '.repeat(pad) + chalk.cyan(' │'), width),
    truncateToWidth(chalk.cyan('├' + '─'.repeat(Math.max(0, width - 2)) + '┤'), width)
  ];
}

/**
 * Render a rounded search input card.
 */
export function renderSearchBox(query, width, { prompt = '> ', hint = 'type to filter' } = {}) {
  if (width < 30) {
    return [truncateToWidth(`${prompt}${query}`, width)];
  }
  const innerWidth = Math.max(1, width - 4);
  const queryText = `${prompt}${query}`;
  const truncated = truncateToWidth(queryText, innerWidth);
  const pad = Math.max(0, innerWidth - visibleWidth(truncated));
  const topText = hint ? ` Search (${hint}) ` : ' Search ';
  const rightDashes = Math.max(0, width - 4 - visibleWidth(topText));
  return [
    truncateToWidth(chalk.dim('╭─') + chalk.dim(topText) + chalk.dim('─'.repeat(rightDashes) + '╮'), width),
    truncateToWidth(chalk.dim('│ ') + chalk.green.bold(prompt) + query + ' '.repeat(Math.max(0, innerWidth - visibleWidth(prompt) - visibleWidth(query))) + chalk.dim(' │'), width),
    truncateToWidth(chalk.dim('╰' + '─'.repeat(Math.max(0, width - 2)) + '╯'), width)
  ];
}
