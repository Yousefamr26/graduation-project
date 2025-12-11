export async function getLatestJobs() {
  const res = await fetch(`http://smartcareerhub.runasp.net/api/Jobs/latest`);
  return await res.json();
}
