Problem Statement

There is a clear and growing gap between academic education and real market needs, which leads to several challenges in the employment ecosystem.

 Key Problems:
There is a gap between academic education and real market requirements.
Lack of integrated youth training and career development systems.
High youth unemployment and skill mismatch in the job market.
Weak connection between graduates, universities, training centers, and companies.
Absence of a unified platform that connects all stakeholders in one ecosystem.
 Stakeholders Challenges
Undergraduates

Struggle to find relevant internships and job opportunities due to:

Lack of career guidance
Limited access to real employers
Weak awareness of market needs
Graduates

Face difficulties entering the workforce because of:

Skill gaps between education and industry requirements
Lack of professional networking channels
No structured career transition support
Training Centers
Lack a centralized platform to reach potential trainees
Difficulty aligning courses with labor market demands
Limited visibility to target audiences
Universities
Weak connection with industry and companies
Limited practical exposure for students
Reduced employability outcomes for graduates
Companies
Difficulty finding qualified candidates efficiently
Lack of reliable skill assessment before hiring
Time-consuming recruitment processes
 Core Problem Summary

All stakeholders are disconnected within fragmented systems, which creates inefficiency in career development, hiring, and training processes.

This highlights the need for a centralized, intelligent platform that connects education with the labor market — which is exactly what Smart Career Hub aims to solve.
------------------------------------------------------------------------------------------------------------------------------------------------------------------
Proposed Solution in Our Platform

Smart Career Hub

Smart Career Hub is an integrated AI-powered platform designed to connect students, graduates, companies, training centers, and universities in one unified ecosystem.

 Full Integration Across Users

The platform connects all stakeholders in a single system:

Students & Graduates
Companies
Training Centers
Universities
 Core Platform Features
 Interactive Dashboard
Personalized dashboard for each user role
Clear view of progress, jobs, RoadMap, and applications

Training Center & Company Management :
Companies can publish Roadmab , internship , workshops,  events job roles and career tracks.
Training centers can publish courses and manage learners.
Direct connection between education and labor market.

Universities:
Integration between company management to regulate workshops and events .

The system uses AI to:
AI-Powered Career Guidance
Analyze user skills 
Recommend the most suitable career path
Suggest relevant courses and training programs

 The model helps users identify the right career direction and start learning effectively.
 <img width="721" height="542" alt="image" src="https://github.com/user-attachments/assets/8ce5a3f6-9d76-45c5-a974-d8a0af4e98df" />

AI Learning Validation Engine

A smart system designed to:

Verify real understanding of learning materials
Ensure users actually study roadmap content
Prevent random skipping of content
Evaluate user responses semantically

 This ensures quality learning, not just course completion.
 <img width="866" height="904" alt="image" src="https://github.com/user-attachments/assets/c37faabd-641c-4764-bed6-bfe93ba74eae" />

---------------------------------------------------------------------------------------------------------------------------------------------------------------
System Analysis:
Stakeholders : Companies , Under Graduates , Graduates , Universities  and Training Center.

System Requirements :
Functional Requirements:
The Smart Career Hub system provides the following functionalities:

 User Management
Users can register and log in securely.
Role-based access control (Student, Graduate, Company, Training Center, University).
Users can create, update, and manage their profiles.

 Student & Graduate Profile System
Each Student and Graduate has a full professional profile.
Profile includes: skills, education, certifications, and achievements.
Track all career activities in one place.

 Career Roadmap Tracking
Follow structured career roadmaps step-by-step.
Track progress automatically.
Store completed milestones in the profile.

 Job Application Process
Apply for job opportunities through the system.
Track application status (Pending / Accepted / Rejected).
Store full job application history.

 Internship Process
Apply for internships through the platform.
Track internship status and progress.
Add internship experience to profile after completion.

 Career Management
View and follow company-created career roadmaps.
Receive AI-based career recommendations.
Track skill development over time.

 Job Management
Companies can post job opportunities.
Users can apply and track applications.
Companies can review and manage applicants.
 Training Management
Training centers can publish courses .
Users can enroll and complete courses.
Track learning progress.

 Events, Workshops & Interview Management
