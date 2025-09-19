import type { APIRoute } from 'astro';

export const GET: APIRoute = ({ redirect }) => {
  return redirect('/page/1', 307);
};
