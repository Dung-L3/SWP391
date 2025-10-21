package test;

import Dal.ReservationDAO;
import Models.Reservation;
import java.util.List;

public class CheckTableReservations {
    public static void main(String[] args) {
        try {
            ReservationDAO dao = new ReservationDAO();
            String tableNumber = "T3-01";
            List<Reservation> reservations = dao.findActiveReservationsByTable(tableNumber);
            
            System.out.println("Active reservations for table " + tableNumber + ":");
            System.out.println("----------------------------------------");
            
            if (reservations.isEmpty()) {
                System.out.println("No active reservations found");
            } else {
                for (Reservation r : reservations) {
                    System.out.printf("Date: %s\n", r.getReservationDate());
                    System.out.printf("Time: %s\n", r.getReservationTime());
                    System.out.printf("Customer: %s\n", r.getCustomerName());
                    System.out.printf("Phone: %s\n", r.getPhone());
                    System.out.printf("Status: %s\n", r.getStatus());
                    System.out.println("----------------------------------------");
                }
            }
            
        } catch (Exception e) {
            System.err.println("Error checking reservations: " + e.getMessage());
            e.printStackTrace();
        }
    }
}