Companies and Universities can create events and workshops.
Users can register and attend events (online/offline).
Events are tracked and added to user profile.

 Interview Process (After Roadmap Completion)
Users become eligible for jobs/internships after completing roadmaps.
Companies can invite candidates for interviews.
Interviews are scheduled through the system.
Interview results are recorded and linked to applications.

Non-Functional Requirements:

Performance
System supports multiple concurrent users.
 API response time.
Optimized database queries for scalability.

 Security
Secure authentication using JWT.
Role-based authorization.
Protection of user data .
Secure API endpoints against unauthorized access.

 Scalability
Modular 3-layer architecture.
System can support future growth (users, features, services).
AI components can scale independently.

 Maintainability
Separation of layers (API / Business / DataAccess).
Clean and reusable code structure.
Easy to extend or modify features.

 Usability
Simple and intuitive UI/UX.
Easy navigation for all user roles.
Responsive design for web and mobile.

 Reliability
High system availability.
Proper error handling and logging.
Data consistency and integrity across system.

 Interoperability
System supports integration with AI services.
Can be extended to mobile applications and external APIs.
------------------------------------------------------------------------------------------------------------------------------------------------------------------
System Architecture:
 1. Client Layer (Frontend Layer)

This layer represents the user interfaces of the system:

 Web Application
 Mobile Application (Flutter)

Responsibilities:

User interaction
Sending requests to backend APIs
Displaying data and dashboards
 2. Backend Layer (API Layer)

Built using ASP.NET Core Web API

Responsibilities:

Handle all requests from Web & Mobile
Authentication & Authorization (JWT)
Business logic processing (via Business Layer)
Communication with database and AI services

3. Business Layer
Core system logic
Career roadmap management
Job & internship logic
AI integration handling

 5. Data Access Layer
Entity Framework Core
Database operations (CRUD)
SQL Server interaction

 7. AI Services Layer
Career Recommendation Model
Skill Gap Detection Model
Learning Validation Model

 System Flow
User interacts via Web or Mobile App
Request sent to Backend API
Business Layer processes logic
Data Access Layer interacts with Database
AI Services run when needed
Response returned to Client
---------------------------------------------------------------------------------------------------------------------------------------------------------------
Use Cases Diagram : <img width="11370" height="10431" alt="Use case overview Diagram drawio" src="https://github.com/user-attachments/assets/305ff33c-802f-4b08-b865-163281dec1c0" />
Context Diagram : 
<img width="654" height="651" alt="Context Diagram-1 drawio" src="https://github.com/user-attachments/assets/0de67f88-e4a3-4e9e-a265-6fc85be9b8af" />

state diagram :<img width="640" height="2001" alt="statediagram drawio" src="https://github.com/user-attachments/assets/f9f3343a-3497-4f9f-8122-fd5fd06d898f" />

Sequence company Roadmap: <img width="686" height="393" alt="companyRoadmap drawio" src="https://github.com/user-attachments/assets/60bb7e0a-6b2d-4448-b038-dea79e6a6909" />

Sequence Student and Graduates ApplyRoadmap : <img width="754" height="504" alt="StudentGrad ApplyRoadmap drawio" src="https://github.com/user-attachments/assets/36aac56d-3fc7-4e96-94ee-32bf97871cd7" />

Container Diagram For Smart Carrer Hub : 
<img width="14043" height="8140" alt="Container Diagram drawio" src="https://github.com/user-attachments/assets/96d8f750-1c64-4a82-852a-951394a9acb0" />

----------------------------------------------------------------------------------------------------------------------------------------------------------------
AI Models : Career Recommendation Model
Skill Gap Detection
<img width="721" height="542" alt="image" src="https://github.com/user-attachments/assets/0246bda0-ceb8-401f-8174-8cf63a63c57a" />

Learning Validation Model
<img width="866" height="904" alt="image" src="https://github.com/user-attachments/assets/42c38044-4c44-43ef-b03c-b99645347d14" />

--------------------------------------------------------------------------------------------------------------------------------------------------------------------
Features / Modules

