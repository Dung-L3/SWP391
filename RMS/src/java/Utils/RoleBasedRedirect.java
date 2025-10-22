package Utils;

import Models.User;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * @author donny
 */
public class RoleBasedRedirect {
    
    public static void redirectByRole(User user, HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/auth/Login.jsp");
            return;
        }
        
        String roleName = user.getRoleName();
        String contextPath = request.getContextPath();
        
        switch (roleName) {
            case "Manager":
                response.sendRedirect(contextPath + "/admin");
                break;
            case "Waiter":
                response.sendRedirect(contextPath + "/tables");
                break;
            case "Chef":
                response.sendRedirect(contextPath + "/kds");
                break;
            case "Receptionist":
                response.sendRedirect(contextPath + "/reception");
                break;
            case "Cashier":
                response.sendRedirect(contextPath + "/cashier");
                break;
            case "Supervisor":
                response.sendRedirect(contextPath + "/supervisor");
                break;
            default:
                response.sendRedirect(contextPath + "/dashboard");
                break;
        }
    }
    
    public static boolean hasPermission(User user, String requiredRole) {
        if (user == null) return false;
        
        String userRole = user.getRoleName();
        
        // Manager có quyền truy cập tất cả
        if ("Manager".equals(userRole)) {
            return true;
        }
        
        // Kiểm tra role cụ thể
        return requiredRole.equals(userRole);
    }
    
    public static boolean hasAnyPermission(User user, String... roles) {
        if (user == null) return false;
        
        String userRole = user.getRoleName();
        
        // Manager có quyền truy cập tất cả
        if ("Manager".equals(userRole)) {
            return true;
        }
        
        // Kiểm tra một trong các role
        for (String role : roles) {
            if (role.equals(userRole)) {
                return true;
            }
        }
        
        return false;
    }
}
