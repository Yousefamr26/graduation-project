export async function getByExperience(level) {
  const res = await fetch(`http://smartcareerhub.runasp.net/api/Jobs/search?experienceLevel=${level}`);
  return await res.json();
}

