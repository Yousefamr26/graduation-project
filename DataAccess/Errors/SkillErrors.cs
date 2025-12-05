using DataAccess.Abstractions;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Business_Logic.Errors
{
    public static class SkillErrors
    {
        public static readonly Error SkillNotFound =
            new("Skill.NotFound", "No skill was found with the given ID");

        public static readonly Error SkillAlreadyExists =
            new("Skill.AlreadyExists", "A skill with this name already exists");
    }
}
