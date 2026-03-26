import { test, expect } from '@playwright/test';

test.describe('Visual Regression', () => {
  test('catalog light mode screenshot', async ({ page }) => {
    await page.goto('/');
    await page.waitForSelector('text=Connected');
    await page.evaluate(() => document.documentElement.classList.remove('dark'));
    await page.waitForTimeout(500);

    await expect(page).toHaveScreenshot('catalog-light.png', {
      fullPage: false,
      maxDiffPixelRatio: 0.05,
    });
  });

  test('catalog dark mode screenshot', async ({ page }) => {
    await page.goto('/');
    await page.waitForSelector('text=Connected');
    await page.evaluate(() => document.documentElement.classList.add('dark'));
    await page.waitForTimeout(500);

    await expect(page).toHaveScreenshot('catalog-dark.png', {
      fullPage: false,
      maxDiffPixelRatio: 0.05,
    });
  });

  test('media tab screenshot', async ({ page }) => {
    await page.goto('/');
    await page.waitForSelector('text=Connected');
    await page.getByRole('tab', { name: 'Media & Entertainment' }).click();
    await page.waitForTimeout(500);

    await expect(page).toHaveScreenshot('media-tab.png', {
      fullPage: false,
      maxDiffPixelRatio: 0.05,
    });
  });

  test('AI tab screenshot', async ({ page }) => {
    await page.goto('/');
    await page.waitForSelector('text=Connected');
    await page.getByRole('tab', { name: 'AI & Machine Learning' }).click();
    await page.waitForTimeout(500);

    await expect(page).toHaveScreenshot('ai-tab.png', {
      fullPage: false,
      maxDiffPixelRatio: 0.05,
    });
  });
});
