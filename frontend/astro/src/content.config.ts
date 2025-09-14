import { defineCollection, z } from "astro:content";

const posts = defineCollection({
  type: "content",
  schema: z.object({
    title: z.string(),
    description: z.string().max(200),
    date: z.string().transform((s) => new Date(s)), // ISO string
    updated: z.string().optional().transform((s) => (s ? new Date(s) : undefined)),
    tags: z.array(z.string()).default([]),
    draft: z.boolean().default(false),
    coverImage: z.string().optional(),
    canonicalUrl: z.string().url().optional(),
  }),
});

export const collections = { posts };
