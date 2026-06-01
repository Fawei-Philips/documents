namespace NetLaboratory.Knowledge.decorator
{
    internal interface IStudent
    {
        int Id { get; init; }
        string Name { get; init; }
        void Study();
    }
}
