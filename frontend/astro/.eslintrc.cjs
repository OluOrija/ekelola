module.exports = {
  root: true,
  extends: ["eslint:recommended", "plugin:astro/recommended", "prettier"],
  plugins: ["import"],
  overrides: [{ files: ["*.astro"], parser: "astro-eslint-parser" }],
};
