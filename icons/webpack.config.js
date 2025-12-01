const SpriteLoaderPlugin = require("svg-sprite-loader/plugin");
const webpack = require("webpack");
const path = require("path");
const currentDir = path.resolve(__dirname);

// List of Feather icons to include in the sprite
// Available icons: https://feathericons.com
const includedIcons = [
  "activity",
  "alert-circle",
  "alert-octagon",
  "alert-triangle",
  "archive",
  "arrow-down",
  "arrow-left",
  "arrow-right",
  "arrow-up",
  "bar-chart-2",
  "book",
  "book-open",
  "calendar",
  "camera",
  "check",
  "check-circle",
  "chevron-down",
  "chevron-left",
  "chevron-right",
  "chevron-up",
  "chevrons-left",
  "chevrons-right",
  "clipboard",
  "clock",
  "columns",
  "copy",
  "corner-right-down",
  "corner-up-right",
  "download",
  "edit",
  "edit-2",
  "edit-3",
  "external-link",
  "eye",
  "eye-off",
  "file",
  "file-text",
  "filter",
  "folder",
  "git-pull-request",
  "globe",
  "grid",
  "hash",
  "heart",
  "help-circle",
  "home",
  "image",
  "info",
  "layers",
  "link",
  "list",
  "loader",
  "lock",
  "log-in",
  "log-out",
  "mail",
  "map",
  "map-pin",
  "maximize",
  "menu",
  "message-circle",
  "minimize",
  "minus",
  "more-horizontal",
  "more-vertical",
  "navigation",
  "pen-tool",
  "pie-chart",
  "play",
  "plus",
  "plus-circle",
  "refresh-cw",
  "save",
  "search",
  "settings",
  "share",
  "share-2",
  "sliders",
  "star",
  "sun",
  "moon",
  "tag",
  "tool",
  "trash",
  "trash-2",
  "trending-up",
  "unlock",
  "upload",
  "user",
  "user-check",
  "user-plus",
  "users",
  "x",
  "x-circle",
  "x-octagon",
  "zap"
];

module.exports = {
  mode: "production",
  entry: "./src/icons.js",
  output: {
    path: path.resolve(currentDir, "../vendor/assets/images"),
    filename: "_icons_entry.js"
  },
  module: {
    rules: [
      {
        test: /\.svg$/,
        use: [
          {
            loader: "svg-sprite-loader",
            options: {
              extract: true,
              spriteFilename: "icons.svg"
            }
          },
          {
            loader: "svgo-loader",
            options: {
              plugins: [
                {
                  name: "removeAttrs",
                  params: {
                    attrs: [
                      "*:fill:((?!^currentcolor).)*",
                      "stroke",
                      "stroke-width",
                      "stroke-linecap",
                      "stroke-linejoin"
                    ]
                  }
                }
              ]
            }
          }
        ]
      }
    ]
  },
  plugins: [
    new webpack.DefinePlugin({
      FEATHER_ICON_REGEXP: new RegExp(`.*\\/(${includedIcons.join("|")})\\.svg$`)
    }),
    new SpriteLoaderPlugin({
      plainSprite: true,
      spriteAttrs: {
        class: "iconset"
      }
    })
  ]
};
