using SaiouService.models;

namespace SaiouService.services.user
{
    public interface IUserService
    {
        /// <summary>
        /// 获取用户信息
        /// </summary>
        /// <param name="userId">用户ID</param>
        /// <returns>用户信息</returns>
        Task<models.UserInfoData> GetUserInfoAsync(long userId);
        /// <summary>
        /// 获取用户角色信息
        /// </summary>
        /// <param name="userId">用户ID</param>
        /// <returns>角色信息</returns>
        RoleInfoData? GetUserRole(long userId);
        /// <summary>
        /// 获取用户菜单信息
        /// </summary>
        /// <param name="userId">用户ID</param>
        /// <returns>菜单信息列表</returns>
        Task<List<models.MenuItemData>> GetMenuItemsAsync(long parentId);
    }
}
