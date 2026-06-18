namespace SmartCareerHub.IService.UserProfileService
{
    public interface IUserProfileService
    {
        Task<UserProfileResponse> GetMyProfileAsync(string userId);
        Task<UserProfileResponse> GetPublicProfileAsync(string userId);
        Task<UserProfileResponse> UpdateProfileAsync(string userId, UpdateProfileRequest request);
    }
}
