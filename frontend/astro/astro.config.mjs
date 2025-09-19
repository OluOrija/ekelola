import { defineConfig } from "astro/config";
import mdx from "@astrojs/mdx";
import tailwind from "@astrojs/tailwind";
import sitemap from "@astrojs/sitemap";

const deploy = process.env.DEPLOY_TARGET ?? "local";
const site =
  process.env.SITE_URL ??
  (deploy === "gh-pages"
    ? "https://oluorija.github.io/ekelola"
    : deploy === "prod"
    ? "https://www.ekelola.com"
    : "http://localhost:4321");
const base = deploy === "gh-pages" ? "/ekelola/" : "/";

export default defineConfig({
  site,
  base,
  integrations: [mdx(), sitemap(), tailwind()],
  trailingSlash: "never",
});
