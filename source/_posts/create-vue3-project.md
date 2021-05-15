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

> yarn2 的一系列操作让人迷惑，不想折腾了。

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
