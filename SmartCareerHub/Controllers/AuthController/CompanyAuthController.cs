using Business_Logic.Errors;
using Business_Logic.IService;
using DataAccess.Abstractions;
using DataAccess.Entities.Users;
using DataAccess.IRepository;
using Mapster;
using Microsoft.AspNetCore.Mvc;
using SmartCareerHub.Contracts.Auth;
using System;
using System.IO;
using System.Threading.Tasks;

namespace SmartCareerHub.Controllers.Auth
{
    [ApiController]
    [Route("api/[controller]")]
    public class CompanyAuthController : ControllerBase
    {
        private readonly IAuthService _authService;

        public CompanyAuthController(IAuthService authService)
        {
            _authService = authService;
        }

        [HttpPost("register")]
        public async Task<IActionResult> RegisterCompany([FromForm] RegisterCompanyRequest request)
        {
            try
            {
                var result = await _authService.RegisterCompanyAsync(request);

                if (!result.IsSuccess)
                    return BadRequest(result.Error);

                return Ok(result.Value);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new Error("Auth.Exception", "An unexpected error occurred. " + ex.Message));
            }
        }
    }
}
