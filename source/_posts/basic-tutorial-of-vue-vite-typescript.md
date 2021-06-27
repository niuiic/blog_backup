---
title: Basic Tutorial of Vue-Vite-Typescript
date: 2021-05-17 22:08:07
tags:
  - Vue
  - Vite
  - Typescript
categories:
  - Vue
---

# Basic Tutorial of Vue-Vite-Typescript

The following are the notes I took when I studied vue with reference to the official tutorial. The biggest difference between my notes and official tutorial is that I use typescript while the tutorial uses javascript. I suggest you learn vue following the official tutorial , but I firmly believe that you need to know some of the differences in the use of ts and js.

And please forgive my stiff English, I was just too lazy to switch input methods.

## Init a vue project

Create the project

```
npm init @vitejs/app appName -- --template vue-ts
cd appName
npm install
npm install less -D
npm install eslint eslint-plugin-vue -D
npm install @vuedx/typescript-plugin-vue -D
node node_modules/esbuild/install.js
```

Modify `coc-settings.json`

```
  "vetur.useWorkspaceDependencies": true
```

Add the content below to `tsconfig.json`

```json
    "plugins": [
      {
        "name": "@vuedx/typescript-plugin-vue"
      }
    ],
```

Modify `vite.config.ts` which is located in the root path of the project.

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

## Directory structure of the project

![directory structure](1.png)

1. public : public resource directory
2. src/assets : static resource directory
3. src/components : custom components
4. src/App.vue : root component
5. src/main.ts : root entry
6. index.css : root css
7. index.html : page entry

## Run project

Use `yarn dev` to run the project. And then you can check your page at browser.

## Content of the vue file

```vue
# src/App.vue # html part
<template>
  <h1>{{ msg }}</h1>
</template>

# typescript part
<script charset="utf-8">
export default {
  data() {
    return {
      msg: "hello vue",
    };
  },
};
</script>

# css part
<style type="text/css" media="screen">
h1 {
  text-align: center;
  color: red;
}
</style>
```

## Commentary

In html part (inside of template lable), the commentary looks like this. `<!-- annotation -->`

In css part (inside of style lable), the commentary looks like this. `/* annotation */`

In typescript part (inside of script lable), the commentary looks like this. `// annotation` or `/* annotation */`

The content outside of the label does not effect.

## Create an application instance

Each vue application is created by function `createApp`. For example, you can create an application like this.

```typescript
import { createApp } from "vue";
import App from "./App.vue";
const app = createApp(App);
app.mount("#app");
```

In the above code, `app` is our root component. We use method `mount` to mount `app` to `#app`.

`#app` represents a html label whose id is app. And by default, `#app` is declared in `index.html`. For example, `<div id="app"></div>`.

The method `mount` returns an instance of the root component. You can get the properties of the component through its instance.

```typescript
const app = Vue.createApp({
  data() {
    return { count: 4 };
  },
});

const vm = app.mount("#app");

console.log(vm.count);
```

A component contains custom properties and inner properties. You can also get inner properties through the instance of the component using `$`. For example, `$attrs`.

## lifecycle hook

Lifetime hook is a function which would be called automatically in different stages of the program runtime.

For instance, you can use `created` hook to execute your code after an instance has been created.

```typescript
Vue.createApp({
  data() {
    return { count: 1 };
  },
  created() {
    /* `this` point to the instance of the component */
    console.log("count is: " + this.count);
  },
});
```

Do not use arrow function in properties. For example, `created: () => console.log("hello")`.

## Template syntax

### Variable binding

You can bind typescript variables to html part.

1. Usually the syntax is `{{ variable }}`.

2. But if you want to bind a html label, the code needs to be changed.

```vue
<template>
  <div>
    <p>
      <!-- failed to bind -->
      {{ msg }}
    </p>
    <!-- successfully bind to html -->
    <p>bind html label : <span v-html="msg"></span></p>
  </div>
</template>

<script charset="utf-8">
export default {
  data() {
    return {
      msg: "<h2> hello </h2>",
    };
  },
};
</script>
```

