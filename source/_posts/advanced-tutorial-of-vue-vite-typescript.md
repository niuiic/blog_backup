---
title: Advanced Tutorial of Vue-Vite-Typescript
date: 2021-06-06 16:04:22
tags:
  - Vue
  - Vite
  - Typescript
categories:
  - Vue
---

# Advanced Tutorial of Vue-Vite-Typescript

The following are the notes I took when I studied vue with reference to the official tutorial. The biggest difference between my notes and official tutorial is that I use typescript while the tutorial uses javascript. I suggest you learn vue following the official tutorial , but I firmly believe that you need to know some of the differences in the use of ts and js.

And please forgive my stiff English, I was just too lazy to switch input methods.

## Component

The default root component is `src/App.vue`. The custom components should be placed in `src/components`.

All components would be mounted in `src/main.ts`.

Next you will learn the process of defining and using custom components

### Define and use custom components

First, we will create a new file in `src/components`. The content should look like this.

```vue
<template>
  {{ msg }}
</template>

<script lang="ts">
import { defineComponent } from "vue";
export default defineComponent({
  name: "HelloWorld",
  data() {
    return {
      msg: "hello",
    };
  },
});
</script>

<style lang="less" scoped></style>
```

Now we have defined a component named `HelloWorld`.

Next, we need to import it in `src/main.ts`.

```typescript
import { createApp } from "vue";
import HelloWorld from "./components/HelloWorld.vue";
// import HelloWorld
// `HelloWorld` is not necessary to be the name of the component
```

Then, you can declare a mount point in `index.html`.

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <link rel="icon" href="/favicon.ico" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Vite App</title>
  </head>
  <body>
    <!-- the mount point is declared here -->
    <div id="test"></div>
    <script type="module" src="/src/main.ts"></script>
  </body>
</html>
```

Finally, you need to mount the component to the mount point. Continue to write in `src/main.ts`.

```typescript
createApp(HelloWorld).mount("#test");
```

The components can also be defined and used in a simple way. For example, the code may look like this.

```typescript
const app = Vue.createApp({})
app.component('button-counter', {
  data() {
    return {
      count: 0
    }
  },
  template: `
    <button @click="count++">
      You clicked me {{ count }} times.
    </button>`t
})
```

And you can simply reuse the components by add labels like this.

```html
<div id="components-demo">
  <button-counter></button-counter>
</div>
```

The `div` with id `components-demo` contains a pair of labels with a name which is the same as the component.

### Component registration

Components registered like this can be used globally. That means all components, including root component and child components can use these components.

```typescript
const app = Vue.createApp({});

app.component("component-a", {
  /* ... */
});
app.component("component-b", {
  /* ... */
});
app.component("component-c", {
  /* ... */
});

app.mount("#app");
```

```html
<div id="app">
  <component-a></component-a>
  <component-b></component-b>
  <component-c></component-c>
</div>
```

Components registered like this can only be used locally. That means only the root component can use these components.

```typescript
import ComponentA from "./ComponentA.vue";
import ComponentB from "./ComponentB.vue";
const app = Vue.createApp({
  components: {
    "component-a": ComponentA,
    "component-b": ComponentB,
  },
});
```

The code below is the same.

```typescript
import ComponentA from "./ComponentA.vue";
import ComponentB from "./ComponentB.vue";
const app = Vue.createApp({});
app.component("component-a", ComponentA);
app.component("component-b", ComponentB);
```

If you want to use ComponentA in ComponentB. You need to do like this.

```typescript
ComponentB.component("component-a", ComponentA);
```

### Interact with child components

#### Passing data to child components

In order to pass data to child components, we need to modify `src/components/HelloWorld.vue` like this.

```vue
<template>
  {{ msg }}
</template>

<script lang="ts">
import { defineComponent } from "vue";
export default defineComponent({
  name: "HelloWorld",
  props: ["msg"],
});
</script>

<style lang="less" scoped></style>
```

In the above code, we use `props` instead of `data`. Any value passed to a prop attribute will become a property on that component instance. And after a property is registered, we can pass data to it as a custom html attribute like this.

```html
<div id="test">
  <HelloWorld msg="hello world"></HelloWorld>
</div>
```

Now, you can launch the project and watch the result in a broswer. But soon, you will find there is nothing displaying on the broswer. The reason is that our component has an uppercase name. We difined an uppercase name in our project but something changed it to a lowercase name when it finally arrived at broswer. So use a lowercase name is enough to fix the error.

Now, our code looks like this.

```vue
<template>
  {{ msg }}
