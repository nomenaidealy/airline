package main.project.servlets;

import main.project.beans.*;
import main.project.utils.DBConnection;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/flights")
public class FlightServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");

        if (action == null) {
            action = "list";
        }

        switch (action) {
            case "add":
                showAddForm(request, response);
                break;
            case "edit":
                showEditForm(request, response);
                break;
            case "delete":
                deleteFlight(request, response);
                break;
            default:
                listFlights(request, response);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");

        if ("update".equals(action)) {
            updateFlight(request, response);
        } else {
            addFlight(request, response);
        }
    }

    private void listFlights(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<Flight> flights = new ArrayList<>();
        Connection conn = null;

        try {
            conn = DBConnection.getConnection();
            String sql = "SELECT f.*, " +
                    "da.code as dep_code, da.name as dep_name, da.city as dep_city, da.country as dep_country, " +
                    "aa.code as arr_code, aa.name as arr_name, aa.city as arr_city, aa.country as arr_country, " +
                    "ac.registration, ac.model, ac.total_seats " +
                    "FROM flights f " +
                    "JOIN airports da ON f.departure_airport_id = da.id " +
                    "JOIN airports aa ON f.arrival_airport_id = aa.id " +
                    "LEFT JOIN aircrafts ac ON f.aircraft_id = ac.id " +
                    "ORDER BY f.departure_time DESC";

            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery(sql);

            while (rs.next()) {
                Flight flight = new Flight();
                flight.setId(rs.getInt("id"));
                flight.setFlightNumber(rs.getString("flight_number"));
                flight.setDepartureTime(rs.getTimestamp("departure_time"));
                flight.setArrivalTime(rs.getTimestamp("arrival_time"));
                flight.setBasePrice(rs.getDouble("base_price"));
                flight.setStatus(rs.getString("status"));

                Airport depAirport = new Airport(
                        rs.getInt("departure_airport_id"),
                        rs.getString("dep_code"),
                        rs.getString("dep_name"),
                        rs.getString("dep_city"),
                        rs.getString("dep_country")
                );
                flight.setDepartureAirport(depAirport);

                Airport arrAirport = new Airport(
                        rs.getInt("arrival_airport_id"),
                        rs.getString("arr_code"),
                        rs.getString("arr_name"),
                        rs.getString("arr_city"),
                        rs.getString("arr_country")
                );
                flight.setArrivalAirport(arrAirport);

                if (rs.getInt("aircraft_id") != 0) {
                    Aircraft aircraft = new Aircraft(
                            rs.getInt("aircraft_id"),
                            rs.getString("registration"),
                            rs.getString("model"),
                            rs.getInt("total_seats")
                    );
                    flight.setAircraft(aircraft);
                }

                flights.add(flight);
            }

            rs.close();
            stmt.close();
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBConnection.closeConnection(conn);
        }

        request.setAttribute("flights", flights);
        request.getRequestDispatcher("/WEB-INF/jsp/flights/listFlights.jsp").forward(request, response);
    }

    private void showAddForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        loadAirportsAndAircrafts(request);
        request.getRequestDispatcher("/WEB-INF/jsp/flights/addFlight.jsp").forward(request, response);
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        Connection conn = null;

        try {
            conn = DBConnection.getConnection();
            String sql = "SELECT * FROM flights WHERE id = ?";
            PreparedStatement stmt = conn.prepareStatement(sql);
            stmt.setInt(1, id);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                Flight flight = new Flight(
                        rs.getInt("id"),
                        rs.getString("flight_number"),
                        rs.getInt("departure_airport_id"),
                        rs.getInt("arrival_airport_id"),
                        rs.getTimestamp("departure_time"),
                        rs.getTimestamp("arrival_time"),
                        rs.getInt("aircraft_id"),
                        rs.getDouble("base_price"),
                        rs.getString("status")
                );
                request.setAttribute("flight", flight);
            }

            rs.close();
            stmt.close();
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBConnection.closeConnection(conn);
        }

        loadAirportsAndAircrafts(request);
        request.getRequestDispatcher("/WEB-INF/jsp/flights/editFlight.jsp").forward(request, response);
    }

    private void addFlight(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        Connection conn = null;

        try {
            conn = DBConnection.getConnection();
            String sql = "INSERT INTO flights (flight_number, departure_airport_id, arrival_airport_id, " +
                    "departure_time, arrival_time, aircraft_id, base_price, status) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

            PreparedStatement stmt = conn.prepareStatement(sql);
            stmt.setString(1, request.getParameter("flightNumber"));
            stmt.setInt(2, Integer.parseInt(request.getParameter("departureAirportId")));
            stmt.setInt(3, Integer.parseInt(request.getParameter("arrivalAirportId")));
            stmt.setTimestamp(4, Timestamp.valueOf(request.getParameter("departureTime")));
            stmt.setTimestamp(5, Timestamp.valueOf(request.getParameter("arrivalTime")));
            stmt.setInt(6, Integer.parseInt(request.getParameter("aircraftId")));
            stmt.setDouble(7, Double.parseDouble(request.getParameter("basePrice")));
            stmt.setString(8, request.getParameter("status"));

            stmt.executeUpdate();
            stmt.close();

            HttpSession session = request.getSession();
            session.setAttribute("successMessage", "Vol ajouté avec succès");
        } catch (SQLException e) {
            e.printStackTrace();
            HttpSession session = request.getSession();
            session.setAttribute("errorMessage", "Erreur lors de l'ajout du vol");
        } finally {
            DBConnection.closeConnection(conn);
        }

        response.sendRedirect("flights");
    }

    private void updateFlight(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        Connection conn = null;

        try {
            conn = DBConnection.getConnection();
            String sql = "UPDATE flights SET flight_number=?, departure_airport_id=?, arrival_airport_id=?, " +
                    "departure_time=?, arrival_time=?, aircraft_id=?, base_price=?, status=? WHERE id=?";

            PreparedStatement stmt = conn.prepareStatement(sql);
            stmt.setString(1, request.getParameter("flightNumber"));
            stmt.setInt(2, Integer.parseInt(request.getParameter("departureAirportId")));
            stmt.setInt(3, Integer.parseInt(request.getParameter("arrivalAirportId")));
            stmt.setTimestamp(4, Timestamp.valueOf(request.getParameter("departureTime")));
            stmt.setTimestamp(5, Timestamp.valueOf(request.getParameter("arrivalTime")));
            stmt.setInt(6, Integer.parseInt(request.getParameter("aircraftId")));
            stmt.setDouble(7, Double.parseDouble(request.getParameter("basePrice")));
            stmt.setString(8, request.getParameter("status"));
            stmt.setInt(9, Integer.parseInt(request.getParameter("id")));

            stmt.executeUpdate();
            stmt.close();

            HttpSession session = request.getSession();
            session.setAttribute("successMessage", "Vol modifié avec succès");
        } catch (SQLException e) {
            e.printStackTrace();
            HttpSession session = request.getSession();
            session.setAttribute("errorMessage", "Erreur lors de la modification du vol");
        } finally {
            DBConnection.closeConnection(conn);
        }

        response.sendRedirect("flights");
    }

    private void deleteFlight(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        Connection conn = null;

        try {
            conn = DBConnection.getConnection();
            String sql = "DELETE FROM flights WHERE id = ?";
            PreparedStatement stmt = conn.prepareStatement(sql);
            stmt.setInt(1, id);
            stmt.executeUpdate();
            stmt.close();

            HttpSession session = request.getSession();
            session.setAttribute("successMessage", "Vol supprimé avec succès");
        } catch (SQLException e) {
            e.printStackTrace();
            HttpSession session = request.getSession();
            session.setAttribute("errorMessage", "Erreur lors de la suppression du vol");
        } finally {
            DBConnection.closeConnection(conn);
        }

        response.sendRedirect("flights");
    }

    private void loadAirportsAndAircrafts(HttpServletRequest request) {
        Connection conn = null;

        try {
            conn = DBConnection.getConnection();

            // Charger les aéroports
            List<Airport> airports = new ArrayList<>();
            Statement stmt1 = conn.createStatement();
            ResultSet rs1 = stmt1.executeQuery("SELECT * FROM airports ORDER BY code");
            while (rs1.next()) {
                airports.add(new Airport(
                        rs1.getInt("id"),
                        rs1.getString("code"),
                        rs1.getString("name"),
                        rs1.getString("city"),
                        rs1.getString("country")
                ));
            }
            rs1.close();
            stmt1.close();

            // Charger les avions
            List<Aircraft> aircrafts = new ArrayList<>();
            Statement stmt2 = conn.createStatement();
            ResultSet rs2 = stmt2.executeQuery("SELECT * FROM aircrafts ORDER BY registration");
            while (rs2.next()) {
                aircrafts.add(new Aircraft(
                        rs2.getInt("id"),
                        rs2.getString("registration"),
                        rs2.getString("model"),
                        rs2.getInt("total_seats")
                ));
            }
            rs2.close();
            stmt2.close();

            request.setAttribute("airports", airports);
            request.setAttribute("aircrafts", aircrafts);
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBConnection.closeConnection(conn);
        }
    }
}