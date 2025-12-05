using DataAccess.Abstractions;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Business_Logic.Errors
{
    public static class ProjectErrors
    {
        public static readonly Error ProjectNotFound =
            new("Project.NotFound", "No project was found with the given ID");

        public static readonly Error ProjectInvalidDifficulty =
            new("Project.InvalidDifficulty", "Invalid difficulty level. Must be Easy, Medium, or Hard");
    }
}
