export async function getByType(jobType) {
  const res = await fetch(`http://smartcareerhub.runasp.net/api/Jobs/type?jobType=${jobType}`);
  return await res.json();
}
