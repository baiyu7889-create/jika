import {readFileSync,writeFileSync} from 'node:fs';
import {fileURLToPath} from 'node:url';
import {dirname,join} from 'node:path';

const root=dirname(fileURLToPath(import.meta.url));
const sourcePath=join(root,'index.html');
const outputPath=join(root,'operations-prototype.html');
const source=readFileSync(sourcePath,'utf8');
const output=source
  .replace('<html lang="zh-CN">','<html lang="zh-CN" class="prototype-mode">')
  .replace('<title>基咔 · H5 / App MVP 原型</title>','<title>基咔 · 运营验收原型</title>');

writeFileSync(outputPath,output,'utf8');
console.log(`Generated ${outputPath}`);
