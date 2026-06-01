using System.Collections;
using System.Collections.Immutable;
using System.Diagnostics;
using Utils.Enumerable;

namespace LeetCode.enumerable
{
    public class CollectionInstructions
    {
        public CollectionInstructions()
        {
            //TestArrayList();
            //LinkedListTest();
            //QueueTest();
            //StackTest();
            HashSetTest();
        }
        #region Array type

        #region Array

        /*
         * Array is a collection of items stored at contiguous memory locations.
         * 存储同类型数据
         * 内存连续 
         * 读取快 增删慢
         * 长度不变
         */
        private void TestArray()
        {
            int[] arr = new int[5]; // Declare an array of integers with a fixed size of 5 
            string[] strArr = new string[] { "a", "b", "c"}; // Declare an array of strings with a fixed size of 3
        }

        #endregion Array

        #region ArrayList

        /*
         * ArrayList is a non-generic collection that can hold items of any type.
         * 可存储不同类型数据,值类型要装箱存储，拆箱读取
         * 内存连续 
         * 读取快 增删慢
         * 长度可变
         */
        private void TestArrayList()
        {
            var arrayList = new ArrayList();
            Debug.WriteLine(arrayList.Count); //default 0 
            arrayList.Add(1); // Add an integer
            arrayList.Add("Hello"); // Add a string
            arrayList.Add(3.14); // Add a double
            arrayList.Add(new DateTime(2023, 10, 1)); // Add a DateTime object

            // Access
            var value0 = arrayList[0];
            Debug.WriteLine(value0?.GetType());
            Debug.WriteLine(arrayList[0]?.GetType());
            Debug.WriteLine(1.GetType());

            // remove item
            arrayList.Remove(1); // Remove the integer 1
            arrayList.RemoveAt(0); // Remove the first item (which is now "Hello" after the previous removal)
        }

        #endregion ArrayList

        #region List

        /*
         * List is a generic collection that can hold items of a specified type.
         * 本质类似Array
         * 存储同类型数据，类型安全，避免装箱和拆箱操作
         * 内存连续 
         * 读取快 增删慢
         * 长度可变
         */
        private void TestList()
        {
            var list = new List<int>();
            list.Add(1); // Add an integer
            list.Add(5); // Add another integer
            list.Add(3); // Add another integer
            var sortedList = list.ToImmutableSortedSet(); // Convert to an immutable sorted set
        }

        #endregion List

        #endregion Array type

        #region Linked type

        #region LinkedList

        /*
         * LinkedList is a collection of items where each item (node) contains a reference to the next item.
         * 存储同类型数据
         * 内存不连续 
         * 读取慢，查找不方便, 增删快
         * 长度不变
         */
        private void LinkedListTest()
        {
            var linkedList = new LinkedList<int>();
            linkedList.AddFirst(100); // Add an item to the beginning
            linkedList.AddLast(1); // Add an item to the end

            var node100 = linkedList.Find(100); // Find an item in the linked list
            if (node100 != null)
            {
                var node2 = linkedList.AddBefore(node100, 2); // Add an item before the first item
                linkedList.AddAfter(node100, 3); // Add an item after the first item
                linkedList.Remove(node100);
            }

            bool success = linkedList.Remove(2645);
        }

        #endregion LinkedList

        #region Queue

        /*
         * Queue is a collection that follows the First In First Out (FIFO) principle.
         * Queue是链表 先进先出
         * 存储同类型数据
         * 内存不连续 
         * 读取慢，查找不方便, 增删快
         * 长度可变
         */
        private void QueueTest()
        {
            var queue = new Queue<string>();
            queue.Enqueue("First"); // Add an item to the end of the queue
            queue.Enqueue("Second"); // Add another item to the end of the queue
            queue.Enqueue("Third");
            queue.Enqueue("4");
            queue.Enqueue("5");
            var firstItem = queue.Dequeue(); // Remove and return the first item in the queue
            Debug.WriteLine(firstItem); // Output: First

            var peekItem = queue.Peek(); // Get the first item without removing it
            peekItem = "666";
            Debug.WriteLine(queue.Peek()); // Output: Second

        }

        #endregion Queue

        #region Stack

        /*
         * Stack is a collection that follows the Last In First Out (LIFO) principle.
         * Stack是链表 先进先出
         * 存储同类型数据
         * 内存不连续 
         * 读取慢，查找不方便, 增删快
         * 长度可变
         */
        private void StackTest()
        {
            var stack = new Stack<int>();
            stack.Push(100);
            stack.Push(200);
            stack.Push(300);
            var topItem = stack.Pop(); // Remove and return the top item from the stack
            Debug.WriteLine(topItem); // Output: 300
            var peekItem = stack.Peek(); // Get the top item without removing it
            Debug.WriteLine(peekItem); // Output: 200

        }

        #endregion Stack

        #endregion Linked type

        #region Set type

        #region HashSet

