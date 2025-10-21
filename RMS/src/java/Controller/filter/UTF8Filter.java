package Controller.filter;

import jakarta.servlet.*;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * UTF-8 Encoding Filter to ensure proper character encoding
 */
public class UTF8Filter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        // Initialization code if needed
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;
        
        // Only apply UTF-8 encoding to HTML pages, not CSS/JS/images
        String requestURI = httpRequest.getRequestURI();
        String contentType = null;
        
        if (requestURI.endsWith(".css")) {
            contentType = "text/css; charset=UTF-8";
        } else if (requestURI.endsWith(".js")) {
            contentType = "application/javascript; charset=UTF-8";
        } else if (requestURI.endsWith(".jsp") || requestURI.endsWith("/") || 
                   (!requestURI.contains(".") && !requestURI.contains("/img/") && !requestURI.contains("/lib/"))) {
            // Only set UTF-8 for JSP pages and servlet requests
            request.setCharacterEncoding("UTF-8");
            contentType = "text/html; charset=UTF-8";
        }
        
        if (contentType != null) {
            response.setCharacterEncoding("UTF-8");
            response.setContentType(contentType);
        }
        
        // Continue with the filter chain
        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
        // Cleanup code if needed
    }
}
