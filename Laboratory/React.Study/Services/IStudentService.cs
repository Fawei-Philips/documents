using Db.React.Study.Entities;
using React.Study.Dto;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace React.Study.Services
{
    public interface IStudentService
    {
        Task<IEnumerable<StudentDto>?> GetAllStudentsAsync();
        Task<StudentDto?> GetStudentByIdAsync(int id);
        Task<StudentDto?> GetStudentByPropertiesAsync(string name, int age, string gender, string? address);
        Task<StudentDto?> CreateStudentAsync(CreateStudentDto studentDto);
        Task<StudentDto?> UpdateStudentAsync(int id, StudentDto studentDto);
        Task<StudentDto?> DeleteStudentAsync(int id);
        Task<bool> StudentExistsAsync(int id);
    }
}