3. In order to bind attributes, the syntax will look like this.

```vue
<template>
  <div>
    <img v-bind:src="imgPath" alt="" />
    <!-- or -->
    <img :src="imgPath" alt="" />
  </div>
</template>

<script charset="utf-8">
export default {
  data() {
    return {
		imgPath="imgPath"
    };
  },
};
</script>
```

4. To bind dynamic attributes.

```vue
<template>
  <div>
    <!-- cause an error due to the static url -->
    <a v-bind:[attributeName]="http://www.url.com" target="_blank"
      >Anchor Text</a
    >
    <!-- you can fix the error in this way -->
    <a v-bind:[attributeName]="'http://www.url.com'" target="_blank"
      >Anchor Text</a
    >
    <!-- or you can also bind the url -->
    <a v-bind:[attributeName]="link" target="_blank">Anchor Text</a>
  </div>
</template>

<script charset="utf-8">
export default {
  data() {
    return {
      attributeName: "href",
      link: "http://www.url.com",
    };
  },
};
</script>
```

5. Loop traversal

```vue
<template>
  <div>
    <ul>
      <!-- :key is necessary, and each key must be unique -->
      <li v-for="(item, index) in list" :key="index">
        {{ index }}--{{ item }}
      </li>
    </ul>
  </div>
</template>

<script charset="utf-8">
export default {
  data() {
    return {
      list: ["hello", "world"],
    };
  },
};
</script>
```

`v-for` with a range.

```html
<div id="range" class="demo">
  <span v-for="n in 10" :key="n">{{ n }} </span>
</div>
```

6. Only bind once

```vue
<template>
  <!-- this would never change -->
  <span v-once>{{ msg }}</span>
</template>
```

7. Bind js expressions

```vue
<template>
  {{ msg + 1 }}
</template>
```

### Method, class and style binding

1. Bind method

```vue
<template>
  <div>
    {{ msg }}
    <button @click="setMsg">set msg</button>
    <button @click="getMsg">get msg</button>
  </div>
</template>

<script charset="utf-8">
export default {
  data() {
    return {
      msg: "hello",
    };
  },
  methods: {
    setMsg() {
      this.msg = "changed msg";
      /* you can call methods with `this` */
      this.getMsg();
    },
    getMsg() {
      alert(this.msg);
    },
  },
};
</script>
```

```vue
<template>
  {{ counter }}
  <br />
  <!-- You can call a method directly in the template. It will be called multiple -->
  <!-- times in the rendering stage of the template. So the value of counter is not -->
  <!-- sure. -->
  {{ count() }}
  <button @click="count">click here to count</button>
</template>

<script lang="ts">
export default {
  data() {
    return {
      counter: 1,
    };
  },
  methods: {
    count() {
      this.$data.counter++;
    },
  },
};
</script>

<style lang="less" scoped></style>
```

Bind method with paramaters.

```vue
<template>
  <button @click="getMessage($event)">click here</button>
</template>

<script lang="ts">
export default {
  data() {
    return {};
  },
  methods: {
    getMessage(e: any) {
      e.target.style.background = "red";
      alert(e);
    },
  },
};
</script>

<style lang="less" scoped></style>
```

You can also bind methods with mutiple paramaters, like this. Note that event must be the last paramater.

```vue
<template>
  <button @click="getMessage('hello', $event)">click here</button>
</template>

<script lang="ts">
export default {
  data() {
    return {};
  },
  methods: {
    getMessage(str: string, e: any) {
      e.target.style.background = "red";
      console.log(str);
      alert(e);
    },
  },
};
</script>

<style lang="less" scoped></style>
```

Bind mutiple methods.

