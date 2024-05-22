<div align="center">

<img src="https://raw.githubusercontent.com/misolori/vscode-symbols/main/symbols.png" width="140" />

# Symbols

A file icon for VS Code

![Preview of extension](https://github.com/misolori/vscode-symbols/raw/main/preview.png)

</div>

## Contributing

If you'd like to contribute to this extension, please take a look at the issues or create a new one. If you'd like to create a new icon, please reference the [Symbols - File Icon Figma file](https://www.figma.com/file/HYLMyRbIdSbIJQlqnd9pSN/Symbols---File-Icons?node-id=20521%3A84115&t=PyBzZOlVG5TXyEdx-1), you can make a copy or reference the styles used (tailwind). Please try to limit your colors to the ones used in existing icons before choosing a different color style.

When submitting a PR, please ensure you've tested the extension locally and ensure that your new icons appear correctly in the file tree view with your new file extension. Include a screenshot of your proposed icon in your PR.

## Configuration

You can configure which folders and files icons are displayed by using the following settings:

### Folders

```json
"symbols.folders.associations": {
    "{folder name}": "{icon name}"
}
```

And here is an example using this setting:

```json
"symbols.folders.associations": {
    "entities": "folder-assets",
    "infra": "folder-app",
    "schemas": "folder-purple"
}
```

### Files

```json
"symbols.files.associations": {
    "{file name}": "{icon name}"
}
```

And here is an example:

```json
"symbols.files.associations": {
    "app.module.ts": "nest",
    "*.service.ts": "nest"
}
```

_Note: For file names, you can use `*` to match all files with a specific file extension._

### Icon Previews

You can choose which icons to use from the [Library](https://www.figma.com/file/HYLMyRbIdSbIJQlqnd9pSN/Symbols---File-Icons?node-id=20521%3A84115&t=PyBzZOlVG5TXyEdx-1):

|Name|Preview|
|--|--|
|folder|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/folders/folder.png)|
|folder-app|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/folders/folder-app.png)|
|folder-android|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/folders/folder-android.png)|
|folder-assets|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/folders/folder-assets.png)|
|folder-prisma|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/folders/folder-prisma.png)|
|folder-mail|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/folders/folder-mail.png)|
|folder-blue|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/folders/folder-blue.png)|
|folder-blue-code|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/folders/folder-blue-code.png)|
|folder-blue-outline|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/folders/folder-blue-outline.png)|
|folder-config|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/folders/folder-config.png)|
|folder-gray|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/folders/folder-gray.png)|
|folder-gray-code|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/folders/folder-gray-code.png)|
|folder-gray-outline|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/folders/folder-gray-outline.png)|
|folder-green|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/folders/folder-green.png)|
|folder-green-code|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/folders/folder-green-code.png)|
|folder-green-outline|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/folders/folder-green-outline.png)|
|folder-orange|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/folders/folder-orange.png)|
|folder-orange-code|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/folders/folder-orange-code.png)|
|folder-orange-outline|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/folders/folder-orange-outline.png)|
|folder-purple|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/folders/folder-purple.png)|
|folder-purple-code|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/folders/folder-purple-code.png)|
|folder-purple-outline|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/folders/folder-purple-outline.png)|
|folder-red|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/folders/folder-red.png)|
|folder-red-code|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/folders/folder-red-code.png)|
|folder-red-outline|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/folders/folder-red-outline.png)|
|folder-sky|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/folders/folder-sky.png)|
|folder-sky-code|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/folders/folder-sky-code.png)|
|folder-sky-outline|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/folders/folder-sky-outline.png)|
|folder-yellow|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/folders/folder-yellow.png)|
|folder-yellow-code|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/folders/folder-yellow-code.png)|
|folder-yellow-outline|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/folders/folder-yellow-outline.png)|

