using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Utils.Events;

namespace NetLaboratory.Knowledge.netBasic
{
    internal class RefoutClass
    {
        public int classX { get; set; } = 9;

        public PointInClass StructInClass = new PointInClass(1, 2);
        public struct PointInClass 
        {
            public int X;
            public int Y;
            public PointInClass(int x, int y)
            {
                X = x;
                Y = y;
            }
        }

    }


    public class RefOut
    {
        public struct Point
        {
            public int X;
            public int Y;
            public string? str = "Point";
            internal RefoutClass? refoutClass { get; set; } = new RefoutClass();
            public Point(int x, int y)
            {
                X = x;
                Y = y;
            }
        }
        public RefOut() { }

        #region Struct 作为参数传递的方式

        // 无修饰符:传递副本（原始值不变）
        private void ModifyStruct(Point p)
        {
            p.X = 100;
            p.Y = 200;
            p.str = "ModifyStruct";
            if (p.refoutClass != null)
            {
                //p.refoutClass = new RefoutClass();
                p.refoutClass.classX = 666;
            }
        }

        // ref修饰符:传递引用（原始值改变,修改生效）
        private void ModifyStruct(ref Point p)
        {
            p.X = 100;
            p.Y = 200;
            p.str = "ModifyStruct";
            p.refoutClass = new RefoutClass() { classX = 99 };
        }

        // out修饰符:传递引用（原始值改变,修改生效）
        private void CreateStruct(out Point p)
        {
            // 必须给p一个初始值，否则编译错误
            p = new Point(100, 200);
            p.str = "ModifyStruct";
            p.refoutClass = new RefoutClass() { classX = 99 };
            // out参数可以直接赋值
        }

        public void RunStruct()
        {
            var p1 = new Point(1,2);
            ModifyStruct(p1); // 无修饰符传递副本，p1不变
            LogEvents.Publish($"p1 ModifyStruct: X={p1.X}, Y={p1.Y}, str={p1.str}, refoutClass.classX={p1.refoutClass?.classX}");
            // 输出: X=1, Y=2, str=Point, refoutClass.classX=666

            var p2 = new Point(1,2);
            ModifyStruct(ref p2); // ref修饰符传递引用，p2改变
            LogEvents.Publish($"p2 ModifyStruct(ref): X={p2.X}, Y={p2.Y}, str={p2.str}, refoutClass.classX={p2.refoutClass?.classX}");
            // 输出: X=100, Y=200, str=ModifyStruct, refoutClass.classX=99

            Point p3; // out修饰符需要先声明变量
            CreateStruct(out p3); // out修饰符传递引用，p3被赋值
            LogEvents.Publish($"p3 CreateStruct(out): X={p3.X}, Y={p3.Y}, str={p3.str}, refoutClass.classX={p3.refoutClass?.classX}");
            // 输出: X=100, Y=200, str=ModifyStruct,refoutClass.classX = 99
        }

        #endregion Struct 作为参数传递的方式

        #region class 作为参数传递的方式

        // 无修饰符:传递引用（原始值改变,修改生效, 重新new无效，不影响原始引用）
        private void ModifyClass(RefoutClass c)
        {
            c.classX = 100;
            c.StructInClass.X = 10;
            c.StructInClass.Y = 20;
            c = new RefoutClass();
        }

        // ref修饰符:传递引用（原始值改变,修改生效, 重新new会改变原始引用）
        private void ModifyClass(ref RefoutClass c)
        {
            c.classX = 100;
            c.StructInClass.X = 10;
            c.StructInClass.Y = 20;
            c = new RefoutClass(); // 重新new会改变原始引用
        }

        // out修饰符:传递引用（原始值改变,修改生效, 重新new会改变原始引用）
        private void CreateClass(out RefoutClass c)
        {
            c = new RefoutClass(); // 必须给c一个初始值，否则编译错误
            c.classX = 100;
            c.StructInClass.X = 10;
            c.StructInClass.Y = 20;
            // out参数可以直接赋值
        }

        public void RunClass()
        {
            var c1 = new RefoutClass() 
            { 
                classX = 1,
            };
            ModifyClass(c1); // 无修饰符传递引用，c1改变
            LogEvents.Publish($"c1 ModifyClass: classX={c1.classX}, StructInClass.X={c1.StructInClass.X}, Y={c1.StructInClass.Y} ");
            // 输出: classX=100, StructInClass.X=10, Y=20

            var c2 = new RefoutClass()
            {
                classX = 1,
            };
            ModifyClass(ref c2);
            LogEvents.Publish($"c2 ModifyClass: classX={c2.classX}, StructInClass.X={c2.StructInClass.X}, Y={c2.StructInClass.Y} ");
            // 输出: classX=9, StructInClass.X=1, Y=2

            var c3 = new RefoutClass()
            {
                classX = 1,
            };
            CreateClass(out c3);
            LogEvents.Publish($"c3 CreateClass: classX={c3.classX}, StructInClass.X={c3.StructInClass.X}, Y={c3.StructInClass.Y} ");
            // 输出: classX=100, StructInClass.X=10, Y=20
        }

        #endregion class 作为参数传递的方式

    }
}
