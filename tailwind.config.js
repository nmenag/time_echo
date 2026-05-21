// TimeEcho Tailwind CSS v4 & DaisyUI v5 Configuration
//
// In Tailwind CSS v4 and DaisyUI v5, configuration has transitioned to a CSS-first approach
// directly within "app/assets/stylesheets/application.tailwind.css" using the `@plugin` syntax.
// 
// This file remains in the project root to support tool integrations and editor plugins
// that require a tailwind.config.js presence to enable auto-completions.

module.exports = {
  content: [
    './app/views/**/*.html.erb',
    './app/helpers/**/*.rb',
    './app/assets/stylesheets/**/*.css',
    './app/javascript/**/*.js',
  ],
  theme: {
    extend: {},
  },
  plugins: [],
}