</template>

<script lang="ts">
import { defineComponent } from "vue";
export default defineComponent({
  name: "hello-world",
  props: ["msg"],
});
</script>

<style lang="less" scoped></style>
```

```html
<div id="test">
  <hello-world msg="hello world"></hello-world>
</div>
```

```typescript
import { createApp } from "vue";
import HelloWorld from "./components/HelloWorld.vue";

const app = createApp({});
app.component("hello-world", HelloWorld);
app.mount("#test");
```

Then we can try a more complicated demo.

```typescript
import { createApp } from "vue";
const App = {
  data() {
    return {
      posts: [
        { id: 1, title: "My journey with Vue" },
        { id: 2, title: "Blogging with Vue" },
        { id: 3, title: "Why Vue is so fun" },
      ],
    };
  },
};

const app = createApp(App);

app.component("blog-post", {
  props: ["title"],
  template: `<h4>{{ title }}</h4>`,
});

app.mount("#blog-posts-demo");
```

```html
<div id="blog-posts-demo">
  <blog-post
    v-for="post in posts"
    :key="post.id"
    :title="post.title"
  ></blog-post>
</div>
```

There is still something which you need to notice. For an instance, see the code below.

```vue
<!-- src/components/Demo.vue -->
<template>
  {{ msg }}
</template>

<script lang="ts">
import { defineComponent } from "vue";

export default defineComponent({
  name: "demo",
  props: ["msg"],
});
</script>
```

```typescript
/* src/main.ts */
import { createApp } from "vue";
import App from "./App.vue";
import EnlargeText from "./components/EnlargeText.vue";

const app = createApp(App);
app.component("enlarge-text", EnlargeText);
app.mount("#app");
```

```vue
<!-- src/App.vue -->
<template>
  <div>hello</div>
</template>

<script lang="ts">
import { defineComponent } from "vue";

export default defineComponent({
  name: "App",
});
</script>

<style lang="less"></style>
```

```
<!-- index.html -->
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <title>Vite App</title>
  </head>
  <body>
    <div id="app">
      <demo msg="world"></demo>
    </div>
    <script type="module" src="/src/main.ts"></script>
  </body>
</html>
```

In this example, we define templates in both main component and child component. And we try to display them in `index.html` together. But something would happen to the template of the child component. It is covered by the template of the main component. Take care of this problem. And if you really want to show them together, you can move `<demo msg="world"></demo>` from `index.html` to main component's template.

#### Listening to the events of child components

Let's ceate a new file named `Demo.vue` in `src/components`.

First, we modify `src/components/Demo.vue` like this.

```vue
<template>
  <div>
    <h4>
      {{ title }}
    </h4>
    <button @click="$emit('enlargeText')">Enlarge text</button>
  </div>
</template>

<script lang="ts">
import { defineComponent } from "vue";

export default defineComponent({
  name: "demo",
  props: ["title"],
  emits: ["enlargeText"],
});
</script>
```

In this file, we define an event of child component called `enlargeText` with `emits`. And we bind this to the button click event. Once the button is clicked, the super component will receive this event.

Then, we modify `src/App.vue` like this.

```vue
<template>
  <div>
    <demo
      :style="{ fontSize: postFontSize + 'em' }"
      @enlarge-text="postFontSize += 0.1"
      title="hello"
    ></demo>
  </div>
</template>

<script lang="ts">
import { defineComponent } from "vue";
import Demo from "./components/Demo.vue";

export default defineComponent({
  data() {
    return {
      postFontSize: 1,
    };
  },
  components: { Demo },
});
</script>
```

In this file, we define the mount point of the child component `Demo`. And we set its style with a variable `postFontSize`. Also, we define the response function for `enlarge-text` event. And finally, we import `Demo` from `Demo.vue` and register it as a clild component.

Be careful that `enlarge-text` is different from the event we defined in the child component called `enlargeText`. Although, `enlargeText` is also worked here, the broswer will interpret any uppercase characters as lowercase. So you'd better use `enlarge-text`.

Since we have imported the child component in `src/App.vue`, the `src/main.ts` becomes more simple.

```typescript
import { createApp } from "vue";
import App from "./App.vue";

