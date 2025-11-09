package Dal;

import Models.Supplier;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class SupplierDAO {

    /**
     * Get all active suppliers
     */
    public List<Supplier> getAllActiveSuppliers() {
        List<Supplier> suppliers = new ArrayList<>();
        String sql = "SELECT supplier_id, company_name, contact_person, email, phone, address, status " +
                "FROM suppliers WHERE status = ? ORDER BY company_name";

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, Supplier.STATUS_ACTIVE);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Supplier s = new Supplier();
                    s.setSupplierId(rs.getInt("supplier_id"));
                    s.setCompanyName(rs.getString("company_name"));
                    s.setContactPerson(rs.getString("contact_person"));
                    s.setEmail(rs.getString("email"));
                    s.setPhone(rs.getString("phone"));
                    s.setAddress(rs.getString("address"));
                    s.setStatus(rs.getString("status"));
                    suppliers.add(s);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return suppliers;
    }

    /**
     * Get supplier by ID
     */
    public Supplier getSupplierById(int supplierId) {
        String sql = "SELECT supplier_id, company_name, contact_person, email, phone, address, status " +
                "FROM suppliers WHERE supplier_id = ?";

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, supplierId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Supplier s = new Supplier();
                    s.setSupplierId(rs.getInt("supplier_id"));
                    s.setCompanyName(rs.getString("company_name"));
                    s.setContactPerson(rs.getString("contact_person"));
                    s.setEmail(rs.getString("email"));
                    s.setPhone(rs.getString("phone"));
                    s.setAddress(rs.getString("address"));
                    s.setStatus(rs.getString("status"));
                    return s;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    /**
     * Create supplier
     */
    public boolean createSupplier(Supplier supplier) {
        String sql = "INSERT INTO suppliers (company_name, contact_person, email, phone, address, status, created_by) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, supplier.getCompanyName());
            ps.setString(2, supplier.getContactPerson());
            ps.setString(3, supplier.getEmail());
            ps.setString(4, supplier.getPhone());
            ps.setString(5, supplier.getAddress());
            ps.setString(6, supplier.getStatus());
            ps.setObject(7, supplier.getCreatedBy());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
}

