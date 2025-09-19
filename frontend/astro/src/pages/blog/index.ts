import type { APIRoute } from 'astro';

export const GET: APIRoute = ({ redirect }) => {
  return redirect('/blog/page/1', 307);
};
