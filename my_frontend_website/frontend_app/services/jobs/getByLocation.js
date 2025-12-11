export async function getByLocation(city) {
  const res = await fetch(`http://smartcareerhub.runasp.net/api/Jobs/location?city=${city}`);
  return await res.json();
}


