package main.project.servlets;

import main.project.beans.*;
import main.project.dao.FlightSeatPriceDAO;
import main.project.utils.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/flight-instances")
public class FlightInstanceServlet extends HttpServlet {

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
                deleteFlightInstance(request, response);
                break;
            case "details":
            showFlightDetails(request, response);
            break;

            default:
                listFlightInstances(request, response);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");

        if ("update".equals(action)) {
            updateFlightInstance(request, response);
        } else {
            addFlightInstance(request, response);
        }
    }

    private void listFlightInstances(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<FlightInstance> instances = new ArrayList<>();
        Connection conn = null;

        try {
            conn = DBConnection.getConnection();
            String sql = "SELECT fi.*, " +
                    "fr.flight_number, fr.departure_airport_id, fr.arrival_airport_id, " +
                    "da.code as dep_code, da.name as dep_name, da.city as dep_city, da.country as dep_country, " +
                    "aa.code as arr_code, aa.name as arr_name, aa.city as arr_city, aa.country as arr_country, " +
                    "ac.registration, ac.model, ac.total_seats " +
                    "FROM flight_instances fi " +
                    "JOIN flight_routes fr ON fi.route_id = fr.id " +
                    "JOIN airports da ON fr.departure_airport_id = da.id " +
                    "JOIN airports aa ON fr.arrival_airport_id = aa.id " +
                    "LEFT JOIN aircrafts ac ON fi.aircraft_id = ac.id " +
                    "ORDER BY fi.departure_time DESC";

            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery(sql);

            while (rs.next()) {
                FlightInstance fi = new FlightInstance();
                fi.setId(rs.getInt("id"));
                fi.setRouteId(rs.getInt("route_id"));
                fi.setAircraftId(rs.getInt("aircraft_id"));
                fi.setDepartureTime(rs.getTimestamp("departure_time"));
                fi.setArrivalTime(rs.getTimestamp("arrival_time"));
                fi.setFlightDate(rs.getDate("flight_date"));
                fi.setBasePrice(rs.getDouble("base_price"));
                fi.setStatus(rs.getString("status"));

                // FlightRoute
                FlightRoute fr = new FlightRoute(
                        rs.getInt("route_id"),
                        rs.getString("flight_number"),
                        rs.getInt("departure_airport_id"),
                        rs.getInt("arrival_airport_id")
                );
                fr.setDepartureAirport(new Airport(
                        rs.getInt("departure_airport_id"),
                        rs.getString("dep_code"),
                        rs.getString("dep_name"),
                        rs.getString("dep_city"),
                        rs.getString("dep_country")
                ));
                fr.setArrivalAirport(new Airport(
                        rs.getInt("arrival_airport_id"),
                        rs.getString("arr_code"),
                        rs.getString("arr_name"),
                        rs.getString("arr_city"),
                        rs.getString("arr_country")
                ));
                fi.setRoute(fr);

                // Aircraft
                if (rs.getInt("aircraft_id") != 0) {
                    fi.setAircraft(new Aircraft(
                            rs.getInt("aircraft_id"),
                            rs.getString("registration"),
                            rs.getString("model"),
                            rs.getInt("total_seats")
                    ));
                }

                instances.add(fi);
            }

            rs.close();
            stmt.close();

        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBConnection.closeConnection(conn);
        }

        request.setAttribute("flightInstances", instances);
        request.getRequestDispatcher("/WEB-INF/jsp/flights/listFlightInstances.jsp")
               .forward(request, response);
    }

    private void showAddForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        loadFlightRoutesAndAircrafts(request);
        System.out.println("showAddForm - Routes loaded");
        request.getRequestDispatcher("/WEB-INF/jsp/flights/addFlightInstance.jsp").forward(request, response);
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        Connection conn = null;

        try {
            conn = DBConnection.getConnection();
            String sql = "SELECT fi.*, " +
                    "fr.flight_number, fr.departure_airport_id, fr.arrival_airport_id, " +
                    "da.code as dep_code, da.name as dep_name, da.city as dep_city, " +
                    "aa.code as arr_code, aa.name as arr_name, aa.city as arr_city, " +
                    "ac.registration, ac.model, ac.total_seats " +
                    "FROM flight_instances fi " +
                    "JOIN flight_routes fr ON fi.route_id = fr.id " +
                    "JOIN airports da ON fr.departure_airport_id = da.id " +
                    "JOIN airports aa ON fr.arrival_airport_id = aa.id " +
                    "LEFT JOIN aircrafts ac ON fi.aircraft_id = ac.id " +
                    "WHERE fi.id = ?";
            
            PreparedStatement stmt = conn.prepareStatement(sql);
            stmt.setInt(1, id);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                FlightInstance fi = new FlightInstance();
                fi.setId(rs.getInt("id"));
                fi.setRouteId(rs.getInt("route_id"));
                fi.setAircraftId(rs.getInt("aircraft_id"));
                fi.setDepartureTime(rs.getTimestamp("departure_time"));
                fi.setArrivalTime(rs.getTimestamp("arrival_time"));
                fi.setFlightDate(rs.getDate("flight_date"));
                fi.setBasePrice(rs.getDouble("base_price"));
                fi.setStatus(rs.getString("status"));
                request.setAttribute("flightInstance", fi);
            }

            rs.close();
            stmt.close();
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBConnection.closeConnection(conn);
        }

        loadFlightRoutesAndAircrafts(request);
        request.getRequestDispatcher("/WEB-INF/jsp/flights/editFlightInstance.jsp").forward(request, response);
    }

    private void addFlightInstance(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        Connection conn = null;

        try {
            conn = DBConnection.getConnection();
            String sql = "INSERT INTO flight_instances (route_id, aircraft_id, flight_date, " +
                    "departure_time, arrival_time, base_price, status) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?)";

            PreparedStatement stmt = conn.prepareStatement(sql);
            stmt.setInt(1, Integer.parseInt(request.getParameter("routeId")));
            stmt.setInt(2, Integer.parseInt(request.getParameter("aircraftId")));
            stmt.setDate(3, java.sql.Date.valueOf(request.getParameter("flightDate")));
            
            // Convertir le format datetime-local (yyyy-MM-ddTHH:mm) en Timestamp
            String depTimeStr = request.getParameter("departureTime").replace("T", " ") + ":00";
            String arrTimeStr = request.getParameter("arrivalTime").replace("T", " ") + ":00";
            
            stmt.setTimestamp(4, Timestamp.valueOf(depTimeStr));
            stmt.setTimestamp(5, Timestamp.valueOf(arrTimeStr));
            stmt.setDouble(6, Double.parseDouble(request.getParameter("basePrice")));
            stmt.setString(7, request.getParameter("status"));

            stmt.executeUpdate();
            stmt.close();

            HttpSession session = request.getSession();
            session.setAttribute("successMessage", "Instance de vol ajoutée avec succès");
        } catch (SQLException e) {
            e.printStackTrace();
            HttpSession session = request.getSession();
            session.setAttribute("errorMessage", "Erreur lors de l'ajout de l'instance de vol: " + e.getMessage());
        } catch (NumberFormatException | NullPointerException e) {
            e.printStackTrace();
            HttpSession session = request.getSession();
            session.setAttribute("errorMessage", "Erreur: vérifiez que tous les champs sont remplis correctement");
        } finally {
            DBConnection.closeConnection(conn);
        }

        response.sendRedirect("flight-instances");
    }

    private void updateFlightInstance(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        Connection conn = null;

        try {
            conn = DBConnection.getConnection();
            String sql = "UPDATE flight_instances SET route_id=?, aircraft_id=?, flight_date=?, " +
                    "departure_time=?, arrival_time=?, base_price=?, status=? WHERE id=?";

            PreparedStatement stmt = conn.prepareStatement(sql);
            stmt.setInt(1, Integer.parseInt(request.getParameter("routeId")));
            stmt.setInt(2, Integer.parseInt(request.getParameter("aircraftId")));
            stmt.setDate(3, java.sql.Date.valueOf(request.getParameter("flightDate")));
            
            // Convertir le format datetime-local (yyyy-MM-ddTHH:mm) en Timestamp
            String depTimeStr = request.getParameter("departureTime").replace("T", " ") + ":00";
            String arrTimeStr = request.getParameter("arrivalTime").replace("T", " ") + ":00";
            
            stmt.setTimestamp(4, Timestamp.valueOf(depTimeStr));
            stmt.setTimestamp(5, Timestamp.valueOf(arrTimeStr));
            stmt.setDouble(6, Double.parseDouble(request.getParameter("basePrice")));
            stmt.setString(7, request.getParameter("status"));
            stmt.setInt(8, Integer.parseInt(request.getParameter("id")));

            stmt.executeUpdate();
            stmt.close();

            HttpSession session = request.getSession();
            session.setAttribute("successMessage", "Instance de vol modifiée avec succès");
        } catch (SQLException e) {
            e.printStackTrace();
            HttpSession session = request.getSession();
            session.setAttribute("errorMessage", "Erreur lors de la modification de l'instance de vol");
        } finally {
            DBConnection.closeConnection(conn);
        }

        response.sendRedirect("flight-instances");
    }

    private void deleteFlightInstance(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        Connection conn = null;

        try {
            conn = DBConnection.getConnection();
            String sql = "DELETE FROM flight_instances WHERE id = ?";
            PreparedStatement stmt = conn.prepareStatement(sql);
            stmt.setInt(1, id);
            stmt.executeUpdate();
            stmt.close();

            HttpSession session = request.getSession();
            session.setAttribute("successMessage", "Instance de vol supprimée avec succès");
        } catch (SQLException e) {
            e.printStackTrace();
            HttpSession session = request.getSession();
            session.setAttribute("errorMessage", "Erreur lors de la suppression de l'instance de vol");
        } finally {
            DBConnection.closeConnection(conn);
        }

        response.sendRedirect("flight-instances");
    }

    private void loadFlightRoutesAndAircrafts(HttpServletRequest request) {
        Connection conn = null;

        try {
            conn = DBConnection.getConnection();

            // Charger les routes de vol
            List<FlightRoute> routes = new ArrayList<>();
            String sqlRoutes = "SELECT fr.*, " +
                    "da.code as dep_code, da.name as dep_name, da.city as dep_city, " +
                    "aa.code as arr_code, aa.name as arr_name, aa.city as arr_city " +
                    "FROM flight_routes fr " +
                    "JOIN airports da ON fr.departure_airport_id = da.id " +
                    "JOIN airports aa ON fr.arrival_airport_id = aa.id " +
                    "ORDER BY fr.flight_number";
            
            Statement stmt1 = conn.createStatement();
            ResultSet rs1 = stmt1.executeQuery(sqlRoutes);
            
            while (rs1.next()) {
                FlightRoute route = new FlightRoute(
                        rs1.getInt("id"),
                        rs1.getString("flight_number"),
                        rs1.getInt("departure_airport_id"),
                        rs1.getInt("arrival_airport_id")
                );
                route.setDepartureAirport(new Airport(
                        rs1.getInt("departure_airport_id"),
                        rs1.getString("dep_code"),
                        rs1.getString("dep_name"),
                        rs1.getString("dep_city"),
                        null
                ));
                route.setArrivalAirport(new Airport(
                        rs1.getInt("arrival_airport_id"),
                        rs1.getString("arr_code"),
                        rs1.getString("arr_name"),
                        rs1.getString("arr_city"),
                        null
                ));
                routes.add(route);
            }
            rs1.close();
            stmt1.close();

            System.out.println("Routes chargées: " + routes.size());

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

            System.out.println("Avions chargés: " + aircrafts.size());

            request.setAttribute("flightRoutes", routes);
            request.setAttribute("aircrafts", aircrafts);
        } catch (SQLException e) {
            e.printStackTrace();
            System.out.println("Erreur lors du chargement des routes et avions: " + e.getMessage());
        } finally {
            DBConnection.closeConnection(conn);
        }
    }

    private void showFlightDetails(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
    int flightInstanceId = 0;
    int aircraftId = 0;

    try {
        flightInstanceId = Integer.parseInt(request.getParameter("id"));
    } catch (NumberFormatException e) {
        response.sendRedirect("flight-instances");
        return;
    }

    // Récupérer l'ID de l'avion associé à l'instance
    Connection conn = null;
    try {
        conn = DBConnection.getConnection();
        String sql = "SELECT aircraft_id FROM flight_instances WHERE id = ?";
        PreparedStatement ps = conn.prepareStatement(sql);
        ps.setInt(1, flightInstanceId);
        ResultSet rs = ps.executeQuery();
        if (rs.next()) {
            aircraftId = rs.getInt("aircraft_id");
        } else {
            rs.close();
            ps.close();
            response.sendRedirect("flight-instances");
            return;
        }
        rs.close();
        ps.close();
    } catch (SQLException e) {
        e.printStackTrace();
        response.sendRedirect("flight-instances");
        return;
    } finally {
        DBConnection.closeConnection(conn);
    }

    // Récupérer le détail des classes pour cet avion et ce vol
    FlightSeatPriceDAO fspDAO = new FlightSeatPriceDAO();
    List<FlightSeatPriceDetail> details = new ArrayList<>();
    try {
        details = fspDAO.findClassDetailsByAircraftAndFlight(aircraftId, flightInstanceId);
    } catch (SQLException e) {
        e.printStackTrace();
    }
        BigDecimal totalMax = BigDecimal.ZERO;
    for (FlightSeatPriceDetail d : details) {
        BigDecimal seats = new BigDecimal(d.getTotalSeats());
        totalMax = totalMax.add(seats.multiply(d.getPrice()));
    }
    request.setAttribute("flightSeatDetails", details);
    request.setAttribute("totalMax", totalMax);
    request.setAttribute("flightInstanceId", flightInstanceId) ;


    request.setAttribute("flightDetails", details);
    request.getRequestDispatcher("/WEB-INF/jsp/flights/flightDetail.jsp").forward(request, response);
}

}