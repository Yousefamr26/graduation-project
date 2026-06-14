const API_URL = "http://smartcareerhub.runasp.net/api/Jobs";

export async function getAllJobs() {
    try {
        const res = await fetch(API_URL, {
            method: "GET"
        });
        if (!res.ok) {
            throw new Error(`Failed to fetch jobs: ${res.status}`);
        }
        const data = await res.json();
        return data; // Array of jobs
    } catch (error) {
        console.error("GET all jobs error:", error);
        return [];
    }
}
