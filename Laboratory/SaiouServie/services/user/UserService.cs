using SaiouService.models;
using Utils.Ioc;

namespace SaiouService.services.user
{
    [Register(Lifetime = Lifetime.Transient, ServiceType = typeof(IUserService))]
    public class UserService : IUserService
    {
        public UserService() { }

        public async Task<UserInfoData> GetUserInfoAsync(long userId)
        {
            // Simulate fetching user info from a database or external service
            var role = GetUserRole(userId);

            return await Task.FromResult(new UserInfoData
            {
                Id = userId,
                account = "account" + userId,
                userName = "userName " + userId,
                nationalId = "nationalId" + userId,
                email = "user" + userId + "@example.com",
                phone = "123-456-7890",
                roleInfo = role
            });
        }

        public Task<List<MenuItemData>> GetMenuItemsAsync(long parnetId)
        {
            // Simulate fetching user menu items from a database or external service
            return Task.FromResult(new List<MenuItemData>
            {
                new MenuItemData { id = 1, name = "Dashboard", code = "DASH", abbr = "DSH", parentId = 0, viewName = "DashboardView" },
                new MenuItemData { id = 2, name = "Settings", code = "SETTINGS", abbr = "SET", parentId = 1, viewName = "SettingsView" }
            });
        }

        public Task<List<StationInfoData>> GetStationsAsync(long parnetId)
        {
            // Simulate fetching user menu items from a database or external service
            return Task.FromResult(new List<StationInfoData>
            {
                new() { id = 1, name = "Station A", code = "STA", abbr = "STA", parentId = 0, viewName = "StationAView" },
                new () { id = 2, name = "Station B", code = "STB", abbr = "STB", parentId = 1, viewName = "StationBView" }
            });
        }

        public RoleInfoData? GetUserRole(long userId)
        {
            var dummyMenus = GetMenuItemsAsync(0).Result;
            var dummyStations = GetStationsAsync(0).Result;
            var dummyRoles = new List<RoleInfoData>
            {
                new RoleInfoData { id = 1, name = "Admin", code = "ADMIN", menuItemList = dummyMenus, owerStationList = dummyStations },
                new RoleInfoData { id = 2, name = "User", code = "USER", menuItemList = dummyMenus, owerStationList = dummyStations }
            };
            // Simulate fetching user roles from a database or external service
            return dummyRoles.FirstOrDefault(r => r.id == userId);
        }
    }
}
