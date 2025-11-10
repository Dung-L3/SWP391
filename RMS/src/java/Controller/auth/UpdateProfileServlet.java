package Controller.auth;

import Dal.UserDAO;
import Models.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.util.UUID;

@WebServlet("/profile/update")
@MultipartConfig(maxFileSize = 5 * 1024 * 1024) // 5MB
public class UpdateProfileServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        User current = (session == null) ? null : (User) session.getAttribute("user");
        if (current == null) {
            resp.sendRedirect(req.getContextPath() + "/LoginServlet");
            return;
        }

        req.setCharacterEncoding("UTF-8");

        String firstName = trim(req.getParameter("firstName"));
        String lastName  = trim(req.getParameter("lastName"));
        String email     = trim(req.getParameter("email"));
        String phone     = trim(req.getParameter("phone"));
        String address   = trim(req.getParameter("address"));

        // Xử lý file avatar (tùy chọn)
        String avatarUrl = null;
        Part avatarPart = req.getPart("avatar");
        if (avatarPart != null && avatarPart.getSize() > 0) {
            String contentType = avatarPart.getContentType();

            if (contentType != null && contentType.startsWith("image/")) {
                String uploadDirPath = getServletContext().getRealPath("/img/avatars");
                File uploadDir = new File(uploadDirPath);
                if (!uploadDir.exists()) uploadDir.mkdirs();

                String ext = guessExt(contentType);
                String fileName = "u" + current.getUserId() + "_" + UUID.randomUUID() + ext;

                File dest = new File(uploadDir, fileName);
                Files.copy(avatarPart.getInputStream(), dest.toPath());

                avatarUrl = req.getContextPath() + "/img/avatars/" + fileName;
            }
        }

        UserDAO dao = new UserDAO();
        boolean ok = dao.updateProfile(
                current.getUserId(),
                firstName,
                lastName,
                email,
                phone,
                address,
                avatarUrl   // có thể null, DAO nên xử lý "không đổi avatar" khi null
        );

        if (ok) {
            // Cập nhật object user trong session
            current.setFirstName(firstName);
            current.setLastName(lastName);
            current.setEmail(email);
            current.setPhone(phone);
            current.setAddress(address);
            if (avatarUrl != null) {
                current.setAvatarUrl(avatarUrl);
            }
            session.setAttribute("user", current);
            session.setAttribute("flash", "Cập nhật hồ sơ thành công.");
        } else {
            session.setAttribute("flash", "Cập nhật thất bại. Vui lòng thử lại.");
        }

        // Quay về trang hồ sơ (qua ProfileServlet)
        resp.sendRedirect(req.getContextPath() + "/profile");
    }

    private String trim(String s) {
        return s == null ? null : s.trim();
    }

    private String guessExt(String contentType) {
        if (contentType == null) return ".jpg";
        contentType = contentType.toLowerCase();
        if (contentType.endsWith("png"))  return ".png";
        if (contentType.endsWith("jpeg")) return ".jpg";
        if (contentType.endsWith("jpg"))  return ".jpg";
        if (contentType.endsWith("gif"))  return ".gif";
        return ".jpg";
    }
}
