using Db.React.Study.Entities;
using Repository.Core;

namespace React.Study.Repositories
{
    public interface IStudentRepository : IRepository<Student>
    {
        Task<Student?> GetStudentByPropertiesAsync(string name, int age, string gender, string? address);
    }
}
