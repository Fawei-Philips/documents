namespace NetLaboratory.Knowledge.decorator
{
    internal class StudentVip : IStudent
    {
        public int Id { get; init; }
        public string Name { get; init; }
        public StudentVip(int id, string name)
        {
            Id = id;
            Name = name;
        }
        public void Study()
        {
            Console.WriteLine($"StudentVip {Name} is studying.");
        }
    }
}
