## CLR

- CLR (Common Language Runtime) is the virtual machine component of Microsoft's .NET framework.
 It provides a managed execution environment for .NET applications, handling memory management, security, and exception handling. 
CLR allows developers to write code in multiple languages, which can then be executed in a consistent manner across different platforms.

- C# -> compiler -> dll / exe (IL (Intermediate Language) + metadata) -> CLR -> JIT (Just-In-Time) compiler -> machine code
### dll / exe 
    
    - CLR -> JIT (Just-In-Time) compiler -> machine code
## 内存分配

- CLR manages memory allocation and deallocation for .NET applications.
- 值类型 - 存储在栈上，分配和释放速度快。
  - 包括基本数据类型（如int、float等）和结构体

- 引用类型 - 存储在堆上，分配和释放速度较慢。
    - 包括类、数组和字符串等。
    - 在 C# 里，引用类型变量的存储情况要分两方面来看：变量本身和它所引用的对象。
      变量本身是存于栈内存的。不过，该变量指向的实际对象，也就是引用类型的实例，是在堆内存里分配空间的。
- 类中的字段和属性包括值类型的字段, 通常是引用类型，存储在堆上。

## GC 垃圾回收
- GC (Garbage Collection) 是 CLR 的一部分，负责自动管理内存。

1. 内存不足时自动触发
当新一代（如第 0 代或第 1 代）的对象占用内存达到阈值，GC 就会被触发。比如：
新创建的对象在第 0 代中分配内存，要是第 0 代的内存空间不够了，就会引发一次第 0 代的 GC。
如果第 0 代 GC 后，存活下来的对象被移到第 1 代，使得第 1 代的内存达到阈值，就会触发第 1 代的 GC，此时第 0 代也会一起被回收。
同样地，第 1 代 GC 后，存活对象进入第 2 代，当第 2 代内存不足时，会触发完整的 GC，也就是第 2 代 GC。
2. 手动调用 GC.Collect ()
在某些特殊情形下，你可以手动调用GC.Collect()方法来强制启动垃圾回收。不过，这种做法一般不建议使用，除非是在进行性能测试或者释放一些特殊资源（如 COM 对象、文件句柄等）时。例如：
csharp
GC.Collect(); // 强制进行一次完整的垃圾回收

3. 系统资源紧张时
当系统内存不足或者 CPU 处于空闲状态时，GC 可能会被触发，以此来释放更多的内存。
4. 应用程序域卸载时
在应用程序域（AppDomain）被卸载的时候，会触发一次 GC，从而回收该应用程序域所占用的资源。
5. 终结器队列满时
要是对象的终结器（Finalizer）队列快要满了，GC 会被触发，进而执行这些对象的终结器。
6. 非托管对象（Unmanaged Objects）不由 GC 管理生命周期的对象，通常是操作系统资源或第三方库资源。
    - 需手动释放（如实现IDisposable接口， 调用Dispose()）
    - 在 C# 中，非托管资源通常是指那些不由 .NET 的垃圾回收器（GC）管理的资源，如文件句柄、数据库连接、网络套接字等。
    - 使用using语句释放 == try-finally 自动调用Dispose() 
    - 终结器（Finalizer）是对象的析构函数，在对象被垃圾回收之前执行。
    - 误区：认为实现IDisposable的对象都是非托管对象 
    - 总结
        - 托管对象：由 GC 自动管理，无需手动释放。
        - 非托管对象：需手动释放，通常通过IDisposable接口实现。
        - 最佳实践：优先使用using语句管理非托管资源，避免依赖终结器。

``` csharp

   protected virtual void Dispose(bool disposing)
    {
        if (!_disposed)
        {
            if (disposing)
            {
                // 释放托管资源（如果有）
            }
            
            // 释放非托管资源
            NativeMethods.FreeResource(_handle);
            _handle = IntPtr.Zero;
            _disposed = true;
        }
    }

```