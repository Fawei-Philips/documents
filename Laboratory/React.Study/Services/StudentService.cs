using Db.React.Study.Entities;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using React.Study.Dto;
using React.Study.Repositories;
using System.Linq.Expressions;
using Utils.Ioc;

namespace React.Study.Services
{
    [Register(Lifetime = Lifetime.Transient, ServiceType = typeof(IStudentService))]
    public class StudentService : IStudentService
    {
        private readonly IStudentRepository _studentRepository;
        private readonly IHttpContextAccessor _httpContextAccessor;

        public StudentService(IStudentRepository studentRepository, IHttpContextAccessor httpContext)
        {
            _studentRepository = studentRepository;
            _httpContextAccessor = httpContext;
        }

        public async Task<IEnumerable<StudentDto>?> GetAllStudentsAsync()
        {
            var students = await _studentRepository.GetAllAsync();

            return students?.Select(s => new StudentDto
            {
                Id = s.Id,
                Attributes = new StudentAttributes
                {
                    Name = s.Name,
                    Gender = s.Gender,
                    Age = s.Age,
                    Address = s.Address
                }
            });
        }

        public async Task<StudentDto?> GetStudentByIdAsync(int id)
        {
            var student = await _studentRepository.GetByIdAsync(id);
            if (student == null)
                return null;

            _httpContextAccessor.HttpContext.Items.TryAdd("student", student);

            return new StudentDto
            {
                Id = student.Id,
                Attributes = new StudentAttributes
                {
                    Name = student.Name,
                    Gender = student.Gender,
                    Age = student.Age,
                    Address = student.Address
                }
            };
        }

        public async Task<StudentDto?> GetStudentByPropertiesAsync(string name, int age, string gender, string? address)
        {
            var student = await _studentRepository.GetStudentByPropertiesAsync(name, age, gender, address);

            if (student == null)
                return null;

            return new StudentDto
            {
                Id = student.Id,
                Attributes = new StudentAttributes
                {
                    Name = student.Name,
                    Gender = student.Gender,
                    Age = student.Age,
                    Address = student.Address
                }
            };
        }

        public async Task<StudentDto?> CreateStudentAsync(CreateStudentDto studentDto)
        {
            var existStudent = await _studentRepository.GetStudentByPropertiesAsync(studentDto.Attributes.Name,
                studentDto.Attributes.Age,
                studentDto.Attributes.Gender,
                studentDto.Attributes.Address);

            if (existStudent != null)
            {
                throw new Exception($"Student already exists.");
            }

            var student = new Student
            {
                Name = studentDto.Attributes.Name,
                Gender = studentDto.Attributes.Gender,
                Age = studentDto.Attributes.Age,
                Address = studentDto.Attributes.Address
            };

            await _studentRepository.AddAsync(student);
            await _studentRepository.SaveChangeAsync();

            return new StudentDto
            {
                Id = student.Id,
                Attributes = new StudentAttributes
                {
                    Name = student.Name,
                    Gender = student.Gender,
                    Age = student.Age,
                    Address = student.Address
                }
            };
        }

        public async Task<StudentDto?> UpdateStudentAsync(int id, StudentDto studentDto)
        {
            var existingStudent = _httpContextAccessor.HttpContext.Items["student"] as Student;
            if (existingStudent == null)
            {
                throw new Exception($"Student with id={studentDto.Id} doesn't exist anymore.");
            }

            existingStudent.Name = studentDto.Attributes.Name;
            existingStudent.Gender = studentDto.Attributes.Gender;
            existingStudent.Age = studentDto.Attributes.Age;
            existingStudent.Address = studentDto.Attributes.Address;

            await _studentRepository.UpdateAsync(existingStudent);
            await _studentRepository.SaveChangeAsync();
            return studentDto;
        }

        public async Task<StudentDto?> DeleteStudentAsync(int id)
        {
            var student = _httpContextAccessor.HttpContext.Items["studentDto"] as StudentDto;
            if (student == null)
                return null;

            await _studentRepository.DeleteAsync(id);
            await _studentRepository.SaveChangeAsync();
            return new StudentDto
            {
                Id = student.Id,
                Attributes = new StudentAttributes
                {
                    Name = student.Attributes.Name,
                    Gender = student.Attributes.Gender,
                    Age = student.Attributes.Age,
                    Address = student.Attributes.Address
                }
            };
        }

        public async Task<bool> StudentExistsAsync(int id)
        {
            Expression<Func<Student, bool>> idExistsPredicate = stu => stu.Id == id;
            return await _studentRepository.ExistAsync(idExistsPredicate);
        }
    }
}
