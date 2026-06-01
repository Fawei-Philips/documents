namespace Db.React.Study.Entities
{
    public class Student
    {
        public int Id { get; set; }
        public required string Name { get; set; }
        public required string Gender { get; set; }
        public required int Age { get; set; }
        public string? Address { get; set; }
    }
}
