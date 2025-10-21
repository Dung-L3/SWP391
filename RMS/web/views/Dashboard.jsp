<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - RMS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        .dashboard-card {
            transition: transform 0.3s;
            cursor: pointer;
        }
        .dashboard-card:hover {
            transform: translateY(-5px);
        }
    </style>
</head>
<body>
    <div class="container-fluid">
        <div class="row">
            <div class="col-12">
                <nav class="navbar navbar-expand-lg navbar-dark bg-primary mb-4">
                    <div class="container-fluid">
                        <a class="navbar-brand" href="#">
                            <i class="fas fa-utensils"></i> RMS - Restaurant Management System
                        </a>
                        <div class="navbar-nav ms-auto">
                            <span class="navbar-text me-3">
                                <i class="fas fa-user"></i> ${sessionScope.user.firstName} ${sessionScope.user.lastName}
                            </span>
                            <a class="nav-link" href="logout">
                                <i class="fas fa-sign-out-alt"></i> Đăng xuất
                            </a>
                        </div>
                    </div>
                </nav>

                <div class="row">
                    <div class="col-12">
                        <h2 class="mb-4">
                            <i class="fas fa-tachometer-alt"></i> Dashboard
                        </h2>
                    </div>
                </div>

                <div class="row">
                    <!-- Bản đồ bàn -->
                    <div class="col-md-6 col-lg-4 mb-4">
                        <div class="card dashboard-card h-100" onclick="location.href='tables'">
                            <div class="card-body text-center">
                                <i class="fas fa-map fa-3x text-primary mb-3"></i>
                                <h5 class="card-title">Bản đồ bàn</h5>
                                <p class="card-text">Quản lý bàn ăn, đón khách, trả bàn</p>
                            </div>
                        </div>
                    </div>

                    <!-- Quản lý đơn hàng -->
                    <div class="col-md-6 col-lg-4 mb-4">
                        <div class="card dashboard-card h-100" onclick="location.href='orders'">
                            <div class="card-body text-center">
                                <i class="fas fa-shopping-cart fa-3x text-success mb-3"></i>
                                <h5 class="card-title">Đơn hàng</h5>
                                <p class="card-text">Tạo đơn, gửi bếp, theo dõi trạng thái</p>
                            </div>
                        </div>
                    </div>

                    <!-- Thực đơn -->
                    <div class="col-md-6 col-lg-4 mb-4">
                        <div class="card dashboard-card h-100" onclick="location.href='menu'">
                            <div class="card-body text-center">
                                <i class="fas fa-book fa-3x text-warning mb-3"></i>
                                <h5 class="card-title">Thực đơn</h5>
                                <p class="card-text">Quản lý món ăn, giá cả, danh mục</p>
                            </div>
                        </div>
                    </div>

                    <!-- Quản lý nhân viên -->
                    <div class="col-md-6 col-lg-4 mb-4">
                        <div class="card dashboard-card h-100" onclick="location.href='staff-management'">
                            <div class="card-body text-center">
                                <i class="fas fa-users fa-3x text-info mb-3"></i>
                                <h5 class="card-title">Nhân viên</h5>
                                <p class="card-text">Quản lý tài khoản nhân viên</p>
                            </div>
                        </div>
                    </div>

                    <!-- Báo cáo -->
                    <div class="col-md-6 col-lg-4 mb-4">
                        <div class="card dashboard-card h-100" onclick="location.href='reports'">
                            <div class="card-body text-center">
                                <i class="fas fa-chart-bar fa-3x text-danger mb-3"></i>
                                <h5 class="card-title">Báo cáo</h5>
                                <p class="card-text">Thống kê doanh thu, bán hàng</p>
                            </div>
                        </div>
                    </div>

                    <!-- Cài đặt -->
                    <div class="col-md-6 col-lg-4 mb-4">
                        <div class="card dashboard-card h-100" onclick="location.href='settings'">
                            <div class="card-body text-center">
                                <i class="fas fa-cog fa-3x text-secondary mb-3"></i>
                                <h5 class="card-title">Cài đặt</h5>
                                <p class="card-text">Cấu hình hệ thống</p>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Thống kê nhanh -->
                <div class="row mt-4">
                    <div class="col-12">
                        <div class="card">
                            <div class="card-header">
                                <h5 class="mb-0">
                                    <i class="fas fa-chart-line"></i> Thống kê nhanh
                                </h5>
                            </div>
                            <div class="card-body">
                                <div class="row text-center">
                                    <div class="col-md-3">
                                        <div class="border-end">
                                            <h3 class="text-primary">12</h3>
                                            <p class="text-muted">Bàn trống</p>
                                        </div>
                                    </div>
                                    <div class="col-md-3">
                                        <div class="border-end">
                                            <h3 class="text-warning">3</h3>
                                            <p class="text-muted">Bàn có khách</p>
                                        </div>
                                    </div>
                                    <div class="col-md-3">
                                        <div class="border-end">
                                            <h3 class="text-info">2</h3>
                                            <p class="text-muted">Đang dọn dẹp</p>
                                        </div>
                                    </div>
                                    <div class="col-md-3">
                                        <h3 class="text-success">5</h3>
                                        <p class="text-muted">Đơn hàng hôm nay</p>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
