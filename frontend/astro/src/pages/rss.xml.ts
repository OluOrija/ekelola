import rss from "@astrojs/rss";
import { getAllPosts } from "../lib/content";

import type { APIRoute } from "astro";

export const GET: APIRoute = async (context) => {
  const posts = (await getAllPosts()).slice(0, 30);
  return rss({
    title: "ekelola",
    description: "AI • Tech • Mind",
    site: String(context.site),
    items: posts.map((p) => ({
      title: p.data.title,
      pubDate: new Date(p.data.date),
      description: p.data.description,
      link: `/blog/${p.slug}`,
    })),
  });
};
