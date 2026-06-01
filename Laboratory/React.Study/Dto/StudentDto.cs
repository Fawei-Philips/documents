using System.ComponentModel.DataAnnotations;

namespace React.Study.Dto
{
    public class CreateStudentDto
    {
        public required StudentAttributes Attributes { get; set; }
    }

    public class StudentDto
    {
        public int Id { get; set; }
        public required StudentAttributes Attributes { get; set; }
    }

    public class StudentAttributes
    {
        [Required(ErrorMessage = "姓名不能为空")]
        public required string Name { get; set; }
        public required string Gender { get; set; }
        [Required(ErrorMessage = "年龄不能为空")]
        [Range(1, 120, ErrorMessage = "年龄必须在1-120之间")]
        public required int Age { get; set; }
        public string? Address { get; set; }
    }
}
