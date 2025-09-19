import { defineCollection, z } from "astro:content";

const posts = defineCollection({
  type: "content",
  schema: z.object({
    title: z.string(),
    description: z.string(),
    date: z.coerce.date(),
    updated: z.coerce.date().optional(),
    draft: z.boolean().default(false),
    tags: z.array(z.string()).default([]),
    category: z.string().optional(),
    coverImage: z.object({
      src: z.string(),
      width: z.number().optional(),
      height: z.number().optional(),
      format: z.string().optional(),
      alt: z.string().optional(),
    }).optional(),
    canonical: z.string().url().optional(),
    author: z.string().default("Ekelola"),
    slug: z.string().optional(),
  }),
});

const pages = defineCollection({
  type: "content",
  schema: z.object({
    title: z.string(),
    description: z.string().optional(),
    draft: z.boolean().default(false),
    order: z.number().optional(),
  }),
});

export const collections = { posts, pages };