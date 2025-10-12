<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login Test - RMS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
    <div class="container mt-5">
        <div class="row justify-content-center">
            <div class="col-md-6">
                <div class="card">
                    <div class="card-header">
                        <h3 class="text-center">Đăng nhập RMS</h3>
                    </div>
                    <div class="card-body">
                        <% 
                            String error = (String) request.getAttribute("loginError");
                            if (error != null) {
                        %>
                            <div class="alert alert-danger">
                                <%= error %>
                            </div>
                        <% } %>
                        
                        <form method="post" action="LoginServlet">
                            <div class="mb-3">
                                <label for="username" class="form-label">Tên đăng nhập / Email</label>
                                <input type="text" class="form-control" id="username" name="username" 
                                       placeholder="admin@rms.com" required>
                            </div>
                            
                            <div class="mb-3">
                                <label for="password" class="form-label">Mật khẩu</label>
                                <input type="password" class="form-control" id="password" name="password" 
                                       placeholder="test" required>
                            </div>
                            
                            <div class="mb-3 form-check">
                                <input type="checkbox" class="form-check-input" id="remember" name="remember">
                                <label class="form-check-label" for="remember">Nhớ tôi</label>
                            </div>
                            
                            <button type="submit" class="btn btn-primary w-100">Đăng nhập</button>
                        </form>
                        
                        <div class="mt-3">
                            <h6>Tài khoản test:</h6>
                            <ul>
                                <li><strong>admin@rms.com</strong> / <strong>test</strong> (Manager)</li>
                                <li><strong>waiter1@rms.com</strong> / <strong>test</strong> (Waiter)</li>
                                <li><strong>chef1@rms.com</strong> / <strong>test</strong> (Chef)</li>
                            </ul>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
