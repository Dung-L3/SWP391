// Phone number validation
function validatePhone(input) {
    // Remove non-digits and update the input value so letters are not kept
    let phoneNumber = input.value.replace(/\D/g, ''); // loại bỏ ký tự không phải số
    // Enforce max length 10
    if (phoneNumber.length > 10) phoneNumber = phoneNumber.slice(0, 10);
    if (input.value !== phoneNumber) {
        // write cleaned value back so letters disappear immediately as user types/pastes
        input.value = phoneNumber; // Ghi giá trị đã dọn trở lại ô nhập để chữ cái biến mất ngay khi người dùng gõ/paste
    }
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
    // Đặt lại giá trị min của ô ngày để luôn là ngày hiện tại
    dateInput.min = today.toISOString().split('T')[0];

    // Rebuild time select options from cached master list so we can remove
    // unavailable times (not only disable). This makes options before
    // now+2h invisible to the user when choosing today's date.
    if (!window.__booking_time_options) { 
        // Lưu trữ các option gốc (bao gồm placeholder ở vị trí 0)
        window.__booking_time_options = Array.from(timeInput.options).map(o => ({ value: o.value, text: o.text }));
    }

    // Helper to parse "HH:mm[:ss]" into a Date on selectedDate
    function optionDateFor(optionValue, baseDate) {
        const parts = optionValue.split(':');
        const hh = parseInt(parts[0] || '0', 10);
        const mm = parseInt(parts[1] || '0', 10);
        const ss = parseInt(parts[2] || '0', 10);
        const d = new Date(baseDate.getFullYear(), baseDate.getMonth(), baseDate.getDate(), hh, mm, ss);
        return d;
    }

    // Build threshold: now + 2 hours
    const threshold = new Date(today.getTime() + 2 * 60 * 60 * 1000);

    // Determine whether selected date is today (compare YMD)
    function isSameDay(a, b) {
        return a.getFullYear() === b.getFullYear() && a.getMonth() === b.getMonth() && a.getDate() === b.getDate();
    }

    // Re-populate select
    timeInput.innerHTML = '';
    // Always include the first placeholder option if it exists in cache
    const master = window.__booking_time_options;
    if (master.length > 0) {
        timeInput.appendChild(new Option(master[0].text, master[0].value));
    }

    if (isNaN(selectedDate.getTime())) {
        // No date chosen yet: re-add all options
        for (let i = 1; i < master.length; i++) {
            timeInput.appendChild(new Option(master[i].text, master[i].value));
        }
    } else if (isSameDay(selectedDate, today)) {
        // For today: only include options where option datetime >= threshold
        for (let i = 1; i < master.length; i++) {
            const opt = master[i];
            const optDate = optionDateFor(opt.value, selectedDate);
            if (optDate.getTime() >= threshold.getTime()) {
                timeInput.appendChild(new Option(opt.text, opt.value));
            }
        }
    } else {
        // Future date: include all options
        for (let i = 1; i < master.length; i++) {
            timeInput.appendChild(new Option(master[i].text, master[i].value));
        }
    }

    // If previously selected time is removed, reset to placeholder
    if (timeInput.selectedIndex > 0 && timeInput.options[timeInput.selectedIndex] == null) {
        timeInput.selectedIndex = 0;
    }
}

// Khởi tạo kiểm tra khi trang tải xong
document.addEventListener('DOMContentLoaded', function() {
    validateDateTime();
});