// Phone number validation
function validatePhone(input) {
    const phoneNumber = input.value.replace(/\D/g, ''); // Remove non-digits
    const phoneError = document.getElementById('phoneError');
    
    if (phoneNumber.length !== 10) {
        input.classList.add('is-invalid');
        phoneError.textContent = 'Số điện thoại phải đủ 10 số';
        phoneError.style.display = 'block';
        return false;
    } else {
        input.classList.remove('is-invalid');
        phoneError.style.display = 'none';
        return true;
    }
}

// Date and time validation
function validateDateTime() {
    const dateInput = document.getElementById('reservation_date');
    const timeInput = document.getElementById('reservation_time');
    const today = new Date();
    const selectedDate = new Date(dateInput.value);
    
    // Reset min date on validation to ensure it's always current
    dateInput.min = today.toISOString().split('T')[0];
    
    // If selected date is today, validate time
    if (selectedDate.toDateString() === today.toDateString()) {
        const currentHour = today.getHours();
        const timeOptions = timeInput.options;
        
        // Disable past times for today
        for (let i = 1; i < timeOptions.length; i++) {
            const optionTime = timeOptions[i].value.split(':');
            const optionHour = parseInt(optionTime[0]);
            const optionMinute = parseInt(optionTime[1]);
            
            if (optionHour < currentHour + 2 || 
                (optionHour === currentHour + 2 && optionMinute <= today.getMinutes())) {
                timeOptions[i].disabled = true;
            } else {
                timeOptions[i].disabled = false;
            }
        }
    } else {
        // Enable all times for future dates
        const timeOptions = timeInput.options;
        for (let i = 1; i < timeOptions.length; i++) {
            timeOptions[i].disabled = false;
        }
    }
    
    // If time was selected before but now invalid, reset it
    if (timeInput.selectedIndex > 0 && timeInput.options[timeInput.selectedIndex].disabled) {
        timeInput.selectedIndex = 0;
    }
}

// Initialize validation on page load
document.addEventListener('DOMContentLoaded', function() {
    validateDateTime();
});