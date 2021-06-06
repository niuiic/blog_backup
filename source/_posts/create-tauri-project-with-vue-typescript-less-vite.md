---
title: Create Tauri Project with Vue-Typescript-Less-Vite
date: 2021-06-04 14:25:54
tags:
  - Tauri
  - Vue
  - Vite
  - Typescript
  - Less
categories:
  - [Vue]
  - [Rust]
---

# 创建 Tauri + Vue + Typescript + Vite + Less 应用

## 项目创建流程

直接上代码

`app_init.sh`

```sh
templatePath=xxx
echo "What's your app's name?"
read appName
yarn create @vitejs/app $appName --template vue-ts
cd $appName
yarn set version berry
cp "$templatePath/tauri/yarnrc.yml" .yarnrc.yml
yarn install
yarn add less -D
yarn add eslint eslint-plugin-vue -D
yarn add @vuedx/typescript-plugin-vue -D
rm ./tsconfig.json
cp "$templatePath/tauri/tsconfig.json" tsconfig.json
rm src/shims-vue.d.ts
rm vite.config.ts
cp "$templatePath/tauri/vite.config.ts" vite.config.ts
cp "$templatePath/tauri/tauri-plugin.ts" tauri-plugin.ts
yarn add tauri @types/sharp
yarn add @rollup/plugin-replace -D
yarn tauri init
```

`$templatePath`自定，注意模板文件在`$templatePath/tauri`下。

以上涉及的几个文件放在下面。

`yarnrc.yml`

```yml
yarnPath: ".yarn/releases/yarn-berry.cjs"
nodeLinker: node-modules
npmRegistryServer: "https://registry.npm.taobao.org/"
```

`tauri-plugin.ts`

```typescript
import { TauriConfig } from "tauri/src/types";
import type { Plugin, ConfigEnv, ResolvedConfig } from "vite";
import tauriConf from "./src-tauri/tauri.conf.json";
import dev from "tauri/dist/api/dev";
import build from "tauri/dist/api/build";
import replace from "@rollup/plugin-replace";
import { isAbsolute, resolve } from "path";

interface Options {
  config?: (c: TauriConfig, e: ConfigEnv) => TauriConfig;
}

export default (options?: Options): Plugin => {
  let tauriConfig = { ...tauriConf };
  let viteConfig: ResolvedConfig;
  return {
    ...replace({
      "process.env.IS_TAURI": true,
    }),
    name: "tauri-plugin",
    configureServer(server) {
      server.httpServer.on("listening", () => {
        if (!process.env.TAURI_SERVE) {
          process.env.TAURI_SERVE = "true";
          const serverOptions = server.config.server || {};
          let port = serverOptions.port || 3000;
          let hostname = serverOptions.host || "localhost";
          if (hostname === "0.0.0.0") {
            hostname = "localhost";
          }
          const protocol = serverOptions.https ? "https" : "http";
          const base = server.config.base;
          const url = `${protocol}://${hostname}:${port}${base}`;
          tauriConfig.build.devPath = url;
          dev(tauriConfig);
        }
      });
    },
    closeBundle() {
      if (!process.env.TAURI_BUILD) {
        process.env.TAURI_BUILD = "true";
        let distDir = viteConfig.build.outDir;
        if (!isAbsolute(distDir)) {
          distDir = resolve(viteConfig.root, distDir);
        }
        tauriConfig.build.distDir = distDir;
        return build(tauriConfig);
      }
    },
    config(viteConfig, env) {
      process.env.IS_TAURI = "true";
      if (options && options.config) {
        options.config(tauriConfig, env);
      }
      if (env.command === "build") {
        viteConfig.base = "/";
      }
    },
    configResolved(resolvedConfig) {
      viteConfig = resolvedConfig;
    },
  };
};
```

`tsconfig.json`

```json
{
  "compilerOptions": {
    "target": "esnext",
    "module": "esnext",
    "moduleResolution": "node",
    "strict": true,
    "jsx": "preserve",
    "sourceMap": true,
    "resolveJsonModule": true,
    "plugins": [
      {
        "name": "@vuedx/typescript-plugin-vue"
      },
      {
        "name": "eslint-plugin-vue"
      }
    ],
    "esModuleInterop": true,
    "lib": ["esnext", "dom"],
    "types": ["vite/client"]
  },
  "include": ["src/**/*.ts", "src/**/*.d.ts", "src/**/*.tsx", "src/**/*.vue"]
}
```

`vite.config.ts`

```typescript
import { defineConfig } from "vite";
import vue from "@vitejs/plugin-vue";
import tauri from "./tauri-plugin";

export default defineConfig({
  plugins: [vue(), tauri()],
  server: {
    hmr: { overlay: false },
  },
  resolve: {
    alias: { vue: "vue/dist/vue.esm-bundler.js" },
  },
});
```

## 说明

初始化 tauri 应用时，设置目录需要与上面的配置对应，即为`../dist`。设置 url 为`http://127.0.0.1:3000`。

`vite.config.ts`中关于 server 的配置是为了屏蔽调试出现的一个错误。该错误原因不明（测试结果为当 tauri 应用的名称和 vue 项目的名称相同时会发生），应该是 vite 的问题，不影响项目调试和编译打包。

使用`yarn dev`进行调试，使用`yarn build`进行打包。当前设置默认打包格式为 deb 和 AppImage。打包需要额外的工具与配置，根据报错信息自行补充即可。
