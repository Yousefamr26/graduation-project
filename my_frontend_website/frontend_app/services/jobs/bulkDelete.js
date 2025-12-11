export async function bulkDelete(ids) {
  const res = await fetch(`http://smartcareerhub.runasp.net/api/Jobs/bulk-delete?ids=${ids}`);
  return await res.json();
}
