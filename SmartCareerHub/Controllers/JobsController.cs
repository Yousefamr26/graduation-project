using Business_Logic.Errors;
using DataAccess.Abstractions;
using DataAccess.Entities.Job;
using DataAccess.IRepository;
using Mapster;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc;
using SmartCareerHub.Contracts.Company.Jobs;
using SmartCareerHub.Extensions;

namespace API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class JobsController : ControllerBase
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly string _rootPath;

        public JobsController(IUnitOfWork unitOfWork, IWebHostEnvironment env)
        {
            _unitOfWork = unitOfWork;
            _rootPath = Path.Combine(env.WebRootPath ?? "wwwroot", "uploads", "jobs");

            // Create required folders
            foreach (var folder in new[] { "", "logos" })
            {
                var path = Path.Combine(_rootPath, folder);
                if (!Directory.Exists(path))
                    Directory.CreateDirectory(path);
            }
        }

      
        [HttpGet("{id:int}")]
        public async Task<IActionResult> GetById(int id)
        {
            var result = await _unitOfWork.Jobs.GetByIdAsync(id);
            if (result.IsFailure)
                return result.ToActionResult();

            var response = result.Value.Adapt<JobResponse>();
            return Ok(response);
        }

      
        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            var result = await _unitOfWork.Jobs.GetAllAsync();
            if (result.IsFailure)
                return result.ToActionResult();

            var response = result.Value.Adapt<IEnumerable<JobResponse>>();
            return Ok(response);
        }

      
        [HttpGet("search")]
        public async Task<IActionResult> Search([FromQuery] string keyword)
        {
            if (string.IsNullOrWhiteSpace(keyword))
                return BadRequest("Search keyword is required");

            var result = await _unitOfWork.Jobs.SearchJobsAsync(keyword);
            if (result.IsFailure)
                return result.ToActionResult();

            var response = result.Value.Adapt<IEnumerable<JobResponse>>();
            return Ok(response);
        }

      
        [HttpGet("type/{jobType}")]
        public async Task<IActionResult> GetByType(string jobType)
        {
            var result = await _unitOfWork.Jobs.GetJobsByTypeAsync(jobType);
            if (result.IsFailure)
                return result.ToActionResult();

            var response = result.Value.Adapt<IEnumerable<JobResponse>>();
            return Ok(response);
        }

       
        [HttpGet("level/{experienceLevel}")]
        public async Task<IActionResult> GetByExperienceLevel(string experienceLevel)
        {
            var result = await _unitOfWork.Jobs.GetJobsByExperienceLevelAsync(experienceLevel);
            if (result.IsFailure)
                return result.ToActionResult();

            var response = result.Value.Adapt<IEnumerable<JobResponse>>();
            return Ok(response);
        }

       
        [HttpGet("location/{location}")]
        public async Task<IActionResult> GetByLocation(string location)
        {
            var result = await _unitOfWork.Jobs.GetJobsByLocationAsync(location);
            if (result.IsFailure)
                return result.ToActionResult();

            var response = result.Value.Adapt<IEnumerable<JobResponse>>();
            return Ok(response);
        }

       
        [HttpGet("latest")]
        public async Task<IActionResult> GetLatest([FromQuery] int count = 10)
        {
            if (count <= 0 || count > 100)
                return BadRequest("Count must be between 1 and 100");

            var result = await _unitOfWork.Jobs.GetLatestJobsAsync(count);
            if (result.IsFailure)
                return result.ToActionResult();

            var response = result.Value.Adapt<IEnumerable<JobResponse>>();
            return Ok(response);
        }

       
        [HttpGet("count")]
        public async Task<IActionResult> GetCount()
        {
            var result = await _unitOfWork.Jobs.GetTotalJobsCountAsync();
            if (result.IsFailure)
                return result.ToActionResult();

            return Ok(new { count = result.Value });
        }

        
        [HttpPost]
        public async Task<IActionResult> Create([FromForm] JobRequest request)
        {
            if (string.IsNullOrWhiteSpace(request.Title))
                return Result.Failure<Job>(JobErrors.JobInvalidRequest).ToActionResult();

            if (await _unitOfWork.Jobs.IsTitleExistsAsync(request.Title))
                return Result.Failure<Job>(JobErrors.JobTitleExists).ToActionResult();

            await _unitOfWork.BeginTransactionAsync();
            try
            {
                var job = request.Adapt<Job>();
                job.CreatedAt = DateTime.UtcNow;

                if (request.CompanyLogo != null)
                {
                    job.CompanyLogo = await SaveFileAsync(request.CompanyLogo, "logos");
                }

                var addedResult = await _unitOfWork.Jobs.AddJobAsync(job);
                if (addedResult.IsFailure)
                {
                    await _unitOfWork.RollbackTransactionAsync();
                    return addedResult.ToActionResult();
                }

                job = addedResult.Value;
                await _unitOfWork.SaveChangesAsync();
                await _unitOfWork.CommitTransactionAsync();

                var fullResult = await _unitOfWork.Jobs.GetByIdAsync(job.Id);
                if (fullResult.IsFailure)
                {
                    return StatusCode(500, "Job created but failed to retrieve details");
                }

                var response = fullResult.Value.Adapt<JobResponse>();
                return CreatedAtAction(nameof(GetById), new { id = job.Id }, response);
            }
            catch (Exception ex)
            {
                await _unitOfWork.RollbackTransactionAsync();
                return Result.Failure<Job>(
                    new Error("Job.CreateFailed", $"Failed to create job: {ex.Message}")
                ).ToActionResult();
            }
        }

       
        [HttpPut("{id:int}")]
        public async Task<IActionResult> Update(int id, [FromForm] JobRequest request)
        {
            var existingResult = await _unitOfWork.Jobs.GetByIdAsync(id);
            if (existingResult.IsFailure)
                return existingResult.ToActionResult();

            if (await _unitOfWork.Jobs.IsTitleExistsAsync(request.Title, id))
                return Result.Failure(JobErrors.JobTitleExists).ToActionResult();

            await _unitOfWork.BeginTransactionAsync();
            try
            {
                var job = existingResult.Value;

                job.Title = request.Title;
                job.Description = request.Description;
                job.RequiredSkills = request.RequiredSkills;
                job.ExperienceLevel = request.ExperienceLevel;
                job.JobType = request.JobType;
                job.Location = request.Location;
                job.SalaryRange = request.SalaryRange;

                if (request.CompanyLogo != null)
                {
                    job.CompanyLogo = await SaveFileAsync(request.CompanyLogo, "logos");
                }

                var updateResult = await _unitOfWork.Jobs.UpdateAsync(job);
                if (updateResult.IsFailure)
                {
                    await _unitOfWork.RollbackTransactionAsync();
                    return updateResult.ToActionResult();
                }

                await _unitOfWork.SaveChangesAsync();
                await _unitOfWork.CommitTransactionAsync();

                var refreshedResult = await _unitOfWork.Jobs.GetByIdAsync(id);
                if (refreshedResult.IsFailure)
                {
                    return StatusCode(500, "Job updated but failed to retrieve details");
                }

                var response = refreshedResult.Value.Adapt<JobResponse>();
                return Ok(response);
            }
            catch (Exception ex)
            {
                await _unitOfWork.RollbackTransactionAsync();
                return Result.Failure(
                    new Error("Job.UpdateFailed", $"Failed to update job: {ex.Message}")
                ).ToActionResult();
            }
        }


        [HttpDelete("{id:int}")]
        public async Task<IActionResult> Delete(int id)
        {
            var result = await _unitOfWork.Jobs.DeleteAsync(id);
            return result.ToActionResult();
        }

        
        [HttpDelete("bulkdelete")]
        public async Task<IActionResult> BulkDelete([FromBody] List<int> ids)
        {
            if (ids == null || !ids.Any())
                return BadRequest("No job IDs provided");

            var result = await _unitOfWork.Jobs.BulkDeleteAsync(ids);
            return result.ToActionResult();
        }

        private async Task<string> SaveFileAsync(IFormFile file, string subFolder)
        {
            try
            {
                var folder = Path.Combine(_rootPath, subFolder);
                if (!Directory.Exists(folder))
                    Directory.CreateDirectory(folder);

                var name = $"{Guid.NewGuid()}{Path.GetExtension(file.FileName)}";
                var path = Path.Combine(folder, name);

                using var stream = new FileStream(path, FileMode.Create);
                await file.CopyToAsync(stream);

                return $"/uploads/jobs/{subFolder}/{name}";
            }
            catch (Exception ex)
            {
                throw new IOException($"Failed to save file: {ex.Message}", ex);
            }
        }
    }
}