export async function searchJobs(query) {
  const res = await fetch(`http://smartcareerhub.runasp.net/api/Jobs/search?query=${query}`);
  return await res.json();
}
