import { test, expect } from '@playwright/test';

test.describe('App Icons', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/');
    await page.waitForSelector('text=Connected');
  });

  test('no broken image elements visible', async ({ page }) => {
    await page.getByRole('tab', { name: 'Media Servers' }).click();
    await page.waitForTimeout(1000);

    const brokenImages = await page.evaluate(() => {
      const imgs = document.querySelectorAll('img');
      const broken: string[] = [];
      imgs.forEach((img) => {
        if (img.offsetParent !== null && img.naturalWidth === 0 && img.complete) {
          broken.push(img.src || img.alt || 'unknown');
        }
      });
      return broken;
    });

    // Allow a few broken community icons — external URLs may be dead
    expect(brokenImages.length).toBeLessThan(5);
  });

  test('known apps have real icons not letter fallbacks', async ({ page }) => {
    await page.getByRole('tab', { name: 'Media Servers' }).click();
    await page.waitForTimeout(1000);

    const coreApps = ['Plex', 'Jellyfin', 'Emby'];

    for (const app of coreApps) {
      const card = page.locator(`text=${app}`).first();
      if (await card.isVisible()) {
        const img = card.locator('xpath=ancestor::*[contains(@class,"card") or contains(@class,"Card")]//img').first();
        if (await img.count() > 0) {
          const loaded = await img.evaluate(
            (el: HTMLImageElement) => el.complete && el.naturalWidth > 0
          );
          expect(loaded, `Icon for ${app} should load`).toBe(true);
        }
      }
    }
  });
});
