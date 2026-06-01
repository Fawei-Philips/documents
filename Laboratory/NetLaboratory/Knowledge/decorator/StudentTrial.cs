namespace NetLaboratory.Knowledge.decorator
{
    internal class StudentTrial : IStudent
    {
        public int Id { get; init; }
        public string Name { get; init; }
        public StudentTrial(int id, string name)
        {
            Id = id;
            Name = name;
        }
        public void Study()
        {
            Console.WriteLine($"StudentTrial {Name} is studying.");
        }
    }
}