```
<template>
  <button @click="hello1($event), hello2($event)">click here</button>
</template>

<script lang="ts">
export default {
  data() {
    return {};
  },
  methods: {
    hello1(e: any) {
      e.target.style.background = "red";
    },
    hello2(e: any) {
      alert(e);
    },
  },
};
</script>

<style lang="less" scoped>
</style>
```

Use event modifiers.

```html
<a @click.stop="doSomething"></a>
<!-- the modifiers provided by vue is listed below -->
<!-- 1. .stop -->
<!-- 2. .prevent -->
<!-- 3. .capture -->
<!-- 4. .self -->
<!-- 5. .once -->
<!-- 6. .passive -->
```

There are also key modifiers, such as `<input @keyup.enter = "submit" />`.

You can use key aliases, such as `.enter`, `.tab`, `.delete`, `.esc`, `.space`, `.up`, `.down`, `.left`, `.right`, instead of key modifiers.

System modifier keys such as `.ctrl`, `.alt`, `.shift`, `.meta` are also useful.

2. Bind class

```vue
<template>
  <div class="custom"></div>
</template>

<style lang="less" scoped>
.custom {
  background: red;
  height: 100px;
  width: 100px;
}
</style>
```

You can also bind classes dynamically.

```vue
<template>
  <div :class="myClass"></div>
</template>

<script lang="ts">
export default {
  data() {
    return {
      myClass: "custom",
    };
  },
};
</script>

<style lang="less" scoped>
.custom {
  background: red;
  height: 100px;
  width: 100px;
}
</style>
```

Optionally bind classes and bind more than one class at one time.

```vue
<template>
  <!-- bind class `active` and `error` optionally and also bind class `custom` -->
  <div class="custom" :class="{ active: isActive, error: isError }"></div>

  <!-- bind class `active` or `error` -->
  <div class="{isActive ? active : error}"></div>

  <!-- bind class `custom` and `active` -->
  <div :class="['active', 'custom']"></div>
</template>

<script lang="ts">
export default {
  data() {
    return {
      isActive: true,
      isError: false,
    };
  },
};
</script>

<style lang="less" scoped>
.custom {
  margin: 10px;
}
.active {
  background: yellowgreen;
  height: 100px;
  width: 100px;
}
.error {
  background: red;
  height: 100px;
  width: 100px;
}
</style>
```

3. Bind style

```vue
<template>
  <div :style="{ color: myColor, fontSize: myFontSize }">hello</div>
</template>

<script lang="ts">
export default {
  data() {
    return {
      myColor: "red",
      myFontSize: "190px",
    };
  },
};
</script>
```

You can also bind styles optionally or in a form of array like the class binding.

#### Instance : monitor an input box

1. The first option

```vue
<template>
  <!-- key up event will be triggered when your keyboard pops up. -->
  <input type="text" @keyup="doSearch($event)" />
</template>

<script lang="ts">
export default {
  data() {
    return {};
  },
  methods: {
    doSearch(e: any) {
      console.log(e.keyCode);
      /* check the input to confirm whether `enter` is pressed. */
      if (e.keyCode == 13) {
        alert("enter key is pressed");
        /* do search */
      }
    },
  },
};
</script>

<style lang="less" scoped></style>
```

2. The second option

```vue
<template>
  <!-- key up event will be triggered when your keyboard pops up. -->
  <!-- keyup.enter will be triggered when you input a `enter` -->
  <input type="text" @keyup.enter="doSearch($event)" />
</template>

<script lang="ts">
export default {
  data() {
    return {};
  },
  methods: {
    doSearch(e: any) {
      /* no need to check the input */
      console.log(e.keyCode);
    },
  },
};
</script>

<style lang="less" scoped></style>
```

### DOM

```vue
<template>
  <ul>
    <li>name : <input type="text" id="username" /></li>
    <li>age : <input type="text" ref="age" /></li>
  </ul>
  <button @click="doSubmit()" class="submit">get content</button>
</template>

<script lang="ts">
export default {
  data() {
    return {};
  },
  methods: {
    doSubmit() {
      var username = document.querySelector("#username");
      if (username != null) {
        console.log(username);
      }
      console.log(this.$refs.age);
    },
  },
};
</script>

<style lang="less" scoped></style>
```

