/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */

package Controller.auth;

import Dal.UserDAO;
import Models.User;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import java.io.File;
import java.nio.file.Files;
import java.util.UUID;

/**
 *
 * @author auiri
 */
@WebServlet("/UpdateProfileServlet")
@MultipartConfig( maxFileSize = 5 * 1024 * 1024 ) 
public class UpdateProfileServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        User current = (session == null) ? null : (User) session.getAttribute("user");
        if (current == null) {
            resp.sendRedirect("LoginServlet");
            return;
        }

        req.setCharacterEncoding("UTF-8");

        String firstName = req.getParameter("firstName");
        String lastName  = req.getParameter("lastName");
        String email     = req.getParameter("email");
        String phone     = req.getParameter("phone");
        String address   = req.getParameter("address");

        // Xử lý file avatar (tùy chọn)
        String avatarUrl = null;
        Part avatarPart = req.getPart("avatar"); 
        if (avatarPart != null && avatarPart.getSize() > 0) {
            String contentType = avatarPart.getContentType(); 
            if (contentType != null && contentType.startsWith("image/")) {
                String uploadDir = getServletContext().getRealPath("/img/avatars");
                File dir = new File(uploadDir);
                if (!dir.exists()) dir.mkdirs();

                String ext = guessExt(contentType); 
                String fileName = "u" + current.getUserId() + "_" + UUID.randomUUID() + ext;

                File dest = new File(dir, fileName);
                Files.copy(avatarPart.getInputStream(), dest.toPath());

                avatarUrl = "/img/avatars/" + fileName;
            }
        }

        UserDAO dao = new UserDAO();
        boolean ok = dao.updateProfile(
                current.getUserId(), firstName, lastName, email, phone, address, avatarUrl
        );

        if (ok) {
            
            current.setFirstName(firstName);
            current.setLastName(lastName);
            current.setEmail(email);
            current.setPhone(phone);
            current.setAddress(address);
            if (avatarUrl != null) current.setAvatarUrl(avatarUrl);
            session.setAttribute("user", current);

            session.setAttribute("flash", "Profile updated successfully.");
        } else {
            session.setAttribute("flash", "Update failed. Please try again.");
        }

        resp.sendRedirect("views/profile.jsp");
    }

    private String guessExt(String contentType) {
        if (contentType == null) return ".jpg";
        if (contentType.endsWith("png"))  return ".png";
        if (contentType.endsWith("jpeg")) return ".jpg";
        if (contentType.endsWith("jpg"))  return ".jpg";
        if (contentType.endsWith("gif"))  return ".gif";
        return ".jpg";
    }
}