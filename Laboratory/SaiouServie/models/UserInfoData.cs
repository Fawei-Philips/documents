namespace SaiouService.models
{
    public class UserInfoData
    {
        //用户ID
        public long Id { set; get; }
        //账号
        public string? account { set; get; }
        //姓名
        public string? userName { set; get; }
        //身份ID
        public string? nationalId { set; get; }
        //邮箱
        public string? email { set; get; }
        //手机号
        public string? phone { set; get; }

        //角色信息
        public RoleInfoData? roleInfo { set; get; }
    }
}
