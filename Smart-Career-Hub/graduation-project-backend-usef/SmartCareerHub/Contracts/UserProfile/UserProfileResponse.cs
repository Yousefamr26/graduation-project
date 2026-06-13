public record UserProfileResponse(
       UserBasicInfoDto BasicInfo,
       UserStatsDto Stats,
       List<RoadmapProgressCardDto> RoadmapsProgress,
       List<SkillProgressDto> Skills,
       List<AchievementDto> Achievements,
       List <ActivityDto> ActivityDtos
   );