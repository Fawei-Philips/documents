namespace NetLaboratory.Knowledge.decorator
{
    internal class StudentDecorator : IStudent
    {
        private readonly IStudent _student;
        public int Id { get; init; }
        public string Name { get; init; }
        public StudentDecorator(IStudent student)
        {
            _student = student;
            Id = student.Id;
            Name = student.Name;
        }
        public void Study()
        {
            _student.Study();
            Console.WriteLine($"Decorator: {Name} is studying with additional features.");
        }
    }
}
