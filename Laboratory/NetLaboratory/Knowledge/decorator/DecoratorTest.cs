namespace NetLaboratory.Knowledge.decorator
{
    internal class DecoratorTest
    {
        public DecoratorTest() { }

        /*
         * 测试装饰器模式
         * 1. 只用继承弊端: 无法动态添加功能
         * 2. 只用组合弊端: 需要引入多余代码
         * 3. 使用 组合 + 继承 = 装饰器模式
         */
        public void Run()
        {
            IStudent studentVip = new StudentVip(1, "Alice");
            studentVip = new StudentDecorator(studentVip);
            studentVip.Study();
        }
    }
}
