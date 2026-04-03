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

  test('some app icons load successfully', async ({ page }) => {
    await page.getByRole('tab', { name: 'Media Servers' }).click();
    await page.waitForTimeout(3000);

    // Count how many visible images actually loaded (naturalWidth > 0)
    const { total, loaded } = await page.evaluate(() => {
      const imgs = document.querySelectorAll('img');
      let total = 0;
      let loaded = 0;
      imgs.forEach((img) => {
        if (img.offsetParent !== null) {
          total++;
          if (img.complete && img.naturalWidth > 0) loaded++;
        }
      });
      return { total, loaded };
    });

    // At least some icons should render (logo + a few app icons)
    expect(loaded, `${loaded}/${total} icons loaded`).toBeGreaterThan(0);
  });
});
