export async function getJobsCount() {
  const res = await fetch(`http://smartcareerhub.runasp.net/api/Jobs/count`);
  return await res.json();
}
