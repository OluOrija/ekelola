import rss from "@astrojs/rss";
import { getCollection } from "astro:content";

export async function GET(context) {
  const posts = (await getCollection("posts")).filter((p) => !p.data.draft);
  return rss({
    title: "ekelola",
    description: "AI • Tech • Mind",
    site: context.site,
    items: posts.map((p) => ({
      title: p.data.title,
      pubDate: new Date(p.data.date),
      description: p.data.description,
      link: `/blog/${p.slug}`,
    })),
  });
}
