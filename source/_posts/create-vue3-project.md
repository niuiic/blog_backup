---
title: Create Vue3 Project
date: 2021-05-15 22:06:13
tags:
		- Vue
		- Vite
		- Typescript
		- Less
categories:
		- Vue
---

# 创建 vue3 项目（vue3 + vite + typescript + less）

首先声明一下，笔者只是刚玩了会 vue, 和 `cannot find module vue`斗智斗勇了半天。好不容易搞定了，来分享一下。以下不会涉及关于 vue 开发的具体内容。

使用 npm 作为包管理器。

> yarn2 的一系列操作让人迷惑，本来不想折腾了。最后还是忍不住折腾了一把，用法放在最后面。

创建项目

```sh
# 使用vue + ts的模板创建项目
npm init @vitejs/app $appName -- --template vue-ts
cd appName
# 安装less
npm install less -D
# 这是coc-vetur的依赖项，不使用vim + coc.nvim 的可以忽略
npm install eslint eslint-plugin-vue -D
# 这是在vue文件中解决cannot find module问题的插件
npm install @vuedx/typescript-plugin-vue -D
```

现在可以进入项目，使用`npm run dev`运行。

> npm7 以上版本会出错，使用`node node_modules/esbuild/install.js`解决。

为了解决 ts 文件中`cannot find module vue`的问题，还需要做以下设置。

在`tsconfig.json`中加入

```json
    "plugins": [
      {
        "name": "@vuedx/typescript-plugin-vue"
      }
    ],
```

> 可以以同样方式加入 eslint-plugin-vue。

如果你使用的是 vim/neovim + coc-vetur，则在`coc-settings.json`中配置`"vetur.useWorkspaceDependencies": true`。这一步是让插件使用项目内的依赖，否则插件在全局找不到刚才安装的插件。

如果你使用 vscode，设置` "Select TypeScript version" -> "Use workspace version"`。[参考](https://github.com/vitejs/vite/tree/main/packages/create-app/template-vue-ts)

注意，此时已经不需要`src/shims-vue.d.ts`。

笔者不使用 vscode，不过从[参考](https://github.com/vitejs/vite/tree/main/packages/create-app/template-vue-ts)的描述来看，应该是可以对 vue 文件和 ts 文件都产生作用。在 vim + coc.nvim 的环境中，两种文件均可生效。

在 neovim + coc.nvim 环境下进行测试。

1. 不启用任何插件，无论有没有`src/shims-vue.d.ts`文件，vue 文件中`import { defineComponent } from 'vue'`都不报错，`import HelloWorld from './components/HelloWorld.vue'`也不报错。
2. 只要启用`eslint-plugin-vue`插件，就可以防止 ts 文件中`import { createApp } from 'vue'`出错。但是如果没有`src/shims-vue.d.ts`文件，`import App from './App.vue'`还是会出错。
3. 继续启用`@vuedx/typescript-plugin-vue`，删掉`src/shims-vue.d.ts`，一切正常。

为了在挂载自定义组件的时候不出错，还需要设置根目录下的`vite.config.ts`如下。

```typescript
import { defineConfig } from "vite";
import vue from "@vitejs/plugin-vue";

export default defineConfig({
  plugins: [vue()],
  resolve: {
    alias: { vue: "vue/dist/vue.esm-bundler.js" },
  },
});
```

使用 yarn2 代替 npm。

首先安装 yarn1。

> yarn2 的默认用法是把自己当成依赖安装在项目中。如果在全局安装 yarn2，也需要在项目中才能执行命令。同时 yarn2 无法执行 create 命令，还需要依靠 yarn1。

```sh
# 在全局安装yarn1
npm -g install yarn
# 初始化项目
yarn create @vitejs/app appName --template vue-ts
# 升级成yarn2
cd appName
yarn set version berry
```

修改项目根目录下`.yarnrc.yml`。

```yml
yarnPath: ".yarn/releases/yarn-berry.cjs"
nodeLinker: node-modules
npmRegistries: https://registry.npm.taobao.org/
```

第二行的配置是让 yarn2 完全用 npm 的方式安装依赖。否则是不存在`node_modules`的，也就不能调用插件。虽然这样做丧失了 yarn2 的特性，但是比起 npm 至少速度上可以快点。

继续完成项目初始化。

```sh
yarn install
yarn add less -D
yarn add eslint eslint-plugin-vue -D
yarn add @vuedx/typescript-plugin-vue -D
```
