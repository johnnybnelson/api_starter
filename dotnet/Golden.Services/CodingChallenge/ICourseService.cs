using Golden.Models;
using Golden.Models.Domain.CodingChallenge.Domain;
using Golden.Models.Domain.CodingChallenge.Requests;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Golden.Services.CodingChallenge
{
    public interface ICourseService
    {
        int AddCourse(CourseAddRequest newCourse);

        Course GetCourseById(int id);

        void UpdateCourse(CourseUpdateRequest existingCourse);

        void DeleteStudent(int Id);

        Paged<Course> GetCoursesByPage(int pageIndex, int pageSize);



    }
}
