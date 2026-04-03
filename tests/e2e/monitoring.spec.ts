import { test, expect } from '@playwright/test';

const GRAFANA_URL = process.env.GRAFANA_URL || 'http://192.168.1.250:3000';
const GRAFANA_USER = 'admin';
const GRAFANA_PASS = 'admin';

test.describe('Monitoring Stack', () => {

  test('Grafana requires login', async ({ page }) => {
    await page.goto(GRAFANA_URL);
    await expect(page.locator('input[name="user"]')).toBeVisible({ timeout: 10000 });
  });

  test('Grafana login works with admin/admin', async ({ page }) => {
    await page.goto(`${GRAFANA_URL}/login`);
    await page.fill('input[name="user"]', GRAFANA_USER);
    await page.fill('input[name="password"]', GRAFANA_PASS);
    await page.click('button[type="submit"]');
    // Grafana prompts to change password on first login — skip it if shown
    await page.waitForTimeout(2000);
    const skipButton = page.locator('a:has-text("Skip"), button:has-text("Skip")');
    if (await skipButton.isVisible({ timeout: 3000 }).catch(() => false)) {
      await skipButton.click();
      await page.waitForTimeout(2000);
    }
    // Verify we're logged in — "Logged in" toast or we're past the login form
    const loggedIn = await page.locator('text=Logged in').isVisible({ timeout: 3000 }).catch(() => false)
      || await page.locator('input[name="user"]').isHidden({ timeout: 3000 }).catch(() => false);
    expect(loggedIn).toBeTruthy();
  });

  test('all 4 dashboards are loaded', async ({ request }) => {
    const dashboards = [
      'homelabarr-v2-overview',
      'node-exporter-monitoring',
      'cadvisor-monitoring',
      'promtail-monitoring',
    ];

    for (const uid of dashboards) {
      const res = await request.get(`${GRAFANA_URL}/api/dashboards/uid/${uid}`, {
        headers: {
          Authorization: `Basic ${Buffer.from(`${GRAFANA_USER}:${GRAFANA_PASS}`).toString('base64')}`,
        },
      });
      expect(res.status(), `Dashboard ${uid} should exist`).toBe(200);
      const data = await res.json();
      expect(data.dashboard.uid).toBe(uid);
    }
  });

  test('all 4 dashboards are starred', async ({ request }) => {
    const res = await request.get(`${GRAFANA_URL}/api/search?starred=true`, {
      headers: {
        Authorization: `Basic ${Buffer.from(`${GRAFANA_USER}:${GRAFANA_PASS}`).toString('base64')}`,
      },
    });
    expect(res.status()).toBe(200);
    const starred = await res.json();
    expect(starred.length).toBeGreaterThanOrEqual(4);
  });

  test('Prometheus has active targets', async ({ request }) => {
    // Query Prometheus through Grafana's datasource proxy
    const res = await request.get(
      `${GRAFANA_URL}/api/datasources/uid/prometheus/resources/api/v1/targets`,
      {
        headers: {
          Authorization: `Basic ${Buffer.from(`${GRAFANA_USER}:${GRAFANA_PASS}`).toString('base64')}`,
        },
      }
    );
    expect(res.status()).toBe(200);
    const data = await res.json();
    const active = data.data.activeTargets;
    expect(active.length).toBeGreaterThanOrEqual(4);

    const healthy = active.filter((t: any) => t.health === 'up');
    expect(healthy.length, 'At least 3 targets should be up').toBeGreaterThanOrEqual(3);
  });

  test('Prometheus has CPU and memory data', async ({ request }) => {
    const auth = {
      headers: {
        Authorization: `Basic ${Buffer.from(`${GRAFANA_USER}:${GRAFANA_PASS}`).toString('base64')}`,
      },
    };

    // CPU data
    const cpuRes = await request.get(
      `${GRAFANA_URL}/api/datasources/uid/prometheus/resources/api/v1/query?query=node_cpu_seconds_total`,
      auth
    );
    expect(cpuRes.status()).toBe(200);
    const cpuData = await cpuRes.json();
    expect(cpuData.data.result.length, 'CPU metrics should exist').toBeGreaterThan(0);

    // Memory data
    const memRes = await request.get(
      `${GRAFANA_URL}/api/datasources/uid/prometheus/resources/api/v1/query?query=node_memory_MemTotal_bytes`,
      auth
    );
    expect(memRes.status()).toBe(200);
    const memData = await memRes.json();
    expect(memData.data.result.length, 'Memory metrics should exist').toBeGreaterThan(0);
  });

  test('Prometheus has container metrics', async ({ request }) => {
    const res = await request.get(
      `${GRAFANA_URL}/api/datasources/uid/prometheus/resources/api/v1/query?query=container_cpu_usage_seconds_total`,
      {
        headers: {
          Authorization: `Basic ${Buffer.from(`${GRAFANA_USER}:${GRAFANA_PASS}`).toString('base64')}`,
        },
      }
    );
    expect(res.status()).toBe(200);
    const data = await res.json();
    expect(data.data.result.length, 'Container metrics should exist').toBeGreaterThan(0);
  });

  test('overview dashboard panels render with data', async ({ page }) => {
    // Login
    await page.goto(`${GRAFANA_URL}/login`);
    await page.fill('input[name="user"]', GRAFANA_USER);
    await page.fill('input[name="password"]', GRAFANA_PASS);
    await page.click('button[type="submit"]');
    await page.waitForTimeout(3000);

    // Navigate to overview dashboard
    await page.goto(`${GRAFANA_URL}/d/homelabarr-v2-overview`);
    await page.waitForTimeout(5000);

    // Check that "No data" doesn't appear in all panels
    const noDataCount = await page.locator('text="No data"').count();
    const panelCount = await page.locator('[data-testid="data-testid Panel header"]').count()
      || await page.locator('.panel-container').count()
      || 5; // fallback

    // Allow some panels without data but not ALL
    expect(noDataCount, 'Not all panels should show "No data"').toBeLessThan(panelCount);
  });

  test('node exporter dashboard has data', async ({ page }) => {
    await page.goto(`${GRAFANA_URL}/login`);
    await page.fill('input[name="user"]', GRAFANA_USER);
    await page.fill('input[name="password"]', GRAFANA_PASS);
    await page.click('button[type="submit"]');
    await page.waitForTimeout(3000);

    await page.goto(`${GRAFANA_URL}/d/node-exporter-monitoring`);
    await page.waitForTimeout(5000);

    const noDataCount = await page.locator('text="No data"').count();
    expect(noDataCount, 'Node Exporter dashboard should have data').toBeLessThan(3);
  });

  test('cadvisor dashboard has data', async ({ page }) => {
    await page.goto(`${GRAFANA_URL}/login`);
    await page.fill('input[name="user"]', GRAFANA_USER);
    await page.fill('input[name="password"]', GRAFANA_PASS);
    await page.click('button[type="submit"]');
    await page.waitForTimeout(3000);

    await page.goto(`${GRAFANA_URL}/d/cadvisor-monitoring`);
    await page.waitForTimeout(5000);

    const noDataCount = await page.locator('text="No data"').count();
    expect(noDataCount, 'cAdvisor dashboard should have data').toBeLessThan(3);
  });

  test('navigation bar links work on all dashboards', async ({ page }) => {
    await page.goto(`${GRAFANA_URL}/login`);
    await page.fill('input[name="user"]', GRAFANA_USER);
    await page.fill('input[name="password"]', GRAFANA_PASS);
    await page.click('button[type="submit"]');
    await page.waitForTimeout(3000);

    // Start on overview
    await page.goto(`${GRAFANA_URL}/d/homelabarr-v2-overview`);
    await page.waitForTimeout(3000);

    // Click System link in nav bar
    const systemLink = page.locator('a:has-text("System")').first();
    if (await systemLink.isVisible()) {
      await systemLink.click();
      await page.waitForTimeout(2000);
      await expect(page).toHaveURL(/node-exporter/);
    }

    // Click Containers link
    await page.goto(`${GRAFANA_URL}/d/homelabarr-v2-overview`);
    await page.waitForTimeout(2000);
    const containersLink = page.locator('a:has-text("Containers")').first();
    if (await containersLink.isVisible()) {
      await containersLink.click();
      await page.waitForTimeout(2000);
      await expect(page).toHaveURL(/cadvisor/);
    }
  });

  test('Loki has container logs', async ({ request }) => {
    const res = await request.get(
      `${GRAFANA_URL}/api/datasources/uid/loki/resources/loki/api/v1/labels`,
      {
        headers: {
          Authorization: `Basic ${Buffer.from(`${GRAFANA_USER}:${GRAFANA_PASS}`).toString('base64')}`,
        },
      }
    );
    // Loki might not be running (optional) — skip if 502/404
    if (res.status() === 200) {
      const data = await res.json();
      expect(data.data.length, 'Loki should have labels from container logs').toBeGreaterThan(0);
      expect(data.data).toContain('container');
    }
  });
});
