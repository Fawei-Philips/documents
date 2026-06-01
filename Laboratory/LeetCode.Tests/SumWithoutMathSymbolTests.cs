namespace LeetCode.Tests
{
    public class SumWithoutMathSymbolTests
    {
        [Theory]
        [InlineData(5, 10, 10, 5)]
        [InlineData(-5, 10, 10, -5)]
        public void Exchange_Numbers_Test1(int a, int b, int resA, int resB)
        {
            // Arrange
            var sumWithoutMathSymbol = new LeetCode.numbers.SumWithoutMathSymbol();
            // Act
            var result = sumWithoutMathSymbol.Exchange(a, b);
            // Assert
            Assert.Equal((resA, resB), result);
        }
    }
}