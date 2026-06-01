using Microsoft.EntityFrameworkCore;
using System.Linq.Expressions;

namespace NetUtils.Repository
{
    public class RepositoryBase<TEntity, TId> : IRepository<TEntity, TId> where TEntity : class
    {
        protected DbContext DbContext { get; init; }
        protected DbSet<TEntity> DbSet { get; init; }

        public RepositoryBase(DbContext dbContext)
        {
            DbContext = dbContext;
            DbSet = DbContext.Set<TEntity>();
        }

        public async Task<bool> ExistAsync(Expression<Func<TEntity, bool>> predicate, CancellationToken ct = default)
        {
            return await DbSet.AnyAsync(predicate, ct);
        }

        public async Task<IEnumerable<TEntity>> GetAllAsync(Expression<Func<TEntity, bool>>? predicate = null, CancellationToken ct = default)
        {
            return predicate == null
                ? await DbSet.AsNoTracking().ToListAsync(ct)
                : await DbSet.AsNoTracking().Where(predicate).ToListAsync(ct);
        }

        public async Task<TEntity?> GetAsync(Expression<Func<TEntity, bool>> predicate, bool asNoTracking = true, CancellationToken ct = default)
        {
            var query = asNoTracking ? DbSet.AsNoTracking() : DbSet;
            return await query.FirstOrDefaultAsync(predicate, ct);
        }

        public async ValueTask<TEntity?> GetByIdAsync(TId id, CancellationToken ct = default)
        {
            return await DbSet.FindAsync(id, ct);
        }

        public async ValueTask<TEntity> AddAsync(TEntity entity, CancellationToken ct = default)
        {
            var addedEntry = await DbSet.AddAsync(entity, ct);
            return addedEntry.Entity;
        }

        public async ValueTask<TEntity?> DeleteAsync(TId id, CancellationToken ct = default)
        {
            var entity = await GetByIdAsync(id, ct);
            if (entity != null)
            {
                DbSet.Remove(entity);
            }

            return entity;
        }

        public async ValueTask UpdateAsync(TEntity entity)
        {
            DbSet.Update(entity);
            await ValueTask.CompletedTask;
        }

        public async Task<int> SaveChangeAsync(CancellationToken ct = default)
        {
            return await DbContext.SaveChangesAsync(ct);
        }
    }
}
