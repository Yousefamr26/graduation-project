// {
// "info": {
// "_postman_id": "2cf0d620-9082-459c-b64f-0be37045c840",
// "name": "SmartCareerHub",
// "schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json",
// "_exporter_id": "40684496"
// },
// "item": [
// {
// "name": "Company",
// "item": [
// {
// "name": "RoadMap",
// "item": [
// {
// "name": "Get Roadmap by ID",
// "request": {
// "method": "GET",
// "header": []
// },
// "response": []
// },
// {
// "name": "Get All Roadmaps",
// "request": {
// "method": "GET",
// "header": []
// },
// "response": []
// },
// {
// "name": "Get Published",
// "request": {
// "method": "GET",
// "header": []
// },
// "response": []
// },
// {
// "name": "Create Roadmap",
// "request": {
// "method": "POST",
// "header": [],
// "body": {
// "mode": "formdata",
// "formdata": [
// {
// "key": "Title",
// "value": "My First Roadmap2056465",
// "type": "text"
// },
// {
// "key": "Description",
// "value": "Description of roadmap",
// "type": "text"
// },
// {
// "key": "TargetRole",
// "value": "Student",
// "type": "text"
// },
// {
// "key": "StartDate",
// "value": "2025-12-07T00:00:00Z",
// "type": "text"
// },
// {
// "key": "EndDate",
// "value": "2026-01-07T00:00:00Z",
// "type": "text"
// },
// {
// "key": "IsPublished",
// "value": "true",
// "type": "text"
// },
// {
// "key": "CoverImage",
// "type": "file",
// "src": "/D:/Downloads/IDM/download (1).jpg"
// },
// {
// "key": "SkillRequests[0].SkillName",
// "value": "C#",
// "type": "text"
// },
// {
// "key": "SkillRequests[0].Level",
// "value": "Beginner",
// "type": "text"
// },
// {
// "key": "SkillRequests[0].LevelPoints",
// "value": "10",
// "type": "text"
// },
// {
// "key": "SkillRequests[1].SkillName",
// "value": "SQL",
// "type": "text"
// },
// {
// "key": "SkillRequests[1].Level",
// "value": "Intermediate",
// "type": "text"
// },
// {
// "key": "SkillRequests[1].LevelPoints",
// "value": "15",
// "type": "text"
// },
// {
// "key": "LearningMaterialRequests[0].TitleVideos",
// "value": "Intro Video",
// "type": "text"
// },
// {
// "key": "LearningMaterialRequests[0].Duration",
// "value": "Medium",
// "type": "text"
// },
// {
// "key": "LearningMaterialRequests[0].Type",
// "value": "Video",
// "type": "text"
// },
// {
// "key": "LearningMaterialRequests[0].Points",
// "value": "20",
// "type": "text"
// },
// {
// "key": "LearningMaterialRequests[0].FilePath",
// "type": "file",
// "src": "/D:/Downloads/Video/Records/2025-10-18 03-35-37.mp4"
// },
// {
// "key": "LearningMaterialRequests[1].TitleVideos",
// "value": "Advanced Video",
// "type": "text"
// },
// {
// "key": "LearningMaterialRequests[1].Duration",
// "value": "Medium",
// "type": "text"
// },
// {
// "key": "LearningMaterialRequests[1].Type",
// "value": "Video",
// "type": "text"
// },
// {
// "key": "LearningMaterialRequests[1].Points",
// "value": "25",
// "type": "text"
// },
// {
// "key": "LearningMaterialRequests[1].FilePath",
// "type": "file",
// "src": "/D:/Downloads/Video/Records/2025-10-18 03-36-43.mp4"
// },
// {
// "key": "ProjectRequests[0].Title",
// "value": "Mini Project 1",
// "type": "text"
// },
// {
// "key": "ProjectRequests[0].Description",
// "value": "Project description",
// "type": "text"
// },
// {
// "key": "ProjectRequests[0].Difficulty",
// "value": "Easy",
// "type": "text"
// },
// {
// "key": "ProjectRequests[0].Points",
// "value": "30",
// "type": "text"
// },
// {
// "key": "QuizRequests[0].Title",
// "value": "C# Basics Quiz",
// "type": "text"
// },
// {
// "key": "QuizRequests[0].Type",
// "value": "MCQ",
// "type": "text"
// },
// {
// "key": "QuizRequests[0].Points",
// "value": "10",
// "type": "text"
// },
// {
// "key": "QuizRequests[0].QuestionRequests[0].Text",
// "value": "What is C#?",
// "type": "text"
// },
// {
// "key": "QuizRequests[0].QuestionRequests[0].Type",
// "value": "MCQ",
// "type": "text"
// },
// {
// "key": "QuizRequests[0].QuestionRequests[0].OptionsJson",
// "value": "[\"Language\",\"Car\",\"Food\"]",
// "type": "text"
// },
// {
// "key": "QuizRequests[0].QuestionRequests[0].CorrectAnswer",
// "value": "Language",
// "type": "text"
// }
// ]
// },
// "url": {
// "raw": "{{baseUrl}}/api/Roadmaps",
// "host": [
// "{{baseUrl}}"
// ],
// "path": [
// "api",
// "Roadmaps"
// ]
// },
// "description": "Create a new roadmap with skills, learning materials, projects, and quizzes"
// },
// "response": []
// },
// {
// "name": "Update Roadmap",
// "request": {
// "method": "POST",
// "header": [],
// "body": {
// "mode": "formdata",
// "formdata": [
// {
// "key": "Title",
// "value": "My First Roadmap2056465",
// "type": "text"
// },
// {
// "key": "Description",
// "value": "Description of roadmap",
// "type": "text"
// },
// {
// "key": "TargetRole",
// "value": "Student",
// "type": "text"
// },
// {
// "key": "StartDate",
// "value": "2025-12-07T00:00:00Z",
// "type": "text"
// },
// {
// "key": "EndDate",
// "value": "2026-01-07T00:00:00Z",
// "type": "text"
// },
// {
// "key": "IsPublished",
// "value": "true",
// "type": "text"
// },
// {
// "key": "CoverImage",
// "type": "file",
// "src": "/D:/Downloads/IDM/download (1).jpg"
// },
// {
// "key": "SkillRequests[0].SkillName",
// "value": "C#",
// "type": "text"
// },
// {
// "key": "SkillRequests[0].Level",
// "value": "Beginner",
// "type": "text"
// },
// {
// "key": "SkillRequests[0].LevelPoints",
// "value": "10",
// "type": "text"
// },
// {
// "key": "SkillRequests[1].SkillName",
// "value": "SQL",
// "type": "text"
// },
// {
// "key": "SkillRequests[1].Level",
// "value": "Intermediate",
// "type": "text"
// },
// {
// "key": "SkillRequests[1].LevelPoints",
// "value": "15",
// "type": "text"
// },
// {
// "key": "LearningMaterialRequests[0].TitleVideos",
// "value": "Intro Video",
// "type": "text"
// },
// {
// "key": "LearningMaterialRequests[0].Duration",
// "value": "Medium",
// "type": "text"
// },
// {
// "key": "LearningMaterialRequests[0].Type",
// "value": "Video",
// "type": "text"
// },
// {
// "key": "LearningMaterialRequests[0].Points",
// "value": "20",
// "type": "text"
// },
// {
// "key": "LearningMaterialRequests[0].FilePath",
// "type": "file",
// "src": "/D:/Downloads/Video/Records/2025-10-18 03-35-37.mp4"
// },
// {
// "key": "LearningMaterialRequests[1].TitleVideos",
// "value": "Advanced Video",
// "type": "text"
// },
// {
// "key": "LearningMaterialRequests[1].Duration",
// "value": "Medium",
// "type": "text"
// },
// {
// "key": "LearningMaterialRequests[1].Type",
// "value": "Video",
// "type": "text"
// },
// {
// "key": "LearningMaterialRequests[1].Points",
// "value": "25",
// "type": "text"
// },
// {
// "key": "LearningMaterialRequests[1].FilePath",
// "type": "file",
// "src": "/D:/Downloads/Video/Records/2025-10-18 03-36-43.mp4"
// },
// {
// "key": "ProjectRequests[0].Title",
// "value": "Mini Project 1",
// "type": "text"
// },
// {
// "key": "ProjectRequests[0].Description",
// "value": "Project description",
// "type": "text"
// },
// {
// "key": "ProjectRequests[0].Difficulty",
// "value": "Easy",
// "type": "text"
// },
// {
// "key": "ProjectRequests[0].Points",
// "value": "30",
// "type": "text"
// },
// {
// "key": "QuizRequests[0].Title",
// "value": "C# Basics Quiz",
// "type": "text"
// },
// {
// "key": "QuizRequests[0].Type",
// "value": "MCQ",
// "type": "text"
// },
// {
// "key": "QuizRequests[0].Points",
// "value": "10",
// "type": "text"
// },
// {
// "key": "QuizRequests[0].QuestionRequests[0].Text",
// "value": "What is C#?",
// "type": "text"
// },
// {
// "key": "QuizRequests[0].QuestionRequests[0].Type",
// "value": "MCQ",
// "type": "text"
// },
// {
// "key": "QuizRequests[0].QuestionRequests[0].OptionsJson",
// "value": "[\"Language\",\"Car\",\"Food\"]",
// "type": "text"
// },
// {
// "key": "QuizRequests[0].QuestionRequests[0].CorrectAnswer",
// "value": "Language",
// "type": "text"
// }
// ]
// },
// "url": {
// "raw": "{{baseUrl}}/api/Roadmaps",
// "host": [
// "{{baseUrl}}"
// ],
// "path": [
// "api",
// "Roadmaps"
// ]
// },
// "description": "Create a new roadmap with skills, learning materials, projects, and quizzes"
// },
// "response": []
// },
// {
// "name": "Get By Target Role",
// "request": {
// "method": "GET",
// "header": []
// },
// "response": []
// },
// {
// "name": "Search Roadmaps",
// "request": {
// "method": "GET",
// "header": []
// },
// "response": []
// },
// {
// "name": "Latest Roadmaps",
// "request": {
// "method": "GET",
// "header": [],
// "url": {
// "raw": "/api/Roadmaps/latest?count=10",
// "path": [
// "api",
// "Roadmaps",
// "latest"
// ],
// "query": [
// {
// "key": "count",
// "value": "10"
// }
// ]
// }
// },
// "response": []
// },
// {
// "name": "Top Roadmaps (by totalPoints)",
// "request": {
// "method": "GET",
// "header": []
// },
// "response": []
// },
// {
// "name": "Toggle Publish Status",
// "request": {
// "method": "GET",
// "header": []
// },
// "response": []
// },
// {
// "name": "Bulk Status Update",
// "request": {
// "method": "GET",
// "header": []
// },
// "response": []
// },
// {
// "name": "Delete Roadmap",
// "request": {
// "method": "GET",
// "header": []
// },
// "response": []
// }
// ]
// },
// {
// "name": "WorkShops",
// "item": [
// {
// "name": "Create Workshop",
// "event": [
// {
// "listen": "test",
// "script": {
// "exec": [
// "// Enhanced tests to handle both success and RFC7807 problem+json failure responses for Create Workshop",
// "",
// "// Content-Type should be JSON or problem+json depending on status",
// "pm.test(\"Response Content-Type is JSON or Problem+JSON appropriately\", function () {",
// "  pm.response.to.have.header(\"Content-Type\");",
// "  const ct = (pm.response.headers.get(\"Content-Type\") || \"\").toLowerCase();",
// "  if (pm.response.code >= 200 && pm.response.code < 300) {",
// "    pm.expect(ct).to.include(\"application/json\");",
// "  } else {",
// "    // Accept RFC 7807 content type for errors",
// "    pm.expect(ct).to.satisfy(v => v.includes(\"application/json\") || v.includes(\"application/problem+json\"));",
// "  }",
// "});",
// "",
// "let json = {};",
// "let rawText = pm.response.text();",
// "try { json = pm.response.json(); } catch (e) { json = {}; }",
// "",
// "pm.test(\"Status is 2xx or expected 4xx (validation)\", function () {",
// "  pm.expect([200,201,202,204,400,422]).to.include(pm.response.code);",
// "});",
// "",
// "// If success, validate WorkshopResponse shape",
// "pm.test(\"Success shape (if 2xx)\", function () {",
// "  if (pm.response.code >= 200 && pm.response.code < 300) {",
// "    pm.expect(json).to.be.an(\"object\");",
// "    pm.expect(json).to.have.property(\"id\").that.is.a(\"number\");",
// "    pm.expect(json).to.have.property(\"title\").that.is.a(\"string\");",
// "    pm.expect(json).to.have.property(\"description\").that.is.a(\"string\");",
// "    pm.expect(json).to.have.property(\"universityId\").that.is.a(\"number\");",
// "    pm.expect(json).to.have.property(\"location\").that.is.a(\"string\");",
// "    pm.expect(json).to.have.property(\"maxCapacity\").that.is.a(\"number\");",
// "    pm.expect(json).to.have.property(\"workshopType\").that.is.a(\"string\");",
// "    pm.expect(json).to.have.property(\"requireCV\").that.is.a(\"boolean\");",
// "    pm.expect(json).to.have.property(\"isPublished\").that.is.a(\"boolean\");",
// "    pm.expect(json).to.have.property(\"requireRoadmapCompletion\").that.is.a(\"boolean\");",
// "",
// "    if (Array.isArray(json.materials)) {",
// "      json.materials.forEach(m => {",
// "        pm.expect(m).to.have.property(\"id\").that.is.a(\"number\");",
// "        pm.expect(m).to.have.property(\"title\").that.is.a(\"string\");",
// "      });",
// "    }",
// "  }",
// "});",
// "",
// "// Failure handling: surface server error details clearly",
// "pm.test(\"Failure details (if non-2xx) include code and description\", function () {",
// "  if (!(pm.response.code >= 200 && pm.response.code < 300)) {",
// "    // Log raw text for debugging visibility",
// "    console.warn(\"Create Workshop failed. Raw response:\", rawText);",
// "",
// "    // If JSON, ensure it has expected properties",
// "    if (typeof json === 'object' && Object.keys(json).length) {",
// "      pm.expect(json).to.have.property(\"code\").that.is.a(\"string\");",
// "      pm.expect(json).to.have.property(\"description\").that.is.a(\"string\");",
// "    }",
// "  }",
// "});"
// ],
// "type": "text/javascript",
// "packages": {},
// "requests": {}
// }
// }
// ],
// "request": {
// "method": "POST",
// "header": [],
// "body": {
// "mode": "formdata",
// "formdata": [
// {
// "key": "Title",
// "value": "AI Career Bootcamp",
// "type": "text"
// },
// {
// "key": "Description",
// "value": "Learn AI and Machine Learning from scratch",
// "type": "text"
// },
// {
// "key": "UniversityId",
// "value": "1",
// "type": "text"
// },
// {
// "key": "Location",
// "value": "Online / Campus Hall, Building A",
// "type": "text"
// },
// {
// "key": "MaxCapacity",
// "value": "100",
// "type": "text"
// },
// {
// "key": "WorkshopType",
// "value": "Online",
// "type": "text"
// },
// {
// "key": "RequireCV",
// "value": "true",
// "type": "text"
// },
// {
// "key": "RequireRoadmapCompletion",
// "value": "false",
// "type": "text"
// },
// {
// "key": "IsPublished",
// "value": "true",
// "type": "text"
// },
// {
// "key": "StartDate",
// "value": "2025-01-15T09:00:00Z",
// "type": "text"
// },
// {
// "key": "EndDate",
// "value": "2025-01-17T17:00:00Z",
// "type": "text"
// },
// {
// "key": "Activities[0].Name",
// "value": "Build a Portfolio Website",
// "type": "text"
// },
// {
// "key": "Activities[0].Description",
// "value": "Create your professional",
// "type": "text"
// },
// {
// "key": "Activities[0].Difficulty",
// "value": "Easy",
// "type": "text"
// },
// {
// "key": "Activities[0].Points",
// "value": "10",
// "type": "text"
// },
// {
// "key": "Materials[0].Type",
// "value": "Video",
// "type": "text"
// },
// {
// "key": "Materials[0].TitleVideo",
// "value": "Introduction to AI",
// "type": "text"
// },
// {
// "key": "Materials[0].Duration",
// "value": "30",
// "type": "text"
// },
// {
// "key": "Materials[0].Points",
// "value": "10",
// "type": "text"
// },
// {
// "key": "Materials[0].FilePath",
// "type": "file",
// "src": "/E:/المنوعات/الصور/صوري/WhatsApp Video 2025-01-28 at 12.04.01_81bee27f.mp4"
// },
// {
// "key": "Materials[1].Type",
// "value": "PDF",
// "type": "text"
// },
// {
// "key": "Materials[1].TitlePdf",
// "value": "AI Basics PDF",
// "type": "text"
// },
// {
// "key": "Materials[1].Duration",
// "value": "15",
// "type": "text"
// },
// {
// "key": "Materials[1].Points",
// "value": "10",
// "type": "text"
// },
// {
// "key": "Materials[1].FilePath",
// "type": "file",
// "src": "/E:/cv.pdf"
// }
// ]
// },
// "url": {
// "raw": "https://localhost:7205/api/workshops",
// "protocol": "https",
// "host": [
// "localhost"
// ],
// "port": "7205",
// "path": [
// "api",
// "workshops"
// ]
// }
// },
// "response": []
// },
// {
// "name": "Update Workshop",
// "event": [
// {
// "listen": "test",
// "script": {
// "exec": [
// "// Enhanced tests to handle both success and RFC7807 problem+json failure responses for Create Workshop",
// "",
// "// Content-Type should be JSON or problem+json depending on status",
// "pm.test(\"Response Content-Type is JSON or Problem+JSON appropriately\", function () {",
// "  pm.response.to.have.header(\"Content-Type\");",
// "  const ct = (pm.response.headers.get(\"Content-Type\") || \"\").toLowerCase();",
// "  if (pm.response.code >= 200 && pm.response.code < 300) {",
// "    pm.expect(ct).to.include(\"application/json\");",
// "  } else {",
// "    // Accept RFC 7807 content type for errors",
// "    pm.expect(ct).to.satisfy(v => v.includes(\"application/json\") || v.includes(\"application/problem+json\"));",
// "  }",
// "});",
// "",
// "let json = {};",
// "let rawText = pm.response.text();",
// "try { json = pm.response.json(); } catch (e) { json = {}; }",
// "",
// "pm.test(\"Status is 2xx or expected 4xx (validation)\", function () {",
// "  pm.expect([200,201,202,204,400,422]).to.include(pm.response.code);",
// "});",
// "",
// "// If success, validate WorkshopResponse shape",
// "pm.test(\"Success shape (if 2xx)\", function () {",
// "  if (pm.response.code >= 200 && pm.response.code < 300) {",
// "    pm.expect(json).to.be.an(\"object\");",
// "    pm.expect(json).to.have.property(\"id\").that.is.a(\"number\");",
// "    pm.expect(json).to.have.property(\"title\").that.is.a(\"string\");",
// "    pm.expect(json).to.have.property(\"description\").that.is.a(\"string\");",
// "    pm.expect(json).to.have.property(\"universityId\").that.is.a(\"number\");",
// "    pm.expect(json).to.have.property(\"location\").that.is.a(\"string\");",
// "    pm.expect(json).to.have.property(\"maxCapacity\").that.is.a(\"number\");",
// "    pm.expect(json).to.have.property(\"workshopType\").that.is.a(\"string\");",
// "    pm.expect(json).to.have.property(\"requireCV\").that.is.a(\"boolean\");",
// "    pm.expect(json).to.have.property(\"isPublished\").that.is.a(\"boolean\");",
// "    pm.expect(json).to.have.property(\"requireRoadmapCompletion\").that.is.a(\"boolean\");",
// "",
// "    if (Array.isArray(json.materials)) {",
// "      json.materials.forEach(m => {",
// "        pm.expect(m).to.have.property(\"id\").that.is.a(\"number\");",
// "        pm.expect(m).to.have.property(\"title\").that.is.a(\"string\");",
// "      });",
// "    }",
// "  }",
// "});",
// "",
// "// Failure handling: surface server error details clearly",
// "pm.test(\"Failure details (if non-2xx) include code and description\", function () {",
// "  if (!(pm.response.code >= 200 && pm.response.code < 300)) {",
// "    // Log raw text for debugging visibility",
// "    console.warn(\"Create Workshop failed. Raw response:\", rawText);",
// "",
// "    // If JSON, ensure it has expected properties",
// "    if (typeof json === 'object' && Object.keys(json).length) {",
// "      pm.expect(json).to.have.property(\"code\").that.is.a(\"string\");",
// "      pm.expect(json).to.have.property(\"description\").that.is.a(\"string\");",
// "    }",
// "  }",
// "});"
// ],
// "type": "text/javascript",
// "packages": {},
// "requests": {}
// }
// }
// ],
// "request": {
// "method": "POST",
// "header": [],
// "body": {
// "mode": "formdata",
// "formdata": [
// {
// "key": "Title",
// "value": "AI Career Bootcamp",
// "type": "text"
// },
// {
// "key": "Description",
// "value": "Learn AI and Machine Learning from scratch",
// "type": "text"
// },
// {
// "key": "UniversityId",
// "value": "1",
// "type": "text"
// },
// {
// "key": "Location",
// "value": "Online / Campus Hall, Building A",
// "type": "text"
// },
// {
// "key": "MaxCapacity",
// "value": "100",
// "type": "text"
// },
// {
// "key": "WorkshopType",
// "value": "Online",
// "type": "text"
// },
// {
// "key": "RequireCV",
// "value": "true",
// "type": "text"
// },
// {
// "key": "RequireRoadmapCompletion",
// "value": "false",
// "type": "text"
// },
// {
// "key": "IsPublished",
// "value": "true",
// "type": "text"
// },
// {
// "key": "StartDate",
// "value": "2025-01-15T09:00:00Z",
// "type": "text"
// },
// {
// "key": "EndDate",
// "value": "2025-01-17T17:00:00Z",
// "type": "text"
// },
// {
// "key": "Activities[0].Name",
// "value": "Build a Portfolio Website",
// "type": "text"
// },
// {
// "key": "Activities[0].Description",
// "value": "Create your professional",
// "type": "text"
// },
// {
// "key": "Activities[0].Difficulty",
// "value": "Easy",
// "type": "text"
// },
// {
// "key": "Activities[0].Points",
// "value": "10",
// "type": "text"
// },
// {
// "key": "Materials[0].Type",
// "value": "Video",
// "type": "text"
// },
// {
// "key": "Materials[0].TitleVideo",
// "value": "Introduction to AI",
// "type": "text"
// },
// {
// "key": "Materials[0].Duration",
// "value": "30",
// "type": "text"
// },
// {
// "key": "Materials[0].Points",
// "value": "10",
// "type": "text"
// },
// {
// "key": "Materials[0].FilePath",
// "type": "file",
// "src": "/E:/المنوعات/الصور/صوري/WhatsApp Video 2025-01-28 at 12.04.01_81bee27f.mp4"
// },
// {
// "key": "Materials[1].Type",
// "value": "PDF",
// "type": "text"
// },
// {
// "key": "Materials[1].TitlePdf",
// "value": "AI Basics PDF",
// "type": "text"
// },
// {
// "key": "Materials[1].Duration",
// "value": "15",
// "type": "text"
// },
// {
// "key": "Materials[1].Points",
// "value": "10",
// "type": "text"
// },
// {
// "key": "Materials[1].FilePath",
// "type": "file",
// "src": "/E:/cv.pdf"
// }
// ]
// },
// "url": {
// "raw": "https://localhost:7205/api/workshops",
// "protocol": "https",
// "host": [
// "localhost"
// ],
// "port": "7205",
// "path": [
// "api",
// "workshops"
// ]
// }
// },
// "response": []
// },
// {
// "name": "Get Workshop By Id",
// "request": {
// "method": "GET",
// "header": []
// },
// "response": []
// },
// {
// "name": "Get All Workshops",
// "request": {
// "method": "GET",
// "header": []
// },
// "response": []
// },
// {
// "name": "Toggle Published Status",
// "request": {
// "method": "GET",
// "header": []
// },
// "response": []
// },
// {
// "name": "Bulk Status Update",
// "request": {
// "method": "GET",
// "header": []
// },
// "response": []
// },
// {
// "name": "Delete Workshop",
// "request": {
// "method": "GET",
// "header": []
// },
// "response": []
// },
// {
// "name": "Bulk Delete",
// "request": {
// "method": "GET",
// "header": []
// },
// "response": []
// }
// ]
// },
// {
// "name": "Jobs",
// "item": [
// {
// "name": "Get Job by ID",
// "request": {
// "method": "GET",
// "header": []
// },
// "response": []
// },
// {
// "name": "Get All Jobs",
// "request": {
// "method": "GET",
// "header": [],
// "url": {
// "raw": "http://smartcareerhub.runasp.net/api/Jobs",
// "protocol": "http",
// "host": [
// "smartcareerhub",
// "runasp",
// "net"
// ],
// "path": [
// "api",
// "Jobs"
// ]
// }
// },
// "response": []
// },
// {
// "name": "Search Jobs",
// "request": {
// "method": "GET",
// "header": []
// },
// "response": []
// },
// {
// "name": "Get by Job Type",
// "request": {
// "method": "GET",
// "header": []
// },
// "response": []
// },
// {
// "name": "Get by Experience Level",
// "request": {
// "method": "GET",
// "header": []
// },
// "response": []
// },
// {
// "name": "Get by Location",
// "request": {
// "method": "GET",
// "header": []
// },
// "response": []
// },
// {
// "name": "Get Latest Jobs",
// "request": {
// "method": "GET",
// "header": []
// },
// "response": []
// },
// {
// "name": "Get Jobs Count",
// "request": {
// "method": "GET",
// "header": []
// },
// "response": []
// },
// {
// "name": "Create",
// "request": {
// "method": "POST",
// "header": [],
// "body": {
// "mode": "formdata",
// "formdata": [
// {
// "key": "Title",
// "value": "Senior Frontend Developer",
// "type": "text"
// },
// {
// "key": "Description",
// "value": "We are looking for an experienced Frontend Developer to join our team...",
// "type": "text"
// },
// {
// "key": "RequiredSkills",
// "value": "React, TypeScript, Next.js, Tailwind CSS",
// "type": "text"
// },
// {
// "key": "ExperienceLevel",
// "value": "Senior Level",
// "type": "text"
// },
// {
// "key": "JobType",
// "value": "Hybrid",
// "type": "text"
// },
// {
// "key": "Location",
// "value": "Cairo, Egypt",
// "type": "text"
// },
// {
// "key": "SalaryRange",
// "value": "$40,000 - $60,000",
// "type": "text"
// },
// {
// "key": "CompanyLogo",
// "type": "file",
// "src": "/E:/المنوعات/الصور/صوري/IMG-20240622-WA0005.jpg"
// }
// ]
// },
// "url": {
// "raw": "https://localhost:7205/api/jobs",
// "protocol": "https",
// "host": [
// "localhost"
// ],
// "port": "7205",
// "path": [
// "api",
// "jobs"
// ]
// }
// },
// "response": []
// },
// {
// "name": "Update Job",
// "request": {
// "method": "POST",
// "header": [],
// "body": {
// "mode": "formdata",
// "formdata": [
// {
// "key": "Title",
// "value": "Senior Frontend Developer",
// "type": "text"
// },
// {
// "key": "Description",
// "value": "We are looking for an experienced Frontend Developer to join our team...",
// "type": "text"
// },
// {
// "key": "RequiredSkills",
// "value": "React, TypeScript, Next.js, Tailwind CSS",
// "type": "text"
// },
// {
// "key": "ExperienceLevel",
// "value": "Senior Level",
// "type": "text"
// },
// {
// "key": "JobType",
// "value": "Hybrid",
// "type": "text"
// },
// {
// "key": "Location",
// "value": "Cairo, Egypt",
// "type": "text"
// },
// {
// "key": "SalaryRange",
// "value": "$40,000 - $60,000",
// "type": "text"
// },
// {
// "key": "CompanyLogo",
// "type": "file",
// "src": "/E:/المنوعات/الصور/صوري/IMG-20240622-WA0005.jpg"
// }
// ]
// },
// "url": {
// "raw": "https://localhost:7205/api/jobs",
// "protocol": "https",
// "host": [
// "localhost"
// ],
// "port": "7205",
// "path": [
// "api",
// "jobs"
// ]
// }
// },
// "response": []
// },
// {
// "name": "Delete",
// "request": {
// "method": "GET",
// "header": []
// },
// "response": []
// },
// {
// "name": "Bulk Delete",
// "request": {
// "method": "GET",
// "header": []
// },
// "response": []
// }
// ]
// },
// {
// "name": "Interview",
// "item": [
// {
// "name": "CreateInterviews",
// "request": {
// "method": "GET",
// "header": []
// },
// "response": []
// },
// {
// "name": "Update Interview",
// "request": {
// "method": "GET",
// "header": []
// },
// "response": []
// },
// {
// "name": "Get All Interviews",
// "request": {
// "method": "GET",
// "header": []
// },
// "response": []
// },
// {
// "name": "Get Interview By ID",
// "request": {
// "method": "GET",
// "header": []
// },
// "response": []
// },
// {
// "name": "Delete Interview",
// "request": {
// "method": "GET",
// "header": []
// },
// "response": []
// },
// {
// "name": "Get Today’s Interviews",
// "request": {
// "method": "GET",
// "header": []
// },
// "response": []
// },
// {
// "name": "Get Interviews by Roadmap",
// "request": {
// "method": "GET",
// "header": []
// },
// "response": []
// },
// {
// "name": "Search Interviews",
// "request": {
// "method": "GET",
// "header": []
// },
// "response": []
// },
// {
// "name": "Update Interview Status",
// "request": {
// "method": "GET",
// "header": []
// },
// "response": []
// },
// {
// "name": "Bulk Update Interview Status",
// "request": {
// "method": "GET",
// "header": []
// },
// "response": []
// },
// {
// "name": "Get Total Count",
// "request": {
// "method": "GET",
// "header": []
// },
// "response": []
// },
// {
// "name": "Get Today Count",
// "request": {
// "method": "GET",
// "header": []
// },
// "response": []
// },
// {
// "name": "Get Latest Interviews",
// "request": {
// "method": "GET",
// "header": []
// },
// "response": []
// },
// {
// "name": "Bulk Delete",
// "request": {
// "method": "GET",
// "header": []
// },
// "response": []
// }
// ]
// },
// {
// "name": "Event",
// "item": [
// {
// "name": "Create",
// "request": {
// "method": "POST",
// "header": [],
// "body": {
// "mode": "formdata",
// "formdata": [
// {
// "key": "Title",
// "value": "AI Career Bootcamp",
// "type": "text"
// },
// {
// "key": "Description",
// "value": "Learn AI basics and career path",
// "type": "text"
// },
// {
// "key": "Banner",
// "type": "file",
// "src": "/E:/المنوعات/الصور/صوري/IMG-20240622-WA0005.jpg"
// },
// {
// "key": "EventType",
// "value": "Workshop ",
// "type": "text"
// },
// {
// "key": "Mode",
// "value": "Hybrid",
// "type": "text"
// },
// {
// "key": "StartDate",
// "value": "2025-12-01",
// "type": "text"
// },
// {
// "key": "EndDate",
// "value": "2025-12-15",
// "type": "text"
// },
// {
// "key": "StartTime",
// "value": "10:00:00",
// "type": "text"
// },
// {
// "key": "EndTime",
// "value": "18:00:00",
// "type": "text"
// },
// {
// "key": "MinimumRequiredPoints",
// "value": "50",
// "type": "text"
// },
// {
// "key": "CompletedRoadmap",
// "value": "true",
// "type": "text"
// },
// {
// "key": "Completed50PercentCourses",
// "value": "true",
// "type": "text"
// },
// {
// "key": "HighCommunicationSkills",
// "value": "true",
// "type": "text"
// },
// {
// "key": "HighTechnicalSkills",
// "value": "true",
// "type": "text"
// },
// {
// "key": "Top30PercentProgress",
// "value": "true",
// "type": "text"
// },
// {
// "key": "InviteOnlyEligibleStudents",
// "value": "true",
// "type": "text"
// },
// {
// "key": "MaxCapacity",
// "value": "50",
// "type": "text"
// },
// {
// "key": "AllowWaitingList",
// "value": "true",
// "type": "text"
// },
// {
// "key": "SendAutoEmailToEligibleStudents",
// "value": "true",
// "type": "text"
// },
// {
// "key": "PointsForAttendance",
// "value": "5",
// "type": "text"
// },
// {
// "key": "PointsForFullParticipation",
// "value": "10",
// "type": "text"
// },
// {
// "key": "IsPublished",
// "value": "true",
// "type": "text"
// }
// ]
// },
// "url": {
// "raw": "https://localhost:7205/api/events",
// "protocol": "https",
// "host": [
// "localhost"
// ],
// "port": "7205",
// "path": [
// "api",
// "events"
// ]
// }
// },
// "response": []
// },
// {
// "name": "Update Event",
// "request": {
// "method": "POST",
// "header": [],
// "body": {
// "mode": "formdata",
// "formdata": [
// {
// "key": "Title",
// "value": "AI Career Bootcamp",
// "type": "text"
// },
// {
// "key": "Description",
// "value": "Learn AI basics and career path",
// "type": "text"
// },
// {
// "key": "Banner",
// "type": "file",
// "src": "/E:/المنوعات/الصور/صوري/IMG-20240622-WA0005.jpg"
// },
// {
// "key": "EventType",
// "value": "Workshop ",
// "type": "text"
// },
// {
// "key": "Mode",
// "value": "Hybrid",
// "type": "text"
// },
// {
// "key": "StartDate",
// "value": "2025-12-01",
// "type": "text"
// },
// {
// "key": "EndDate",
// "value": "2025-12-15",
// "type": "text"
// },
// {
// "key": "StartTime",
// "value": "10:00:00",
// "type": "text"
// },
// {
// "key": "EndTime",
// "value": "18:00:00",
// "type": "text"
// },
// {
// "key": "MinimumRequiredPoints",
// "value": "50",
// "type": "text"
// },
// {
// "key": "CompletedRoadmap",
// "value": "true",
// "type": "text"
// },
// {
// "key": "Completed50PercentCourses",
// "value": "true",
// "type": "text"
// },
// {
// "key": "HighCommunicationSkills",
// "value": "true",
// "type": "text"
// },
// {
// "key": "HighTechnicalSkills",
// "value": "true",
// "type": "text"
// },
// {
// "key": "Top30PercentProgress",
// "value": "true",
// "type": "text"
// },
// {
// "key": "InviteOnlyEligibleStudents",
// "value": "true",
// "type": "text"
// },
// {
// "key": "MaxCapacity",
// "value": "50",
// "type": "text"
// },
// {
// "key": "AllowWaitingList",
// "value": "true",
// "type": "text"
// },
// {
// "key": "SendAutoEmailToEligibleStudents",
// "value": "true",
// "type": "text"
// },
// {
// "key": "PointsForAttendance",
// "value": "5",
// "type": "text"
// },
// {
// "key": "PointsForFullParticipation",
// "value": "10",
// "type": "text"
// },
// {
// "key": "IsPublished",
// "value": "true",
// "type": "text"
// }
// ]
// },
// "url": {
// "raw": "https://localhost:7205/api/events",
// "protocol": "https",
// "host": [
// "localhost"
// ],
// "port": "7205",
// "path": [
// "api",
// "events"
// ]
// }
// },
// "response": []
// },
// {
// "name": "Get Event by ID",
// "request": {
// "method": "GET",
// "header": []
// },
// "response": []
// },
// {
// "name": "Get All Events",
// "request": {
// "method": "GET",
// "header": []
// },
// "response": []
// },
// {
// "name": "Get Published Events",
// "request": {
// "method": "GET",
// "header": []
// },
// "response": []
// },
// {
// "name": "Search Events",
// "request": {
// "method": "GET",
// "header": []
// },
// "response": []
// },
// {
// "name": "Get Latest Events",
// "request": {
// "method": "GET",
// "header": []
// },
// "response": []
// },
// {
// "name": "Toggle Event Publish Status",
// "request": {
// "method": "GET",
// "header": []
// },
// "response": []
// },
// {
// "name": "Bulk Status Update",
// "request": {
// "method": "GET",
// "header": []
// },
// "response": []
// },
// {
// "name": "Delete Event",
// "request": {
// "method": "GET",
// "header": []
// },
// "response": []
// },
// {
// "name": "Bulk Delete",
// "request": {
// "method": "GET",
// "header": []
// },
// "response": []
// }
// ]
// },
// {
// "name": "Analytics",
// "item": [
// {
// "name": "Dashboard Overview",
// "request": {
// "method": "GET",
// "header": []
// },
// "response": []
// },
// {
// "name": "Roadmaps Analytics",
// "request": {
// "method": "GET",
// "header": []
// },
// "response": []
// },
// {
// "name": "Workshops Analytics",
// "request": {
// "method": "GET",
// "header": []
// },
// "response": []
// },
// {
// "name": "Events Analytics",
// "request": {
// "method": "GET",
// "header": []
// },
// "response": []
// },
// {
// "name": "Jobs Analytics",
// "request": {
// "method": "GET",
// "header": []
// },
// "response": []
// },
// {
// "name": "Interviews Analytics",
// "request": {
// "method": "GET",
// "header": []
// },
// "response": []
// }
// ]
// }
// ]
// }
// ]
// }