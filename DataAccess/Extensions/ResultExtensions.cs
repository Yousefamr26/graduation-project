using DataAccess.Abstractions;
using Microsoft.AspNetCore.Mvc;

namespace SmartCareerHub.Extensions
{
    public static class ResultExtensions
    {
        public static IActionResult ToActionResult(this Result result)
        {
            if (result.IsSuccess)
                return new NoContentResult(); 

            return result.Error.Code switch
            {
                
                var code when code.EndsWith(".NotFound") =>
                    new NotFoundObjectResult(CreateErrorResponse(result.Error)),

                
                var code when code.Contains("Exists") || code.Contains("AlreadyExists") =>
                    new ConflictObjectResult(CreateErrorResponse(result.Error)),

               
                _ => new BadRequestObjectResult(CreateErrorResponse(result.Error))
            };
        }

    
        public static IActionResult ToActionResult<T>(this Result<T> result)
        {
            if (result.IsSuccess)
                return new OkObjectResult(result.Value); 

            return result.Error.Code switch
            {
                var code when code.EndsWith(".NotFound") =>
                    new NotFoundObjectResult(CreateErrorResponse(result.Error)),

                var code when code.Contains("Exists") || code.Contains("AlreadyExists") =>
                    new ConflictObjectResult(CreateErrorResponse(result.Error)),

                _ => new BadRequestObjectResult(CreateErrorResponse(result.Error))
            };
        }

      
        public static IActionResult ToCreatedResult<T>(
            this Result<T> result,
            string actionName,
            object routeValues)
        {
            if (result.IsSuccess)
            {
                return new CreatedAtActionResult(
                    actionName,
                    controllerName: null,
                    routeValues,
                    result.Value
                );
            }

            return result.Error.Code switch
            {
                var code when code.EndsWith(".NotFound") =>
                    new NotFoundObjectResult(CreateErrorResponse(result.Error)),

                var code when code.Contains("Exists") || code.Contains("AlreadyExists") =>
                    new ConflictObjectResult(CreateErrorResponse(result.Error)),

                _ => new BadRequestObjectResult(CreateErrorResponse(result.Error))
            };
        }

        private static object CreateErrorResponse(Error error)
        {
            return new
            {
                code = error.Code,
                description = error.Description  
            };
        }
    }
}
