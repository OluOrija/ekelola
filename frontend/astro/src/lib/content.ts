import { getCollection, type CollectionEntry } from "astro:content";

const isProd = import.meta.env.DEV === false && (process.env.DEPLOY_TARGET === "prod" || process.env.DEPLOY_TARGET === "gh-pages");

export async function getAllPosts({ includeDraft = false } = {}) {
  const posts = await getCollection("posts");
  return posts
    .filter((p) => includeDraft || !p.data.draft)
    .sort((a, b) => +new Date(b.data.date) - +new Date(a.data.date));
}

export async function getPaginatedPosts(page: number, pageSize: number) {
  const all = await getAllPosts();
  const totalPages = Math.ceil(all.length / pageSize);
  const posts = all.slice((page - 1) * pageSize, page * pageSize);
  return { posts, totalPages };
}


// Helper to slugify tags: lowercase, replace spaces/underscores with dashes, remove non-alphanum
export function slugifyTag(tag: string) {
  return tag
    .toLowerCase()
    .replace(/\s+/g, '-')
    .replace(/_+/g, '-')
    .replace(/[^a-z0-9-]/g, '');
}

export async function getAllTags() {
  const posts = await getAllPosts();
  const tagMap: Record<string, { count: number; original: string }> = {};
  posts.forEach((p) => {
    p.data.tags.forEach((tag) => {
      const slug = slugifyTag(tag);
      if (!tagMap[slug]) tagMap[slug] = { count: 0, original: tag };
      tagMap[slug].count++;
    });
  });
  return tagMap;
}

export async function getPostsByTag(tagSlug: string, page: number, pageSize: number) {
  const all = (await getAllPosts()).filter((p) =>
    p.data.tags.some((tag) => slugifyTag(tag) === tagSlug)
  );
  const totalPages = Math.ceil(all.length / pageSize);
  const posts = all.slice((page - 1) * pageSize, page * pageSize);
  return { posts, totalPages };
}

export function normalizeSlug(entry: CollectionEntry<"posts">) {
  return entry.data.slug ?? (entry as any).slug;
}