|Name|Preview|
|--|--|
|angular|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/angular.png)|
|astro|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/astro.png)|
|audio|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/audio.png)|
|babel|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/babel.png)|
|biome|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/biome.png)|
|brackets-blue|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/brackets-blue.png)|
|brackets-gray|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/brackets-gray.png)|
|brackets-green|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/brackets-green.png)|
|brackets-orange|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/brackets-orange.png)|
|brackets-purple|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/brackets-purple.png)|
|brackets-red|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/brackets-red.png)|
|brackets-sky|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/brackets-sky.png)|
|brackets-yellow|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/brackets-yellow.png)|
|c|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/c.png)|
|capacitor|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/capacitor.png)|
|clojure|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/clojure.png)|
|code-blue|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/code-blue.png)|
|code-gray|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/code-gray.png)|
|code-green|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/code-green.png)|
|code-orange|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/code-orange.png)|
|code-purple|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/code-purple.png)|
|code-red|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/code-red.png)|
|code-sky|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/code-sky.png)|
|code-yellow|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/code-yellow.png)|
|coffeescript|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/coffeescript.png)|
|coldfusion|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/coldfusion.png)|
|cplus|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/cplus.png)|
|crystal|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/crystal.png)|
|csharp|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/csharp.png)|
|csv|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/csv.png)|
|cypress|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/cypress.png)|
|dart|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/dart.png)|
|database|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/database.png)|
|deno|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/deno.png)|
|docker|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/docker.png)|
|document|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/document.png)|
|drawio|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/drawio.png)|
|dts|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/dts.png)|
|editorconfig|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/editorconfig.png)|
|elixir|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/elixir.png)|
|erlang|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/erlang.png)|
|eslint|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/eslint.png)|
|exe|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/exe.png)|
|firebase|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/firebase.png)|
|font|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/font.png)|
|fsharp|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/fsharp.png)|
|gear|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/gear.png)|
|git|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/git.png)|
|github|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/github.png)|
|go-mod|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/go-mod.png)|
|go|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/go.png)|
|gradle|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/gradle.png)|
|graphql|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/graphql.png)|
|gulp|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/gulp.png)|
|h|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/h.png)|
|haml|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/haml.png)|
|http|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/http.png)|
|hugo|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/hugo.png)|
|ignore|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/ignore.png)|
|image|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/image.png)|
|ionic|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/ionic.png)|
|java|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/java.png)|
|jenkins|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/jenkins.png)|
|jest|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/jest.png)|
|js-test|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/js-test.png)|
|js|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/js.png)|
|julia-markdown|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/julia-markdown.png)|
|julia|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/julia.png)|
|kotlin|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/kotlin.png)|
|laravel|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/laravel.png)|
|license|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/license.png)|
|liquid|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/liquid.png)|
|lua|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/lua.png)|
|markdown|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/markdown.png)|
|mdx|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/mdx.png)|
|nest|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/nest.png)|
|netlify|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/netlify.png)|
|next|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/next.png)|
|nix|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/nix.png)|
|node|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/node.png)|
|nodemon|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/nodemon.png)|
|notebook|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/notebook.png)|
|npm|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/npm.png)|
|nunjucks|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/nunjucks.png)|
|patch|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/patch.png)|
|perl|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/perl.png)|
|php|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/php.png)|
|pnpm|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/pnpm.png)|
|postcss|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/postcss.png)|
|prettier|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/prettier.png)|
|prisma|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/prisma.png)|
|proto|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/proto.png)|
|pug|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/pug.png)|
|pulumi|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/pulumi.png)|
|puzzle|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/puzzle.png)|
|python|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/python.png)|
|r|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/r.png)|
|react-test|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/react-test.png)|
|react-ts|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/react-ts.png)|
|react|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/react.png)|
|rescript-interface|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/rescript-interface.png)|
|rescript|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/rescript.png)|
|robot|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/robot.png)|
|ruby|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/ruby.png)|
|rust|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/rust.png)|
|sass|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/sass.png)|
|sbt|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/sbt.png)|
|scala|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/scala.png)|
|shell|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/shell.png)|
|storybook|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/storybook.png)|
|stylus|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/stylus.png)|
|supabase|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/supabase.png)|
|svelte|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/svelte.png)|
|svg|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/svg.png)|
|swc|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/swc.png)|
|swift|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/swift.png)|
|tailwind|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/tailwind.png)|
|terraform|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/terraform.png)|
|tex|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/tex.png)|
|text|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/text.png)|
|ts-test|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/ts-test.png)|
|ts|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/ts.png)|
|tsconfig|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/tsconfig.png)|
|turborepo|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/turborepo.png)|
|twig|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/twig.png)|
|v|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/v.png)|
|vanilla-extract|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/vanilla-extract.png)|
|vercel|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/vercel.png)|
|video|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/video.png)|
|visual-studio|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/visual-studio.png)|
|vite|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/vite.png)|
|vitest|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/vitest.png)|
|vue|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/vue.png)|
|webpack|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/webpack.png)|
|xml|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/xml.png)|
|yaml|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/yaml.png)|
|yarn|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/yarn.png)|
|zig|![img](https://github.com/misolori/vscode-symbols/raw/HEAD/preview/files/zig.png)|
