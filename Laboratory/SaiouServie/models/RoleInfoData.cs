namespace SaiouService.models
{
    public class RoleInfoData
    {
        //角色ID
        public long id { set; get; }
        //角色名
        public string name { set; get; }
        //角色编码
        public string code { set; get; }

        //车站信息
        public List<StationInfoData>? owerStationList { set; get; }

        //菜单信息
        public List<MenuItemData>? menuItemList { set; get; }

        public bool IsOCC { get { return (this.owerStationList == null || this.owerStationList.Count <= 0); } }
    }
}
