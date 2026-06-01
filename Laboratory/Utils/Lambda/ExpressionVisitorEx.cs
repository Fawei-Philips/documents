using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Expressions;
using System.Text;
using System.Threading.Tasks;

namespace Utils.Lambda
{
    public class ExpressionVisitorEx : ExpressionVisitor
    {
        public ParameterExpression Parameter { get; init; }
        public ExpressionVisitorEx(ParameterExpression parameter)
        {
            Parameter = parameter ?? 
                throw new ArgumentNullException(nameof(parameter), "Parameter cannot be null.");
        }

        public Expression Replace(Expression expression)
        {
            if (expression == null)
            {
                throw new ArgumentNullException(nameof(expression), "Expression cannot be null.");
            }
            return Visit(expression);
        }

        protected override Expression VisitParameter(ParameterExpression node)
        {
            if (node == null)
            {
                throw new ArgumentNullException(nameof(node), "Parameter node cannot be null.");
            }
            return Parameter;
        }
    }
}
