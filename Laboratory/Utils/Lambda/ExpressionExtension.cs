using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Expressions;
using System.Text;
using System.Threading.Tasks;

namespace Utils.Lambda
{
    public static class ExpressionExtension
    {
        public static Expression<Func<T, bool>> And<T>(this Expression<Func<T, bool>> expr1, Expression<Func<T, bool>> expr2)
        {
            if (expr1 == null)
            {
                return expr2;
            }

            if (expr2 == null)
            {
                return expr1;
            }

            var parameter = Expression.Parameter(typeof(T), "x");
            var visitor = new ExpressionVisitorEx(parameter);
            var left = visitor.Replace(expr1.Body);
            var right = visitor.Replace(expr2.Body);

            var body = Expression.And(left, right);

            return Expression.Lambda<Func<T, bool>>(body, parameter);
        }

        public static Expression<Func<T, bool>> Or<T>(this Expression<Func<T, bool>> expr1, Expression<Func<T, bool>> expr2)
        {
            if (expr1 == null)
            {
                return expr2;
            }
            if (expr2 == null)
            {
                return expr1;
            }
            var parameter = Expression.Parameter(typeof(T), "x");
            var visitor = new ExpressionVisitorEx(parameter);
            var left = visitor.Replace(expr1.Body);
            var right = visitor.Replace(expr2.Body);
            var body = Expression.OrElse(left, right);
            return Expression.Lambda<Func<T, bool>>(body, parameter);
        }

        public static Expression<Func<T, bool>>? Not<T>(this Expression<Func<T, bool>> expr)
        {
            if (expr == null)
            {
                return null;
            }
            var candidateExpr = expr.Parameters.FirstOrDefault();
            if (candidateExpr == null)
            {
                return null;
            }

            var body = Expression.Not(expr.Body);
            return Expression.Lambda<Func<T, bool>>(body, candidateExpr);
        }
    }
}
