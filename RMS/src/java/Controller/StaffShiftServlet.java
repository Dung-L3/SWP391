package Controller;

import Dal.StaffShiftDAO;
import Dal.UserDAO;
import Models.StaffShift;
import Models.User;

import java.io.IOException;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

@WebServlet("/StaffShiftServlet")
public class StaffShiftServlet extends HttpServlet {

    // ====================== GET ======================
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");

        HttpSession session = req.getSession(false);
        User currentUser = (session == null) ? null : (User) session.getAttribute("user");
        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/LoginServlet");
            return;
        }

        String action = req.getParameter("action");
        if (action == null) {
            action = "weekTimetable";
        }

        StaffShiftDAO dao = new StaffShiftDAO();
        boolean canManage = isManagerOrAdmin(currentUser);

        switch (action) {
            case "create": {
                if (!canManage) {
                    resp.sendError(403);
                    return;
                }

                loadAssignableStaff(req);
                req.setAttribute("viewMode", "create");
                req.setAttribute("page", "shift");
                req.setAttribute("overlayNav", false);
                req.setAttribute("canManage", true);
                req.setAttribute("u", currentUser);
                req.getRequestDispatcher("/views/ShiftForm.jsp").forward(req, resp);
                break;
            }

            case "edit": {
                if (!canManage) {
                    resp.sendError(403);
                    return;
                }

                int id = parseIntSafe(req.getParameter("id"));
                StaffShift shift = dao.getById(id);

                loadAssignableStaff(req);
                req.setAttribute("shift", shift);
                req.setAttribute("viewMode", "edit");
                req.setAttribute("page", "shift");
                req.setAttribute("overlayNav", false);
                req.setAttribute("canManage", true);
                req.setAttribute("u", currentUser);
                req.getRequestDispatcher("/views/ShiftForm.jsp").forward(req, resp);
                break;
            }

            case "view": {
                int id = parseIntSafe(req.getParameter("id"));
                StaffShift shift = dao.getById(id);

                req.setAttribute("shift", shift);
                req.setAttribute("viewMode", "view");
                req.setAttribute("page", "shift");
                req.setAttribute("overlayNav", false);
                req.setAttribute("canManage", canManage);
                req.setAttribute("u", currentUser);
                req.getRequestDispatcher("/views/ShiftForm.jsp").forward(req, resp);
                break;
            }

            case "weekTimetable":
            default: {
                String baseStr = req.getParameter("baseDate");
                LocalDate baseDate = (baseStr == null || baseStr.isEmpty())
                        ? LocalDate.now() : LocalDate.parse(baseStr);

                WeekData wd = buildWeekData(baseDate);
                List<StaffShift> shifts = dao.getShifts(wd.monday, wd.sunday);

                req.setAttribute("weekDays", wd.weekDays);
                req.setAttribute("shifts", shifts);
                req.setAttribute("mondayDate", wd.monday);
                req.setAttribute("sundayDate", wd.sunday);
                req.setAttribute("weekLabel", wd.weekLabel);
                req.setAttribute("selectedYear", wd.monday.getYear());
                req.setAttribute("baseDate", baseDate);
                req.setAttribute("prevDate", wd.prevWeekBase);
                req.setAttribute("nextDate", wd.nextWeekBase);
                req.setAttribute("canManage", canManage);
                req.setAttribute("page", "shift");
                req.setAttribute("overlayNav", false);
                req.setAttribute("u", currentUser);

                req.getRequestDispatcher("/views/ShiftTimetable.jsp").forward(req, resp);
                break;
            }
        }
    }

    // ====================== POST ======================
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");

        HttpSession session = req.getSession(false);
        User currentUser = (session == null) ? null : (User) session.getAttribute("user");
        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/LoginServlet");
            return;
        }

        String action = req.getParameter("action");
        if (action == null) {
            action = "";
        }

        StaffShiftDAO dao = new StaffShiftDAO();
        boolean canManage = isManagerOrAdmin(currentUser);

        switch (action) {
            case "saveCreate": {
                if (!canManage) {
                    resp.sendError(403);
                    return;
                }

                StaffShift sh = buildFromRequest(req, false);
                sh.setCreatedBy(currentUser.getUserId());

                boolean ok = dao.create(sh);
                if (!ok) {
                    req.setAttribute("error", "Không thể tạo ca (trùng giờ hoặc lỗi DB).");
                    loadAssignableStaff(req);
                    req.setAttribute("shift", sh);
                    req.setAttribute("viewMode", "create");
                    req.setAttribute("page", "shift");
                    req.setAttribute("overlayNav", false);
                    req.setAttribute("canManage", true);
                    req.setAttribute("u", currentUser);
                    req.getRequestDispatcher("/views/ShiftForm.jsp").forward(req, resp);
                    return;
                }

                session.setAttribute("successMessage", "Tạo ca thành công!");
                resp.sendRedirect(req.getContextPath()
                        + "/StaffShiftServlet?action=weekTimetable&baseDate=" + sh.getShiftDate());
                break;
            }

            case "saveEdit": {
                if (!canManage) {
                    resp.sendError(403);
                    return;
                }

                StaffShift sh = buildFromRequest(req, true);
                boolean ok = dao.update(sh);
                if (!ok) {
                    req.setAttribute("error", "Không thể cập nhật ca (có thể trùng giờ).");
                    loadAssignableStaff(req);
                    req.setAttribute("shift", sh);
                    req.setAttribute("viewMode", "edit");
                    req.setAttribute("page", "shift");
                    req.setAttribute("overlayNav", false);
                    req.setAttribute("canManage", true);
                    req.setAttribute("u", currentUser);
                    req.getRequestDispatcher("/views/ShiftForm.jsp").forward(req, resp);
                    return;
                }

                session.setAttribute("successMessage", "Cập nhật ca thành công!");
                resp.sendRedirect(req.getContextPath()
                        + "/StaffShiftServlet?action=weekTimetable&baseDate=" + sh.getShiftDate());
                break;
            }

            case "delete": {
                if (!canManage) {
                    resp.sendError(403);
                    return;
                }

                int id = parseIntSafe(req.getParameter("shift_id"));
                StaffShift old = dao.getById(id);
                if (old == null) {
                    session.setAttribute("errorMessage", "Ca không tồn tại hoặc đã bị xoá.");
                    resp.sendRedirect(req.getContextPath() + "/StaffShiftServlet?action=weekTimetable");
                    return;
                }
                if (!hasShiftEnded(old)) {
                    session.setAttribute("errorMessage", "Ca chưa kết thúc, không thể xoá lúc này.");
                    resp.sendRedirect(req.getContextPath()
                            + "/StaffShiftServlet?action=weekTimetable&baseDate=" + old.getShiftDate());
                    return;
                }

                dao.delete(id);
                session.setAttribute("successMessage", "Đã xoá ca #" + id);
                resp.sendRedirect(req.getContextPath()
                        + "/StaffShiftServlet?action=weekTimetable&baseDate=" + old.getShiftDate());
                break;
            }

            case "markDone": {
                if (!canManage) {
                    resp.sendError(403);
                    return;
                }

                int id = parseIntSafe(req.getParameter("shift_id"));
                StaffShift old = dao.getById(id);
                if (old == null) {
                    session.setAttribute("errorMessage", "Ca không tồn tại.");
                    resp.sendRedirect(req.getContextPath() + "/StaffShiftServlet?action=weekTimetable");
                    return;
                }
                if (!hasShiftEnded(old)) {
                    session.setAttribute("errorMessage", "Chưa hết ca nên không thể đánh dấu Hoàn thành.");
                    resp.sendRedirect(req.getContextPath()
                            + "/StaffShiftServlet?action=weekTimetable&baseDate=" + old.getShiftDate());
                    return;
                }

                dao.updateStatus(id, "DONE");
                session.setAttribute("successMessage", "Ca #" + id + " đã hoàn thành.");
                resp.sendRedirect(req.getContextPath()
                        + "/StaffShiftServlet?action=weekTimetable&baseDate=" + old.getShiftDate());
                break;
            }

            case "cancelShift": {
                if (!canManage) {
                    resp.sendError(403);
                    return;
                }

                int id = parseIntSafe(req.getParameter("shift_id"));
                StaffShift old = dao.getById(id);
                if (old == null) {
                    session.setAttribute("errorMessage", "Ca không tồn tại.");
                    resp.sendRedirect(req.getContextPath() + "/StaffShiftServlet?action=weekTimetable");
                    return;
                }
                if (!hasShiftEnded(old)) {
                    session.setAttribute("errorMessage", "Ca chưa kết thúc, không thể huỷ lúc này.");
                    resp.sendRedirect(req.getContextPath()
                            + "/StaffShiftServlet?action=weekTimetable&baseDate=" + old.getShiftDate());
                    return;
                }

                dao.updateStatus(id, "CANCELLED");
                session.setAttribute("successMessage", "Ca #" + id + " đã bị huỷ.");
                resp.sendRedirect(req.getContextPath()
                        + "/StaffShiftServlet?action=weekTimetable&baseDate=" + old.getShiftDate());
                break;
            }

            default:
                resp.sendError(400, "Invalid action");
        }
    }

    // ====================== HELPERS ======================
    private StaffShift buildFromRequest(HttpServletRequest req, boolean withId) {
        StaffShift sh = new StaffShift();
        if (withId) {
            sh.setShiftId(parseIntSafe(req.getParameter("shift_id")));
        }
        sh.setStaffId(parseIntSafe(req.getParameter("staff_id")));

        String dateRaw = req.getParameter("shift_date");
        if (dateRaw != null && !dateRaw.isEmpty()) {
            sh.setShiftDate(LocalDate.parse(dateRaw));
        }

        String stRaw = req.getParameter("start_time");
        if (stRaw != null && !stRaw.isEmpty()) {
            sh.setStartTime(LocalTime.parse(stRaw));
        }

        String etRaw = req.getParameter("end_time");
        if (etRaw != null && !etRaw.isEmpty()) {
            sh.setEndTime(LocalTime.parse(etRaw));
        }

        sh.setStatus(req.getParameter("status"));
        return sh;
    }

    private void loadAssignableStaff(HttpServletRequest req) {
        // UserDAO udao = new UserDAO();
        // req.setAttribute("staffList", udao.getAssignableStaff());
        req.setAttribute("staffList", new java.util.ArrayList<>());
    }

    private boolean isManagerOrAdmin(User currentUser) {
        String role = currentUser.getRoleName();
        if (role == null) {
            return false;
        }
        role = role.toUpperCase();
        return role.contains("MANAGER") || role.contains("ADMIN");
    }

    private int parseIntSafe(String raw) {
        try {
            return Integer.parseInt(raw);
        } catch (Exception e) {
            return 0;
        }
    }

    // Ca đã kết thúc khi now >= end_time (hỗ trợ ca qua đêm)
    private boolean hasShiftEnded(StaffShift sh) {
        if (sh == null) {
            return false;
        }
        LocalDate shiftDate = sh.getShiftDate();
        LocalTime start = sh.getStartTime();
        LocalTime end = sh.getEndTime();
        LocalDate endDate = end.isBefore(start) ? shiftDate.plusDays(1) : shiftDate;
        LocalDateTime shiftEnd = LocalDateTime.of(endDate, end);
        return !LocalDateTime.now().isBefore(shiftEnd);
    }

    // Thông tin tuần (Mon..Sun) để render lịch
    private WeekData buildWeekData(LocalDate baseDate) {
        DayOfWeek dow = baseDate.getDayOfWeek();
        int diffFromMon = dow.getValue() - DayOfWeek.MONDAY.getValue();
        LocalDate monday = baseDate.minusDays(diffFromMon);
        LocalDate sunday = monday.plusDays(6);

        List<LocalDate> weekDays = new ArrayList<>();
        for (int i = 0; i < 7; i++) {
            weekDays.add(monday.plusDays(i));
        }

        WeekData wd = new WeekData();
        wd.monday = monday;
        wd.sunday = sunday;
        wd.weekDays = weekDays;
        wd.weekLabel = monday.getDayOfMonth() + "/" + monday.getMonthValue()
                + " To " + sunday.getDayOfMonth() + "/" + sunday.getMonthValue();
        wd.prevWeekBase = baseDate.minusDays(7);
        wd.nextWeekBase = baseDate.plusDays(7);
        return wd;
    }

    private static class WeekData {

        LocalDate monday;
        LocalDate sunday;
        List<LocalDate> weekDays;
        String weekLabel;
        LocalDate prevWeekBase;
        LocalDate nextWeekBase;
    }
}
