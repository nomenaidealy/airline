package main.project.servlets;

import main.project.beans.*;
import main.project.utils.DBConnection;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/payments")
public class PaymentServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Employee employee = (Employee) request.getSession().getAttribute("employee");

        // Vérifier les permissions
        if (employee == null || (!employee.isAccountant() && !employee.isAdmin())) {
            response.sendRedirect("dashboard");
            return;
        }

        String action = request.getParameter("action");

        if (action == null) {
            action = "dashboard";
        }

        switch (action) {
            case "list":
                listPayments(request, response);
                break;
            case "byFlight":
                revenueByFlight(request, response);
                break;
            case "byMonth":
                revenueByMonth(request, response);
                break;
            default:
                showDashboard(request, response);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");

        if ("create".equals(action)) {
            createPayment(request, response);
        }
    }

    private void showDashboard(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Connection conn = null;

        try {
            conn = DBConnection.getConnection();

            // Total des revenus
            String sqlTotal = "SELECT SUM(amount) as total FROM payments WHERE status = 'paid'";
            Statement stmtTotal = conn.createStatement();
            ResultSet rsTotal = stmtTotal.executeQuery(sqlTotal);
            double totalRevenue = 0;
            if (rsTotal.next()) {
                totalRevenue = rsTotal.getDouble("total");
            }
            rsTotal.close();
            stmtTotal.close();

            // Nombre de paiements ce mois
            String sqlMonth = "SELECT COUNT(*) as count, SUM(amount) as total FROM payments " +
                    "WHERE status = 'paid' AND EXTRACT(MONTH FROM payment_date) = EXTRACT(MONTH FROM CURRENT_DATE) " +
                    "AND EXTRACT(YEAR FROM payment_date) = EXTRACT(YEAR FROM CURRENT_DATE)";
            Statement stmtMonth = conn.createStatement();
            ResultSet rsMonth = stmtMonth.executeQuery(sqlMonth);
            int monthCount = 0;
            double monthRevenue = 0;
            if (rsMonth.next()) {
                monthCount = rsMonth.getInt("count");
                monthRevenue = rsMonth.getDouble("total");
            }
            rsMonth.close();
            stmtMonth.close();

            // Nombre total de paiements
            String sqlCount = "SELECT COUNT(*) as count FROM payments WHERE status = 'paid'";
            Statement stmtCount = conn.createStatement();
            ResultSet rsCount = stmtCount.executeQuery(sqlCount);
            int totalCount = 0;
            if (rsCount.next()) {
                totalCount = rsCount.getInt("count");
            }
            rsCount.close();
            stmtCount.close();

            request.setAttribute("totalRevenue", totalRevenue);
            request.setAttribute("monthRevenue", monthRevenue);
            request.setAttribute("monthCount", monthCount);
            request.setAttribute("totalCount", totalCount);

        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBConnection.closeConnection(conn);
        }

        request.getRequestDispatcher("/WEB-INF/jsp/payments/dashboard.jsp").forward(request, response);
    }

    private void listPayments(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<Payment> payments = new ArrayList<>();
        Connection conn = null;

        try {
            conn = DBConnection.getConnection();
            String sql = "SELECT p.*, b.booking_reference, b.seat_number, " +
                    "f.flight_number, " +
                    "pass.first_name, pass.last_name " +
                    "FROM payments p " +
                    "JOIN bookings b ON p.booking_id = b.id " +
                    "JOIN flights f ON b.flight_id = f.id " +
                    "JOIN passengers pass ON b.passenger_id = pass.id " +
                    "ORDER BY p.payment_date DESC";

            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery(sql);

            while (rs.next()) {
                Payment payment = new Payment();
                payment.setId(rs.getInt("id"));
                payment.setAmount(rs.getDouble("amount"));
                payment.setPaymentDate(rs.getTimestamp("payment_date"));
                payment.setPaymentMethod(rs.getString("payment_method"));
                payment.setStatus(rs.getString("status"));

                Booking booking = new Booking();
                booking.setId(rs.getInt("booking_id"));
                booking.setBookingReference(rs.getString("booking_reference"));
                booking.setSeatNumber(rs.getString("seat_number"));

                Flight flight = new Flight();
                flight.setFlightNumber(rs.getString("flight_number"));
                booking.setFlight(flight);

                Passenger passenger = new Passenger();
                passenger.setFirstName(rs.getString("first_name"));
                passenger.setLastName(rs.getString("last_name"));
                booking.setPassenger(passenger);

                payment.setBooking(booking);
                payments.add(payment);
            }

            rs.close();
            stmt.close();
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBConnection.closeConnection(conn);
        }

        request.setAttribute("payments", payments);
        request.getRequestDispatcher("/WEB-INF/jsp/payments/listPayments.jsp").forward(request, response);
    }

    private void revenueByFlight(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<Map<String, Object>> flightRevenue = new ArrayList<>();
        Connection conn = null;

        try {
            conn = DBConnection.getConnection();
            String sql = "SELECT f.flight_number, f.departure_time, " +
                    "da.code as dep_code, aa.code as arr_code, " +
                    "COUNT(p.id) as payment_count, SUM(p.amount) as total_revenue " +
                    "FROM flights f " +
                    "JOIN airports da ON f.departure_airport_id = da.id " +
                    "JOIN airports aa ON f.arrival_airport_id = aa.id " +
                    "LEFT JOIN bookings b ON f.id = b.flight_id " +
                    "LEFT JOIN payments p ON b.id = p.booking_id AND p.status = 'paid' " +
                    "GROUP BY f.id, f.flight_number, f.departure_time, da.code, aa.code " +
                    "HAVING COUNT(p.id) > 0 " +
                    "ORDER BY total_revenue DESC";

            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery(sql);

            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("flightNumber", rs.getString("flight_number"));
                row.put("departureTime", rs.getTimestamp("departure_time"));
                row.put("route", rs.getString("dep_code") + " → " + rs.getString("arr_code"));
                row.put("paymentCount", rs.getInt("payment_count"));
                row.put("totalRevenue", rs.getDouble("total_revenue"));
                flightRevenue.add(row);
            }

            rs.close();
            stmt.close();
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBConnection.closeConnection(conn);
        }

        request.setAttribute("flightRevenue", flightRevenue);
        request.getRequestDispatcher("/WEB-INF/jsp/payments/revenueByFlight.jsp").forward(request, response);
    }

    private void revenueByMonth(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<Map<String, Object>> monthlyRevenue = new ArrayList<>();
        Connection conn = null;

        try {
            conn = DBConnection.getConnection();
            String sql = "SELECT " +
                    "EXTRACT(YEAR FROM payment_date) as year, " +
                    "EXTRACT(MONTH FROM payment_date) as month, " +
                    "COUNT(*) as payment_count, " +
                    "SUM(amount) as total_revenue " +
                    "FROM payments " +
                    "WHERE status = 'paid' " +
                    "GROUP BY EXTRACT(YEAR FROM payment_date), EXTRACT(MONTH FROM payment_date) " +
                    "ORDER BY year DESC, month DESC";

            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery(sql);

            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("year", rs.getInt("year"));
                row.put("month", rs.getInt("month"));
                row.put("paymentCount", rs.getInt("payment_count"));
                row.put("totalRevenue", rs.getDouble("total_revenue"));
                monthlyRevenue.add(row);
            }

            rs.close();
            stmt.close();
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBConnection.closeConnection(conn);
        }

        request.setAttribute("monthlyRevenue", monthlyRevenue);
        request.getRequestDispatcher("/WEB-INF/jsp/payments/revenueByMonth.jsp").forward(request, response);
    }

    private void createPayment(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        Connection conn = null;

        try {
            conn = DBConnection.getConnection();

            int bookingId = Integer.parseInt(request.getParameter("bookingId"));
            double amount = Double.parseDouble(request.getParameter("amount"));
            String paymentMethod = request.getParameter("paymentMethod");

            String sql = "INSERT INTO payments (booking_id, amount, payment_method, status) " +
                    "VALUES (?, ?, ?, 'paid')";

            PreparedStatement stmt = conn.prepareStatement(sql);
            stmt.setInt(1, bookingId);
            stmt.setDouble(2, amount);
            stmt.setString(3, paymentMethod);

            stmt.executeUpdate();
            stmt.close();

            HttpSession session = request.getSession();
            session.setAttribute("successMessage", "Paiement enregistré avec succès");
        } catch (SQLException e) {
            e.printStackTrace();
            HttpSession session = request.getSession();
            session.setAttribute("errorMessage", "Erreur lors de l'enregistrement du paiement");
        } finally {
            DBConnection.closeConnection(conn);
        }

        response.sendRedirect("payments?action=list");
    }
}