import yaml from 'yaml';

function sanitizeName(name) {
  if (!name) return '';
  return name.toLowerCase().replace(/[^a-z0-9-]/g, '-').replace(/-+/g, '-').replace(/^-|-$/g, '');
}

function rewritePath(hostPath) {
  if (!hostPath) return hostPath;
  if (hostPath.startsWith('/mnt/user/appdata/')) {
    return hostPath.replace('/mnt/user/appdata/', '/opt/appdata/');
  }
  if (hostPath.startsWith('/mnt/user/')) {
    return hostPath.replace('/mnt/user/', '/mnt/');
  }
  return hostPath;
}

function parseConfig(config, appName) {
  const ports = [];
  const volumes = [];
  const envVars = [];

  if (!Array.isArray(config)) return { ports, volumes, envVars };
  const safeName = appName || 'app';

  for (const entry of config) {
    const attrs = entry?.['@attributes'] || entry;
    if (!attrs?.Type) continue;

    const type = attrs.Type;
    const target = attrs.Target || '';
    const defaultVal = attrs.Default || '';
    const mode = attrs.Mode || '';

    switch (type) {
      case 'Port': {
        const hostPort = defaultVal || target;
        const proto = mode || 'tcp';
        ports.push(`${hostPort}:${target}/${proto}`);
        break;
      }
      case 'Path': {
        const hostPath = rewritePath(defaultVal) || `/opt/appdata/${safeName}${target}`;
        const rw = mode || 'rw';
        if (target) volumes.push(`${hostPath}:${target}:${rw}`);
        break;
      }
      case 'Variable': {
        if (target && defaultVal) {
          envVars.push({ key: target, value: defaultVal });
        }
        break;
      }
    }
  }

  return { ports, volumes, envVars };
}

export function generateComposeObject(app) {
  if (!app?.Repository) return null;

  const name = sanitizeName(app.Name || 'app');
  const isHostNetwork = (app.Network || '').toLowerCase() === 'host';
  const { ports, volumes, envVars } = parseConfig(app.Config, name);

  const envMap = new Map(envVars.map(e => [e.key, e.value]));
  if (!envMap.has('PUID')) envMap.set('PUID', '1000');
  if (!envMap.has('PGID')) envMap.set('PGID', '1000');
  if (!envMap.has('TZ')) envMap.set('TZ', 'UTC');

  const environment = [];
  for (const key of ['PGID', 'PUID', 'TZ']) {
    environment.push(`${key}=${envMap.get(key)}`);
    envMap.delete(key);
  }
  for (const [key, value] of envMap) {
    environment.push(`${key}=${value}`);
  }

  const service = {
    hostname: name,
    container_name: name,
    image: app.Repository,
    restart: 'unless-stopped',
    environment,
  };

  if (isHostNetwork) {
    service.network_mode = 'host';
  } else {
    if (ports.length > 0) {
      service.ports = ports;
    }
    service.networks = ['proxy'];
  }

  if (volumes.length > 0) {
    service.volumes = volumes;
  }

  if (app.Privileged === 'true' || app.Privileged === true) {
    service.privileged = true;
  }

  const compose = {
    services: { [name]: service },
  };

  if (!isHostNetwork) {
    compose.networks = {
      proxy: {
        driver: 'bridge',
        external: true,
      },
    };
  }

  return compose;
}

export function generateCompose(app) {
  const obj = generateComposeObject(app);
  if (!obj) return null;
  return '---\n' + yaml.stringify(obj, { lineWidth: 0 });
}
