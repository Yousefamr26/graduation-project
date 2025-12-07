function goLogin() {
    window.location.href = "login.html";
}

function goRegister() {
    window.location.href = "register.html";
}

function login() {
    const type = document.getElementById("accountType").value;
    const email = document.getElementById("email").value.trim();
    const password = document.getElementById("password").value.trim();

    if (!type) return alert("Please select account type");
    if (!email) return alert("Email / Username is required");
    if (!password) return alert("Password is required");

    alert("Logging in...");
}

/* ---------------- Page Navigation ---------------- */

function goToForgot() {
    window.location.href = "forget-password.html";
}

function goBackToLogin() {
    window.location.href = "login.html";
}

function sendOTP() {
    window.location.href = "otp.html";
}

function goBackToForgot() {
    window.location.href = "forget-password.html";
}

function goBackToOTP() {
    window.location.href = "otp.html";
}


/* ---------------- OTP Verification ---------------- */

// Example valid OTP = 123456
const correctOTP = "123456";

function verifyOTP() {
    let entered =
        document.getElementById("d1").value +
        document.getElementById("d2").value +
        document.getElementById("d3").value +
        document.getElementById("d4").value +
        document.getElementById("d5").value +
        document.getElementById("d6").value;

    if (entered === correctOTP) {
        window.location.href = "new-password.html";
    } else {
        document.getElementById("otpError").innerText =
            "Please enter a valid 6-digit code";
    }
}


/* ---------------- Save New Password ---------------- */

function savePassword() {
    const newPass = document.getElementById("newPassword").value;
    const confirmPass = document.getElementById("confirmPassword").value;

    if (newPass === "" || confirmPass === "") {
        alert("Please fill in both fields.");
        return;
    }

    if (newPass !== confirmPass) {
        alert("Passwords do not match.");
        return;
    }

    document.getElementById("successMsg").style.display = "block";

    setTimeout(() => {
        alert("Password changed successfully!");
        window.location.href = "login.html";
    }, 1500);
}


const tabs = document.querySelectorAll(".tab");
const forms = document.querySelectorAll(".form");

tabs.forEach(tab => {
    tab.addEventListener("click", () => {
        
        tabs.forEach(t => t.classList.remove("active"));
        tab.classList.add("active");

        forms.forEach(f => f.classList.remove("active"));
        document.getElementById(tab.dataset.form).classList.add("active");
    });
});


    const menuIcon = document.querySelector(".menu-icon");
    const menuList = document.querySelector(".menu-list");

    menuIcon.addEventListener('click', function () {
        if (menuList.style.display === 'block') {
            menuList.style.display = 'none';
        } else {
            menuList.style.display = 'block';
        }
    });

function goLogout() {
    window.location.href = "login.html";
}

function goProfile() {
    window.location.href = "profile-company.html";
}

function goCalender() {
    window.location.href = "calender-company.html";
}

function goNotification() {
    window.location.href = "notiifi-company.html";
}

function goJobs() {
    window.location.href = "job-company.html";
}

function goWorkshop() {
    window.location.href = "workshop-company.html";
}

function goEvent() {
    window.location.href = "event-company.html";
}

function goRoadmap() {
    window.location.href = "Roadmap-com.html";
}

function goInterview() {
    window.location.href = "interview-company.html";
}

function goCreateroadmap() {
    window.location.href = "create-roadmap.html";
}

function goAnalytics() {
    window.location.href = "analytics-company.html";
}


function goCreateworkshop() {
    window.location.href = "create-workshop.html";
}

function goCreateevent() {
    window.location.href = "create-event.html";
}



