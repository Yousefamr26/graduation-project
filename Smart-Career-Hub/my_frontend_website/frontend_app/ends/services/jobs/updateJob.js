export async function updateJob(id, jobData) {
    try {
        const res = await fetch(`${API_URL}/${id}`, {
            method: "PUT",
            headers: {
                "Content-Type": "application/json"
            },
            body: JSON.stringify(jobData)
        });
        if (!res.ok) {
            const errorData = await res.json();
            throw new Error(errorData?.message || "Failed to update job");
        }
        return await res.json();
    } catch (error) {
        console.error("UPDATE job error:", error);
        return null;
    }
}
