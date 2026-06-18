
public record PagedResponse<T>(
    IEnumerable<T> Data,
    int TotalCount,
    int Page,
    int PageSize,
    int TotalPages
)
{
    public static PagedResponse<T> Create(
        IEnumerable<T> source,
        int page,
        int pageSize)
    {
        var list = source.ToList();
        var totalCount = list.Count;
        var data = list
            .Skip((page - 1) * pageSize)
            .Take(pageSize);

        return new PagedResponse<T>(
            Data: data,
            TotalCount: totalCount,
            Page: page,
            PageSize: pageSize,
            TotalPages: (int)Math.Ceiling(totalCount / (double)pageSize)
        );
    }
}