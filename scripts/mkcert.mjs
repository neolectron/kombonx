import fsExtra from 'fs-extra';
import { mkdir } from 'fs/promises';
import { join } from 'path';
import { cwd } from 'process';
import { $ } from 'zx';

const certificates = join(cwd(), './docker/config/traefik/certificates');
const keyFile = 'kombo-dev.key';
const certificateFile = 'kombo-dev.cer';

if (
  fsExtra.existsSync(join(certificates, keyFile)) &&
  fsExtra.existsSync(join(certificates, certificateFile))
) {
  console.log(`Certificates already exist. Skipping generation.`);
  process.exit(0);
}

const mkcertExists = await $`command -v mkcert`;
if (!mkcertExists) {
  console.error(`mkcert is not installed. Check the README.`);
  process.exit(1);
}

const mkcertArguments = [
  `-cert-file=${join(certificates, certificateFile)}`,
  `-key-file=${join(certificates, keyFile)}`,
  '*.kombo.dev',
  'kombo.dev',
];

await mkdir(certificates, { recursive: true });

await $`mkcert -install`;
await $`mkcert ${mkcertArguments}`;

console.log(`Certificates generated.`);
