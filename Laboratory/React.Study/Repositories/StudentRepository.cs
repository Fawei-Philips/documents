using Db.React.Study.Configurations.Data;
using Db.React.Study.Entities;
using Microsoft.EntityFrameworkCore;
using Repository.Core;
using Utils.Ioc;

namespace React.Study.Repositories
{
    [Register(Lifetime = Lifetime.Transient, ServiceType = typeof(IStudentRepository))]
    public class StudentRepository : RepositoryBase<Student>, IStudentRepository
    {
        private readonly AppDbContext _dbContext;

        public StudentRepository(AppDbContext dbContext) : base(dbContext)
        {
            _dbContext = dbContext;
        }

        public async Task<Student?> GetStudentByPropertiesAsync(string name, int age, string gender, string? address)
        {
            return await _dbContext.Students.FirstOrDefaultAsync(x =>
            !string.IsNullOrWhiteSpace(name) &&
            !string.IsNullOrWhiteSpace(x.Name) &&
            x.Name.ToLower() == name.ToLower() &&
            x.Age == age &&
            x.Gender == gender &&
            !string.IsNullOrWhiteSpace(address) &&
            !string.IsNullOrWhiteSpace(x.Address) &&
            x.Address.ToLower() == address.ToLower());
        }
    }
}
