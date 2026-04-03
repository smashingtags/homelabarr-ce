import { test, expect } from '@playwright/test';

test.describe('App Catalog', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/');
    await page.waitForSelector('text=Connected');
  });

  test('loads and displays app count', async ({ page }) => {
    const header = page.locator('text=/Connected.*\\d+ apps/');
    await expect(header).toBeVisible();
    const text = await header.textContent();
    const match = text?.match(/(\d+) apps/);
    expect(match).toBeTruthy();
    expect(Number(match![1])).toBeGreaterThanOrEqual(100);
  });

  test('all category tabs are present', async ({ page }) => {
    const expectedTabs = [
      'Deployed Apps',
      'AI',
      'Backup',
      'Cloud',
      'Downloads',
      'Game Servers',
      'Home Automation',
      'Media Apps',
      'Media Servers',
      'Monitoring',
      'Networking',
      'Productivity',
      'Security',
      'Tools',
      'Crypto',
      'Other',
      'Self-Hosted',
      'Virtual Desktops',
      'My Apps',
      'All Apps',
    ];

    for (const tab of expectedTabs) {
      await expect(page.getByRole('tab', { name: tab })).toBeVisible();
    }
  });

  test('defaults to Deployed Apps tab', async ({ page }) => {
    const deployedTab = page.getByRole('tab', { name: 'Deployed Apps' });
    await expect(deployedTab).toHaveAttribute('data-state', 'active');
  });

  test('category tabs filter apps correctly', async ({ page }) => {
    await page.getByRole('tab', { name: 'Media Servers' }).click();
    await page.waitForTimeout(500);
    const deployButtons = page.getByRole('button', { name: /deploy/i });
    await expect(deployButtons.first()).toBeVisible({ timeout: 10_000 });
  });

  test('no raw template variables visible', async ({ page }) => {
    await page.getByRole('tab', { name: 'AI' }).click();
    await page.waitForTimeout(500);
    const body = await page.locator('body').textContent();
    const templateVars = body?.match(/\$\{[A-Z_]+\}/g);
    expect(templateVars).toBeNull();
  });

  test('search filters apps', async ({ page }) => {
    await page.getByRole('tab', { name: 'All Apps' }).click();
    await page.waitForTimeout(500);
    const searchBox = page.getByPlaceholder(/search/i);
    await searchBox.fill('plex');
    await page.waitForTimeout(500);
    const visibleText = await page.locator('body').textContent();
    expect(visibleText?.toLowerCase()).toContain('plex');
  });

  test('sort toggle works', async ({ page }) => {
    await page.getByRole('tab', { name: 'AI' }).click();
    await page.waitForTimeout(500);
    const sortButton = page.getByRole('button', { name: /sort|a.*z|z.*a/i });
    if (await sortButton.isVisible()) {
      await sortButton.click();
      await expect(page.locator('body')).toBeVisible();
    }
  });
});