const app = createApp(App);
app.mount("#app");
```

Now you can run your project and check the result in your broswer.

If you are careful enough, you would find that `emits` is similar to `props`. `props` passes data to super component and `emits` passes event to super component.

##### Emit a value with an event

To go futher, I will introduce you how to emit a value with an event.

The code would look like this.

```vue
<button @click="$emit('enlargeText', 0.1)">
  Enlarge text
</button>
```

Then you can get the value with `$event`.

```vue
<demo
  :style="{ fontSize: postFontSize + 'em' }"
  @enlarge-text="postFontSize += $event"
  title="hello"
></demo>
```

And if the event handler is a method, the value will be passed as the first parameter.

```vue
<demo
  :style="{ fontSize: postFontSize + 'em' }"
  @enlarge-text="onEnlargeText"
  title="hello"
></demo>
```

```vue
<script lang="ts">
import { defineComponent } from "vue";
import Demo from "./components/Demo.vue";

export default defineComponent({
  data() {
    return {
      postFontSize: 1,
    };
  },
  components: { Demo },
  methods: {
    onEnlargeText(enlargeText: any) {
      this.postFontSize += enlargeText;
    },
  },
});
</script>
```

##### Use v-model on components

`src/App.vue`

```vue
<template>
  <div>
    <demo v-model="searchText"></demo>
    <!-- it's the same as the code below -->
    <!-- <demo -->
    <!-- :model-value="searchText" -->
    <!-- @update:model-value="searchText = $event" -->
    <!-- ></demo> -->
  </div>
</template>

<script lang="ts">
import { defineComponent } from "vue";
import Demo from "./components/Demo.vue";

export default defineComponent({
  components: { Demo },
});
</script>
```

`src/components/Demo.vue`

```vue
<template>
  <div>
    <input
      :value="modelValue"
      @input="$emit('update:modelValue', $event.target.value)"
    />
  </div>
</template>

<script lang="ts">
import { defineComponent } from "vue";

export default defineComponent({
  name: "demo",
  props: ["modelValue"],
  emits: ["update:modelValue"],
});
</script>
```

With the code above, we have implemented a simple input function. We use `<demo v-model="searchText"></demo>` to simply our code in this example. The key point is you need to bind some properties in child components before using `v-model`.

There is another way to define child components.

```vue
<template>
  <div>
    <input v-model="value" />
  </div>
</template>

<script lang="ts">
import { defineComponent } from "vue";

export default defineComponent({
  name: "demo",
  props: ["modelValue"],
  emits: ["update:modelValue"],
  computed: {
    value: {
      get(): any {
        return this.modelValue;
      },
      set(value: any) {
        this.$emit("update:modelValue", value);
      },
    },
  },
});
</script>
```

### Content Distribution with slots

The name of the feature may be confusing, but the work is quite simple.

This feature means pass html content to a component. We have used this feature before.

```vue
app.component('alert-box', { template: `
<div class="demo-alert-box">
      <strong>Error!</strong>
      <slot></slot>
    </div>
` })
```

### Dynamic components

It's a feature to change components dynamicly when you swith to different tabs or other similar things, so that you can see different content.

The code is also simple. `<component :is="currentTabComponent"></component>` is all you need. What you need to do is changing `currentTabComponent` when needed.

### DOM template parsing caveats

Some HTML elements, such as `<ul>`, `<ol>`, `<table>` and `<select>` have restrictions on what elements can appear inside them, and some elements such as `<li>`, `<tr>`, and `<option>` can only appear inside certain other elements.

For example:

```html
<table>
  <demo></demo>
</table>
```

The custom component `<demo>` cannot be inside a pair of `<table>` label. To fix the error, you can use `v-is` with a allowed label instead.

```html
<table>
  <tr v-is="'demo'"></tr>
</table>
```

Also, HTML attribute names are case-insensitive, so browsers will interpret any uppercase characters as lowercase. That means when you’re using in-DOM templates, camelCased prop names and event handler parameters need to use their kebab-cased (hyphen-delimited) equivalents. This has been mentioned before.

It should be noted that these limitations do not apply if you are using string templates from one of the following sources:

- String templates (e.g. `template: '...'`)
- Single-file (`.vue`) components
- `<script type="text/x-template">`

## Summary

The most basic part of vue ends here, you are already be able to build some simple vue applications with this knowladge. To go futher, you can continue to learn more syntactic sugar following the [official tutorial](https://v3.vuejs.org/guide/installation.html). It won't be difficult for you.
