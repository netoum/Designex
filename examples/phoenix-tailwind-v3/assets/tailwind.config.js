// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration

const plugin = require("tailwindcss/plugin")
const fs = require("fs")
const path = require("path")

module.exports = {
  content: [
    "./js/**/*.js",
    "../lib/demo_web.ex",
    "../lib/demo_web/**/*.*ex"
  ],
  theme: {
    extend: {
      colors: {
        ...require("./design/demo/build/tailwind/colors.js"),
        ...require("./design/demo/build/phoenix/colors.js")
      },
      animation: require("./design/demo/build/tailwind/animation.js"),
      backgroundPosition: require("./design/demo/build/tailwind/backgroundPosition.js"),
      backgroundSize: require("./design/demo/build/tailwind/backgroundSize.js"),
      blur: require("./design/demo/build/tailwind/blur.js"),
      borderRadius: require("./design/demo/build/tailwind/borderRadius.js"),
      borderWidth: require("./design/demo/build/tailwind/borderWidth.js"),
      fontFamily: require("./design/demo/build/tailwind/fontFamily.js"),
      fontSize: require("./design/demo/build/tailwind/fontSize.js"),
      fontWeight: require("./design/demo/build/tailwind/fontWeight.js"),
      letterSpacing: require("./design/demo/build/tailwind/letterSpacing.js"),
      lineHeight: require("./design/demo/build/tailwind/lineHeight.js"),
      screens: require("./design/demo/build/tailwind/screens.js"),
      spacing: require("./design/demo/build/tailwind/spacing.js")
    }
  },
  plugins: [
    require("@tailwindcss/forms"),
    // Allows prefixing tailwind classes with LiveView classes to add rules
    // only when LiveView classes are applied, for example:
    //
    //     <div class="phx-click-loading:animate-ping">
    //
    plugin(({ addVariant }) => addVariant("phx-click-loading", [".phx-click-loading&", ".phx-click-loading &"])),
    plugin(({ addVariant }) => addVariant("phx-submit-loading", [".phx-submit-loading&", ".phx-submit-loading &"])),
    plugin(({ addVariant }) => addVariant("phx-change-loading", [".phx-change-loading&", ".phx-change-loading &"])),

    // Embeds Heroicons (https://heroicons.com) into your app.css bundle
    // See your `CoreComponents.icon/1` for more information.
    //
    plugin(function ({ matchComponents, theme }) {
      let iconsDir = path.join(__dirname, "../deps/heroicons/optimized")
      let values = {}
      let icons = [
        ["", "/24/outline"],
        ["-solid", "/24/solid"],
        ["-mini", "/20/solid"],
        ["-micro", "/16/solid"]
      ]
      icons.forEach(([suffix, dir]) => {
        fs.readdirSync(path.join(iconsDir, dir)).forEach(file => {
          let name = path.basename(file, ".svg") + suffix
          values[name] = { name, fullPath: path.join(iconsDir, dir, file) }
        })
      })
      matchComponents({
        "hero": ({ name, fullPath }) => {
          let content = fs.readFileSync(fullPath).toString().replace(/\r?\n|\r/g, "")
          let size = theme("spacing.6")
          if (name.endsWith("-mini")) {
            size = theme("spacing.5")
          } else if (name.endsWith("-micro")) {
            size = theme("spacing.4")
          }
          return {
            [`--hero-${name}`]: `url('data:image/svg+xml;utf8,${content}')`,
            "-webkit-mask": `var(--hero-${name})`,
            "mask": `var(--hero-${name})`,
            "mask-repeat": "no-repeat",
            "background-color": "currentColor",
            "vertical-align": "middle",
            "display": "inline-block",
            "width": size,
            "height": size
          }
        }
      }, { values })
    })
  ]
}
