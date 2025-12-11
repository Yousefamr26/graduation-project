export async function deleteJob(id) {
    try {
        const res = await fetch(`${API_URL}/${id}`, {
            method: "DELETE"
        });
        if (!res.ok) {
            throw new Error(`Failed to delete job ${id}: ${res.status}`);
        }
        return true; // Successfully deleted
    } catch (error) {
        console.error("DELETE job error:", error);
        return false;
    }
}
