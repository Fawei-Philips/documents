namespace SaiouService.models
{
    public class MenuItemData
    {
        //ID
        public long id { set; get; }

        //菜单名
        public string name { set; get; }

        //菜单编码
        public string code { set; get; }

        //菜单缩写
        public string abbr { set; get; }

        //父ID
        public long parentId { set; get; }

        //画面名
        public string viewName { set; get; }
    }
}
