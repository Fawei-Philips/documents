using System.Linq.Expressions;

namespace Repository.Core
{
    public interface IRepository<T> where T : class
    {
        Task<bool> ExistAsync(Expression<Func<T, bool>> predicate, CancellationToken ct = default);
        Task<T?> GetAsync(Expression<Func<T, bool>> predicate, CancellationToken ct = default);
        Task<T?> GetByIdAsync(int id, CancellationToken ct = default);
        Task<IEnumerable<T>> GetAllAsync(Expression<Func<T, bool>>? predicate = null, CancellationToken ct = default);
        Task AddAsync(T entity, CancellationToken ct = default);
        Task<T?> DeleteAsync(int id);
        Task<T?> UpdateAsync(T entity);
        Task<int> SaveChangeAsync(CancellationToken ct = default);

    }
}
