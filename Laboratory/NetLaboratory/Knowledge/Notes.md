## 处理超时
```
Task.WaitAsync(TimeSpan.FromSeconds(5)) -- 等待5秒
```

## 获取当前线程

Environment.CurrentManagedThreadId 是 System.Environment 类提供的一个静态属性，用于直接获取当前正在执行的托管线程的唯一标识符（托管线程 ID）。

与 Thread.CurrentThread.ManagedThreadId 的对比：
维度	Environment.CurrentManagedThreadId	Thread.CurrentThread.ManagedThreadId
功能	仅返回当前托管线程的 ID（int）	返回当前托管线程的 ID（通过 Thread 对象）
额外信息	不提供线程的其他属性（如优先级、是否后台线程等）	可通过 Thread 对象获取线程的完整信息
调用便捷性	更简洁（直接静态属性调用）	需先获取 Thread 对象再访问属性
适用场景	仅需线程 ID 时（如日志标记、线程追踪）	需要操作线程或获取线程其他信息时