### Two-way binding

DOM consumes a lot of resources. We use the way of two-way binding to get values instead.

```vue
<template>
  <ul>
    <!-- two-way binding -->
    <li>name : <input type="text" id="username" v-model="username" /></li>
  </ul>
  <button @click="doSubmit()" class="submit">get content</button>
</template>

<script lang="ts">
export default {
  data() {
    return {
      /* two-way binding */
      username: "jack",
    };
  },
  methods: {
    doSubmit() {
      console.log(this.username);
    },
  },
};
</script>

<style lang="less" scoped></style>
```

There are some modifiers for `v-model` binding, suck as `.lazy`, `.number`, `.trim`.

### If else

```vue
<template>
  {{ num == 1 ? "num=1" : "num!=1" }}
  <div v-if="num == 1">hello div</div>
  <!-- this is invaild and will not take effect -->
  <span vi-else>hello span</span>

  <!-- this is the correct code -->
  <div v-if="num == 1">hello div</div>
  <!-- if num != 1, the label will be deleted by DOM -->
  <div v-else>goodbye div</div>

  <!-- if num != 1, the label will be hidden by css -->
  <div v-show="num == 1">hello div</div>
</template>

<script lang="ts">
export default {
  data() {
    return {
      num: 2,
    };
  },
};
</script>
```

### Compute

The function declared in `computed` will be called when variables changed.

```vue
<template>
  {{ calculateNum }}
</template>

<script lang="ts">
export default {
  data() {
    return { message: "hello" };
  },
  computed: {
    calculateNum: function () {
      let self = this as any;
      return self.message.split("").reverse().join("");
      /* The lsp will report an error when using the code below. But it will not cause error during the runtime.*/
      /* return this.message.split("").reverse().join(""); */
    },
  },
};
</script>

<style lang="less" scoped></style>
```

The error in above code is caused by the static type checking of typescript lsp. Once you meet this error, and feel confused about the solution. You can fix it by transforming the type to `any`.

### Watcher

```vue
<template>
  {{ counter }}
  {{ count }}
  <button @click="counter++">click me</button>
</template>

<script lang="ts">
export default {
  data() {
    return { counter: 1, count: 0 };
  },
  watch: {
    /* the name of the function must be the same as the variable you want to watch */
    counter: function (value) {
      this.count = value * 2;
    },
  },
};
</script>

<style lang="less" scoped></style>
```

### Less

```vue
<template>
  <div class="todolist">
    <h3>TodoList</h3>
  </div>
</template>

<script lang="ts">
export default {
  data() {},
};
</script>

<style lang="less" scoped>
.todolist {
  width: 500px;
  height: 500px;
  background-color: green;
  h3 {
    color: red;
  }
}
</style>
```

### Debouncing and Throttling

You can implement debouncing and throttling by using libraries such as `Lodash`.

```html
<script src="https://unpkg.com/lodash@4.17.20/lodash.min.js"></script>
<script>
  Vue.createApp({
    methods: {
      // Debouncing with Lodash
      click: _.debounce(function () {
        // ... respond to click ...
      }, 500),
    },
  }).mount("#app");
</script>
```

If you want to keep the component instance independently, you can add the debounced function in the created lifecycle hook.

```typescript
app.component("save-button", {
  created() {
    // Debouncing with Lodash
    this.debouncedClick = _.debounce(this.click, 500);
  },
  unmounted() {
    // Cancel the timer when the component is removed
    this.debouncedClick.cancel();
  },
  methods: {
    click() {
      // ... respond to click ...
    },
  },
  template: `
    <button @click="debouncedClick">
      Save
    </button>
  `,
});
```

Here is the [advanced tutorial](https://www.niuiic.top/2021/06/06/advanced-tutorial-of-vue-vite-typescript/).