Career Roadmaps
Job & Internship System
Training System
Events & Workshops
AI Assistant
Progress Tracking
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
Database Design : 
<img width="5495" height="5215" alt="ERD 3 drawio" src="https://github.com/user-attachments/assets/0cb2536e-1397-405a-9474-3da76c17792f" />
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Tech Stack
ASP.NET Core
EF Core
SQL Server
JWT Authentication
AI Services 
Flutter (Mobile App)

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Testing
Unit Testing
Integration Testing
Security Testing
Performance Testing
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

API Examples :
Roadmaps APIs

GET /api/roadmaps
GET /api/roadmaps/published
GET /api/roadmaps/search?keyword={keyword}
GET /api/roadmaps/targetrole/{role}
GET /api/roadmaps/latest
GET /api/roadmaps/top
GET /api/roadmaps/{id}
GET /api/roadmaps/{id}/details

POST /api/roadmaps
PUT /api/roadmaps/{id}
PATCH /api/roadmaps/toggle/{id}
PATCH /api/roadmaps/bulkstatus
DELETE /api/roadmaps/{id}
DELETE /api/roadmaps/bulkdelete

 AI Quiz APIs

GET /api/roadmaps/{roadmapId}/quizzes
GET /api/roadmaps/{roadmapId}/quizzes/{quizId}
POST /api/roadmaps/{roadmapId}/quizzes
PUT /api/roadmaps/quizzes/{quizId}
DELETE /api/roadmaps/quizzes/{quizId}

POST /api/roadmaps/{roadmapId}/generate-quiz?quizType=MCQ&numQuestions=5
GET /api/roadmaps/{roadmapId}/generated-quiz
GET /api/roadmaps/job-status/{jobId}

 Profile APIs

GET /api/profile/summary
GET /api/profile/public/{userId}
PUT /api/profile/update

 Jobs APIs

GET /api/jobs
GET /api/jobs/{id}
GET /api/jobs/search?keyword={keyword}
GET /api/jobs/type/{jobType}
GET /api/jobs/level/{experienceLevel}
GET /api/jobs/location/{location}
GET /api/jobs/latest
GET /api/jobs/count
GET /api/jobs/{id}/applicants
GET /api/jobs/my-applications

POST /api/jobs
POST /api/jobs/{id}/apply

PUT /api/jobs/{id}
PATCH /api/jobs/{jobId}/applicants/{applicationId}/status

DELETE /api/jobs/{id}
DELETE /api/jobs/bulkdelete

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Future Work
 Future Vision

The Smart Career Hub platform is designed to continuously evolve into a scalable, intelligent, and enterprise-level career ecosystem. Future development will focus on improving scalability, AI capabilities, and system flexibility to better serve all stakeholders.

 AI Enhancements
Integration of advanced Artificial Intelligence for deeper user analysis
Behavioral and soft skills assessment using AI models
Analysis of user interactions, performance, and engagement
More accurate and personalized career recommendations
Improved learning and career prediction systems

Microservices Architecture Migration

The system will evolve from a monolithic structure into a Microservices Architecture, where core modules will be separated into independent services such as:

Authentication Service
Jobs Service
Courses Service
Notifications Service
Payments Service

 Benefits:
Improved scalability and performance
Independent deployment of services
Better maintainability
Support for Docker & Kubernetes
Ability to handle large-scale user growth

 Multi-Tenant System (SaaS Model)

The platform will support a multi-tenant architecture, allowing each company to operate in its own isolated environment.

Features:
Dedicated company dashboards
Custom branding (logos, colors, domains)
Separate analytics and reports per company
Internal HR role management
Isolated data per organization

 This will transform the system into a SaaS (Software-as-a-Service) product.

 Dynamic Workflow Engine

A flexible workflow system will be introduced to allow companies to customize their own recruitment pipelines.

Example Workflow Stages:
Screening
Technical Assessment
HR Interview
Final Evaluation
Offer Stage
Benefits:
Fully customizable hiring process
Adaptable to different company strategies
Improved recruitment efficiency
Better candidate evaluation flow

 Summary

Future development of Smart Career Hub aims to transform the platform into a fully intelligent, scalable, and enterprise-ready career ecosystem that adapts to the needs of both users and organizations.











