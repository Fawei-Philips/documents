using Microsoft.EntityFrameworkCore;
using System.Linq.Expressions;
using Utils.Ioc;

namespace Repository.Core
{
    [Register(Lifetime = Lifetime.Transient, ServiceType = typeof(IRepository<>))]
    public class RepositoryBase<T> : IRepository<T> where T : class
    {
        protected DbContext DbContext { get; init; }
        protected DbSet<T> DbSet { get; init; }

        public RepositoryBase(DbContext dbContext)
        {
            DbContext = dbContext;
            DbSet = dbContext.Set<T>();
        }

        public async Task<bool> ExistAsync(Expression<Func<T, bool>> predicate, CancellationToken ct = default)
        {
            return await DbSet.AnyAsync(predicate, ct);
        }

        public async Task<IEnumerable<T>> GetAllAsync(Expression<Func<T, bool>>? predicate = null, CancellationToken ct = default)
        {
            return predicate == null
                ? await DbSet.ToListAsync(ct)
                : await DbSet.Where(predicate).ToListAsync(ct);
        }

        public async Task<T?> GetAsync(Expression<Func<T, bool>> predicate, CancellationToken ct = default)
        {
            return await DbSet.FirstOrDefaultAsync(predicate, ct);
        }

        public async Task<T?> GetByIdAsync(int id, CancellationToken ct = default)
        {
            return await DbSet.FindAsync(id, ct);
        }

        public async Task AddAsync(T entity, CancellationToken ct = default)
        {
            await DbSet.AddAsync(entity, ct);
        }

        public async Task<T?> DeleteAsync(int id)
        {
            var entity = await GetByIdAsync(id);
            if (entity != null)
            {
                DbSet.Remove(entity);
            }

            return entity;
        }

        public async Task<T?> UpdateAsync(T entity)
        {
            DbSet.Update(entity);
            await Task.CompletedTask;
            return entity;
        }

        public async Task<int> SaveChangeAsync(CancellationToken ct = default)
        {
            return await DbContext.SaveChangesAsync(ct);
        }
    }
}
