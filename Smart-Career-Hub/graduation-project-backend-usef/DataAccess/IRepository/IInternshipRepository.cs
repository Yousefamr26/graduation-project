using DataAccess.Entities.Job;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;

public interface IInternshipRepository
{
    Task<Internship> GetByIdAsync(int id, CancellationToken cancellationToken = default);

    Task<IEnumerable<Internship>> GetAllAsync(CancellationToken cancellationToken = default);
    Task AddAsync(Internship internship, CancellationToken cancellationToken = default);
    void Update(Internship internship);
    void Delete(Internship internship);

    Task<bool> ExistsAsync(int id, CancellationToken cancellationToken = default);

}