        /*
         * HashSet is a collection that contains unique items and does not allow duplicates.
         * 存储同类型数据
         * 内存不连续 hash分部元素之间没关系
         * 查找，添加，删除都很快，
         * 交叉并补速度快
         * 遍历慢，不支持索引访问
         * 长度可变
         */
        private void HashSetTest()
        {
            var hashSet = new HashSet<string>();
            hashSet.Add("apple");
            hashSet.Add("banana");
            hashSet.Add("pear");
            hashSet.Add("apple"); // Duplicate, will not be added
            Debug.WriteLine(hashSet.Count); // Output: 2, because "apple" is a duplicate and not added again
            hashSet.Remove("banana"); // Remove an item
            Debug.WriteLine(hashSet.Contains("banana")); // Output: False, because "banana" was removed

            var hasSet2 = new HashSet<string> { "apple", "banana", "orange", "mango" };

            // Union 并
            var hashSetUnion = hashSet.ToHashSet();
            hashSetUnion.UnionWith(hasSet2); // Adds all elements from hasSet2 to hashSet
            Debug.WriteLine(hashSetUnion.NotNullString());

            // SymmetricExceptWith 补
            var hasSetSymmetricExceptWith = hashSet.ToHashSet();
            hasSetSymmetricExceptWith.SymmetricExceptWith(hasSet2);
            Debug.WriteLine(hasSetSymmetricExceptWith.NotNullString());

            // Intersect 交
            var hasSetIntersect = hashSet.ToHashSet();
            hasSetIntersect.IntersectWith(hasSet2);
            Debug.WriteLine(hasSetIntersect.NotNullString());

            // Except 差
            var hasSetExcept = hashSet.ToHashSet();
            hasSetExcept.ExceptWith(hasSet2);
            Debug.WriteLine(hasSetExcept.NotNullString());
        }

        #endregion HashSet

        #region SortedSet

        /*
         * SortedSet is a collection that contains unique items and maintains them in sorted order.
         * 存储同类型数据 并自动排序
         * 内存不连续 红黑树
         * 不支持null (需自定义比较器)
         * 查找，添加，删除都很快，
         * 范围查询速度快，取最大值最小值速度快
         * 遍历慢，不支持索引访问
         * 长度可变
         */
        private void SortedSetTest()
        {
            var sortedSet = new SortedSet<int>();
            sortedSet.Add(5);
            sortedSet.Add(3);
            sortedSet.Add(8);
            sortedSet.Add(1); // 添加元素，自动排序
            sortedSet.Add(2);
            sortedSet.Add(4);

            sortedSet.Max(); // 获取最大值
            sortedSet.Min(); // 获取最小值
            Debug.WriteLine(sortedSet.NotNullString()); // 输出: 1, 2, 3, 4, 5, 8
        }

        #endregion SortedSet


        #endregion Set type

        #region Dictionary type

        #region HashTable

        private void HashTableTest()
        {
            /*
             * HashTable is a non-generic collection that stores key-value pairs.
             * 可存储不类型数据
             * 内存不连续 hash分部
             * 遍历慢
             * 查找快，增删快
             * 长度可变
             * 在.NET 2.0及以后版本，通常推荐使用 Dictionary 而非 Hashtable
             */
            var hashTable = new Hashtable();
            hashTable.Add("key1", "value1");
            hashTable.Add("key2", "value2");
            hashTable.Add("key3", "value3");
            Debug.WriteLine(hashTable["key1"]); // Output: value1
            // Check if a key exists
            Debug.WriteLine(hashTable.ContainsKey("key2")); // Output: True
            // Remove an item
            hashTable.Remove("key3");

            // 遍历Hashtable
            foreach (DictionaryEntry de in hashTable)
            {
                Debug.WriteLine($"Key: {de.Key}, Value: {de.Value}");
            }
        }

        #endregion HashTable

        #region Dictionary

        /*
         * Dictionary is a generic collection that stores key-value pairs.
         * 存储同类型数据
         * 内存不连续 hash分部
         * 增删改查都很快
         * 有序
         */
        private void DictionaryTest()
        {
            var dictionary = new Dictionary<string, int>();
            dictionary.Add("apple", 1);
            dictionary.Add("banana", 2);
            dictionary.Add("orange", 3);
            // Access by key
            Debug.WriteLine(dictionary["apple"]); // Output: 1
            // Check if a key exists
            Debug.WriteLine(dictionary.ContainsKey("banana")); // Output: True
            // Remove an item
            dictionary.Remove("orange");
            // Iterate through the dictionary
            foreach (var kvp in dictionary)
            {
                Debug.WriteLine($"Key: {kvp.Key}, Value: {kvp.Value}");
            }
        }

        #endregion Dictionary

        #region SortedDictionary

        #endregion SortedDictionary

        #region SortedList

        #endregion SortedList

        #endregion Dictionary type

        #region Interfaces

        /*
         * IEnumerable<T> - 可枚举的集合
         * ICollection<T> - 集合接口，继承自 IEnumerable<T>
         * IList<T> - 列表接口，继承自 ICollection<T>
         * IReadOnlyList<T> - 只读列表接口，继承自 IEnumerable<T>
         * IReadOnlyCollection<T> - 只读集合接口，继承自 IEnumerable<T>
         * IDictionary<TKey, TValue> - 字典接口，继承自 ICollection<KeyValuePair<TKey, TValue>>
         * 
         * IQueryable<T> - 可查询的集合接口，允许使用 LINQ 查询
         */

        private void InterfacesTest()
        {
            var list = new List<string> { "apple", "banana", "cherry", "mango", "grape" };

            // IEnumerable<T>
            IEnumerable<string> enumerable = list.Where(x => x.Length > 5);
            // IQueryable<T>
            IQueryable<string> queryable = list.AsQueryable().Where(x => x.Length > 5);
        }

        #endregion Interfaces

    }
}
