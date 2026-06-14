export default async function createJob(formData) {
    const res = await fetch("http://smartcareerhub.runasp.net/api/Jobs", {
        method: "POST",
        body: formData
    });

    if (!res.ok) {
        const errorData = await res.json();
        throw new Error(errorData?.message || "Failed to create job");
    }

    return await res.json();
}
