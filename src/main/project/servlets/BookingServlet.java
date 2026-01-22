package main.project.servlets;

import main.project.beans.*;
import main.project.utils.DBConnection;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.io.PrintWriter;
import java.math.BigDecimal;
import java.sql.*;
import java.sql.Date;
import java.util.*;

@WebServlet("/bookings")
public class BookingServlet extends HttpServlet {

    // ========================== DOGET / DOPOST ==========================
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        if (action == null) action = "list";

        switch (action) {
            case "new":
                showNewBookingForm(request, response);
                break;
            case "selectFlight":
                showFlightSelection(request, response);
                break;
            case "cancel":
                cancelBooking(request, response);
                break;
            default:
                listBookings(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        switch (action) {
            case "createPassenger":
                createPassenger(request, response);
                break;
            case "createBooking":
                createBooking(request, response);
                break;
            case "createMultipleBookings":
                createMultipleBookings(request, response);
                break;
            case "searchPassenger":
                searchPassenger(request, response);
                break;
        }
    }

    // ========================== LIST BOOKINGS ==========================
    private void listBookings(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        List<Booking> bookings = new ArrayList<>();
        String sql = "SELECT b.*, p.*, fi.*, fr.*, da.code AS dep_code, da.city AS dep_city, " +
                     "aa.code AS arr_code, aa.city AS arr_city, ac.registration " +
                     "FROM bookings b " +
                     "JOIN passengers p ON b.passenger_id = p.id " +
                     "JOIN flight_instances fi ON b.flight_instance_id = fi.id " +
                     "JOIN flight_routes fr ON fi.route_id = fr.id " +
                     "JOIN airports da ON fr.departure_airport_id = da.id " +
                     "JOIN airports aa ON fr.arrival_airport_id = aa.id " +
                     "LEFT JOIN aircrafts ac ON fi.aircraft_id = ac.id " +
                     "ORDER BY b.booking_date DESC";

        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                Booking b = new Booking();
                b.setId(rs.getInt("id"));
                b.setBookingReference(rs.getString("booking_reference"));
                b.setSeatNumber(rs.getString("seat_number"));
                b.setBookingDate(rs.getTimestamp("booking_date"));
                b.setTotalAmount(rs.getDouble("total_amount"));
                b.setStatus(rs.getString("status"));

                Passenger p = new Passenger();
                p.setId(rs.getInt("passenger_id"));
                p.setFirstName(rs.getString("first_name"));
                p.setLastName(rs.getString("last_name"));
                p.setEmail(rs.getString("email"));
                b.setPassenger(p);

                Flight f = new Flight();
                f.setId(rs.getInt("flight_instance_id"));
                f.setFlightNumber(rs.getString("flight_number"));
                f.setDepartureTime(rs.getTimestamp("departure_time"));
                f.setArrivalTime(rs.getTimestamp("arrival_time"));
                f.setBasePrice(rs.getDouble("base_price"));

                Airport dep = new Airport();
                dep.setCode(rs.getString("dep_code"));
                dep.setCity(rs.getString("dep_city"));
                f.setDepartureAirport(dep);

                Airport arr = new Airport();
                arr.setCode(rs.getString("arr_code"));
                arr.setCity(rs.getString("arr_city"));
                f.setArrivalAirport(arr);

                Aircraft ac = new Aircraft();
                ac.setRegistration(rs.getString("registration"));
                f.setAircraft(ac);

                b.setFlight(f);
                bookings.add(b);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        request.setAttribute("bookings", bookings);
        request.getRequestDispatcher("/WEB-INF/jsp/bookings/listBookings.jsp").forward(request, response);
    }

    // ========================== NEW BOOKING FORM ==========================
    private void showNewBookingForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int flightInstanceId = Integer.parseInt(request.getParameter("flightId"));
        request.getRequestDispatcher("/WEB-INF/jsp/bookings/newBooking.jsp").forward(request, response);
    }

    // ========================== SELECT FLIGHT ==========================
    private void showFlightSelection(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int passengerId = Integer.parseInt(request.getParameter("passengerId"));
        int flightInstanceId = Integer.parseInt(request.getParameter("flightId"));

        try (Connection conn = DBConnection.getConnection()) {

            // Charger le passager
            String sql = "SELECT * FROM passengers WHERE id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, passengerId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        Passenger p = new Passenger(
                                rs.getInt("id"),
                                rs.getString("first_name"),
                                rs.getString("last_name"),
                                rs.getString("email"),
                                rs.getString("phone"),
                                rs.getString("passport_number"),
                                rs.getDate("date_of_birth")
                        );
                        request.setAttribute("passenger", p);
                        request.setAttribute("passengerId", p.getId());
                    }
                }
            }

            // Charger les vols
            loadAvailableFlights(request);

            // Charger les sièges + prix adulte/enfant
            loadAvailableSeatsForFlight(request, flightInstanceId);

            request.setAttribute("flightInstanceId", flightInstanceId);

        } catch (SQLException e) {
            e.printStackTrace();
        }

        request.getRequestDispatcher("/WEB-INF/jsp/bookings/selectSeatType.jsp").forward(request, response);
    }

    // ========================== CREATE PASSENGER ==========================
    private void createPassenger(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int flightInstanceId = Integer.parseInt(request.getParameter("flightInstanceId"));

        try (Connection conn = DBConnection.getConnection()) {
            String sql = "INSERT INTO passengers (first_name,last_name,email,phone,passport_number,date_of_birth) VALUES (?,?,?,?,?,?)";
            try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
                ps.setString(1, request.getParameter("firstName"));
                ps.setString(2, request.getParameter("lastName"));
                ps.setString(3, request.getParameter("email"));
                ps.setString(4, request.getParameter("phone"));
                ps.setString(5, request.getParameter("passportNumber"));
                ps.setDate(6, java.sql.Date.valueOf(request.getParameter("dateOfBirth")));
                ps.executeUpdate();

                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        int passengerId = rs.getInt(1);

                        Passenger p = new Passenger();
                        p.setId(passengerId);
                        p.setFirstName(request.getParameter("firstName"));
                        p.setLastName(request.getParameter("lastName"));
                        p.setEmail(request.getParameter("email"));
                        p.setPhone(request.getParameter("phone"));
                        p.setPassportNumber(request.getParameter("passportNumber"));
                        p.setDateOfBirth(java.sql.Date.valueOf(request.getParameter("dateOfBirth")));

                        request.setAttribute("passenger", p);

                        // Chargement des sièges + prix adulte/enfant
                        loadAvailableSeatsForFlight(request, flightInstanceId);

                        request.getRequestDispatcher("/WEB-INF/jsp/bookings/selectSeatType.jsp").forward(request, response);
                        return;
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Erreur création passager: " + e.getMessage());
            request.getRequestDispatcher("/WEB-INF/jsp/bookings/newBooking.jsp").forward(request, response);
        }
    }

    // ========================== LOAD SEATS WITH PRICES ==========================
    private void loadAvailableSeatsForFlight(HttpServletRequest request, int flightInstanceId) {
        List<FlightSeatPriceDetail> details = new ArrayList<>();
        String sql = """
            SELECT 
                acs.id AS aircraft_class_seat_id,
                ac.libelle AS class_name,
                acs.nombre_seat AS total_seats,
                (acs.nombre_seat - COALESCE(b.booked_count,0)) AS available_seats,
                fsp.prix_base AS adult_price,
                fsp.child_price AS child_price
            FROM flight_instances fi
            JOIN aircrafts a ON fi.aircraft_id = a.id
            JOIN aircraft_class_seat acs ON acs.id_aircraft = a.id
            JOIN aircraft_class ac ON acs.id_aircraftClass = ac.id
            LEFT JOIN flight_seat_price fsp 
                ON fsp.id_aircraftClassSeat = acs.id
               AND fsp.id_flight_instance = fi.id
            LEFT JOIN (
                SELECT id_aircraftClassSeat, COUNT(*) AS booked_count
                FROM bookings
                WHERE flight_instance_id=? AND status='confirmed'
                GROUP BY id_aircraftClassSeat
            ) b ON b.id_aircraftClassSeat = acs.id
            WHERE fi.id=?
            ORDER BY ac.id
        """;

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, flightInstanceId);
            ps.setInt(2, flightInstanceId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    FlightSeatPriceDetail d = new FlightSeatPriceDetail();
                    d.setAircraftClassSeatId(rs.getInt("aircraft_class_seat_id"));
                    d.setClassName(rs.getString("class_name"));
                    d.setTotalSeats(rs.getInt("total_seats"));
                    d.setAvailableSeats(rs.getInt("available_seats"));
                    d.setPrice(rs.getBigDecimal("adult_price"));
                    d.setChildPrice(rs.getBigDecimal("child_price"));
                    details.add(d);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        request.setAttribute("flightDetails", details);
    }

    // ========================== CREATE MULTIPLE BOOKINGS ==========================
// ========================== CREATE MULTIPLE BOOKINGS ==========================
private void createMultipleBookings(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {

    int passengerId = Integer.parseInt(request.getParameter("passengerId"));
    int flightInstanceId = Integer.parseInt(request.getParameter("flightInstanceId"));
    HttpSession session = request.getSession();
    int totalCreated = 0;

    try (Connection conn = DBConnection.getConnection()) {

        Map<String, String[]> params = request.getParameterMap();

        // 1️⃣ Récupérer tous les sièges déjà réservés pour ce vol
        Set<String> reservedSeats = new HashSet<>();
        String sqlSeats = "SELECT seat_number FROM bookings WHERE flight_instance_id=? AND status='confirmed'";
        try (PreparedStatement psSeats = conn.prepareStatement(sqlSeats)) {
            psSeats.setInt(1, flightInstanceId);
            try (ResultSet rs = psSeats.executeQuery()) {
                while (rs.next()) reservedSeats.add(rs.getString("seat_number"));
            }
        }

        // 2️⃣ Parcourir les classes et le nombre de sièges à réserver
        for (String paramName : params.keySet()) {

            if (paramName.startsWith("seatsToBookAdult_")) {
                int aircraftClassSeatId = Integer.parseInt(paramName.replace("seatsToBookAdult_", ""));
                int seatsAdult = Integer.parseInt(params.get(paramName)[0]);

                int seatsChild = 0;
                String childParam = "seatsToBookChild_" + aircraftClassSeatId;
                if (params.containsKey(childParam)) seatsChild = Integer.parseInt(params.get(childParam)[0]);

                int seatsBaby = 0;
                String babyParam = "seatsToBookBaby_" + aircraftClassSeatId;
                if (params.containsKey(babyParam)) seatsBaby = Integer.parseInt(params.get(babyParam)[0]);

                int seatsToBook = seatsAdult + seatsChild + seatsBaby;
                if (seatsToBook <= 0) continue;

                // Récupérer prix adulte et enfant
                double adultPrice = getSeatPrice(conn, flightInstanceId, aircraftClassSeatId);
                double childPrice = getChildSeatPrice(conn, flightInstanceId, aircraftClassSeatId);
                double babyPrice = adultPrice * 0.1; // 10% du prix adulte

                // Nombre total de sièges pour cette classe
                int totalSeats = 0;
                String sqlTotalSeats = "SELECT nombre_seat FROM aircraft_class_seat WHERE id=?";
                try (PreparedStatement psTotal = conn.prepareStatement(sqlTotalSeats)) {
                    psTotal.setInt(1, aircraftClassSeatId);
                    try (ResultSet rs = psTotal.executeQuery()) {
                        if (rs.next()) totalSeats = rs.getInt("nombre_seat");
                    }
                }

                // Requête d'insertion
                String sqlInsert = "INSERT INTO bookings " +
                        "(booking_reference, flight_instance_id, passenger_id, seat_number, aircraft_class_seat_id, total_amount, child_count, baby_count, status) " +
                        "VALUES (?,?,?,?,?,?,?,?,?)";

                try (PreparedStatement psInsert = conn.prepareStatement(sqlInsert)) {

                    int booked = 0;
                    outer:
                    for (int row = 1; row <= totalSeats && booked < seatsToBook; row++) {
                        for (char col = 'A'; col <= 'F' && booked < seatsToBook; col++) {
                            String seatNumberStr = row + "" + col;
                            if (reservedSeats.contains(seatNumberStr)) continue;

                            String ref = generateBookingReference(conn);

                            double price;
                            int childCount = 0;
                            int babyCount = 0;

                            if (booked < seatsAdult) {
                                price = adultPrice;
                            } else if (booked < seatsAdult + seatsChild) {
                                price = childPrice;
                                childCount = 1;
                            } else {
                                price = babyPrice;
                                babyCount = 1;
                            }

                            psInsert.setString(1, ref);
                            psInsert.setInt(2, flightInstanceId);
                            psInsert.setInt(3, passengerId);
                            psInsert.setString(4, seatNumberStr);
                            psInsert.setInt(5, aircraftClassSeatId);
                            psInsert.setDouble(6, price);
                            psInsert.setInt(7, childCount);
                            psInsert.setInt(8, babyCount);
                            psInsert.setString(9, "confirmed");

                            int inserted = psInsert.executeUpdate();
                            if (inserted > 0) {
                                reservedSeats.add(seatNumberStr);
                                totalCreated++;
                                booked++;
                            }
                        }
                    }

                    if (booked < seatsToBook) {
                        session.setAttribute("errorMessage", "Pas assez de sièges disponibles pour la classe " + aircraftClassSeatId);
                        break;
                    }
                }
            }
        }

        session.setAttribute("successMessage", totalCreated + " réservation(s) créée(s) avec succès");

    } catch (Exception e) {
        e.printStackTrace();
        session.setAttribute("errorMessage", "Erreur lors de la création des réservations: " + e.getMessage());
    }

    // 🔹 Rediriger vers le détail du vol avec toutes les réservations
    request.setAttribute("flightInstanceId", flightInstanceId);
    listBookingsForFlight(request, response, flightInstanceId);
}


  // ========================== LIST BOOKINGS FOR FLIGHT ==========================
private void listBookingsForFlight(HttpServletRequest request, HttpServletResponse response, int flightInstanceId)
        throws ServletException, IOException {

    List<Booking> bookings = new ArrayList<>();

    String sql = "SELECT b.*, p.first_name, p.last_name, p.email, " +
                 "b.aircraft_class_seat_id, b.child_count, b.baby_count " +
                 "FROM bookings b " +
                 "JOIN passengers p ON b.passenger_id = p.id " +
                 "WHERE b.flight_instance_id=? AND b.status='confirmed' " +
                 "ORDER BY b.booking_date";

    try (Connection conn = DBConnection.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql)) {

        ps.setInt(1, flightInstanceId);

        try (ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Booking b = new Booking();
                b.setId(rs.getInt("id"));
                b.setBookingReference(rs.getString("booking_reference"));
                b.setSeatNumber(rs.getString("seat_number"));
                b.setBookingDate(rs.getTimestamp("booking_date"));
                b.setTotalAmount(rs.getDouble("total_amount"));
                b.setStatus(rs.getString("status"));

                b.setAircraftClassSeatId(rs.getInt("aircraft_class_seat_id"));
                b.setChildCount(rs.getInt("child_count"));
                b.setBabyCount(rs.getInt("baby_count"));

                Passenger p = new Passenger();
                p.setId(rs.getInt("passenger_id"));
                p.setFirstName(rs.getString("first_name"));
                p.setLastName(rs.getString("last_name"));
                p.setEmail(rs.getString("email"));
                b.setPassenger(p);

                bookings.add(b);
            }
        }

    } catch (SQLException e) {
        e.printStackTrace();
        request.setAttribute("errorMessage", "Erreur lors de la récupération des réservations: " + e.getMessage());
    }

    request.setAttribute("bookings", bookings);
    request.getRequestDispatcher("/WEB-INF/jsp/bookings/detail.jsp").forward(request, response);
}




    // ========================== GET PRICES ==========================
    private double getSeatPrice(Connection conn, int flightInstanceId, int aircraftClassSeatId) throws SQLException {
        String sql = "SELECT prix_base FROM flight_seat_price WHERE id_flight_instance=? AND id_aircraftClassSeat=?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, flightInstanceId);
            ps.setInt(2, aircraftClassSeatId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getDouble("prix_base");
            }
        }
        return 0.0;
    }

    private double getChildSeatPrice(Connection conn, int flightInstanceId, int aircraftClassSeatId) throws SQLException {
        String sql = "SELECT child_price FROM flight_seat_price WHERE id_flight_instance=? AND id_aircraftClassSeat=?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, flightInstanceId);
            ps.setInt(2, aircraftClassSeatId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getDouble("child_price");
            }
        }
        return 0.0;
    }

    // ========================== CREATE SINGLE BOOKING ==========================
    private void createBooking(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        int passengerId = Integer.parseInt(request.getParameter("passengerId"));
        int flightInstanceId = Integer.parseInt(request.getParameter("flightInstanceId"));
        int aircraftClassSeatId = Integer.parseInt(request.getParameter("aircraftClassSeatId"));
        int seatIndex = Integer.parseInt(request.getParameter("seatIndex"));

        try (Connection conn = DBConnection.getConnection()) {

            int realSeatNumber = computeRealSeatNumber(conn, aircraftClassSeatId, seatIndex);

            if (isSeatOccupied(conn, flightInstanceId, aircraftClassSeatId, realSeatNumber)) {
                request.getSession().setAttribute("errorMessage", "Siège déjà occupé");
                response.sendRedirect("bookings");
                return;
            }

            double price = getSeatPrice(conn, flightInstanceId, aircraftClassSeatId);
            String bookingRef = generateBookingReference(conn);

            String sql =
                    "INSERT INTO bookings " +
                    "(booking_reference, flight_instance_id, passenger_id, seat_number, aircraft_class_seat_id, total_amount, status) " +
                    "VALUES (?,?,?,?,?,?,'confirmed')";

            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, bookingRef);
                ps.setInt(2, flightInstanceId);
                ps.setInt(3, passengerId);
                ps.setInt(4, realSeatNumber);
                ps.setInt(5, aircraftClassSeatId);
                ps.setDouble(6, price);
                ps.executeUpdate();
            }

            request.getSession().setAttribute("successMessage", "Réservation créée : " + bookingRef);
            response.sendRedirect("bookings");

        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("errorMessage", e.getMessage());
            response.sendRedirect("bookings");
        }
    }

    // ========================== CANCEL BOOKING ==========================
    private void cancelBooking(HttpServletRequest request, HttpServletResponse response) throws IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        try (Connection conn = DBConnection.getConnection()) {
            String sql = "UPDATE bookings SET status='cancelled' WHERE id=?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, id);
                ps.executeUpdate();
            }
            request.getSession().setAttribute("successMessage", "Réservation annulée avec succès");
        } catch (SQLException e) {
            e.printStackTrace();
            request.getSession().setAttribute("errorMessage", "Erreur lors de l'annulation");
        }
        response.sendRedirect("bookings");
    }

    // ========================== UTILITAIRES ==========================
    private boolean isSeatOccupied(Connection conn, int flightInstanceId, int aircraftClassSeatId, int seatNumber) throws SQLException {
        String sql = "SELECT COUNT(*) FROM bookings WHERE flight_instance_id=? AND aircraft_class_seat_id=? AND seat_number=? AND status='confirmed'";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, flightInstanceId);
            ps.setInt(2, aircraftClassSeatId);
            ps.setInt(3, seatNumber);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        }
    }

    private int computeRealSeatNumber(Connection conn, int aircraftClassSeatId, int seatIndex) throws SQLException {
        // à adapter si tu veux calculer un offset réel
        return seatIndex;
    }

    private String generateBookingReference(Connection conn) throws SQLException {
        Random r = new Random();
        String ref;
        while (true) {
            ref = "AIR" + 2026 + String.format("%05d", r.nextInt(100000));
            String sql = "SELECT COUNT(*) FROM bookings WHERE booking_reference=?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, ref);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next() && rs.getInt(1) == 0) return ref;
                }
            }
        }
    }

    private void loadAvailableFlights(HttpServletRequest request) {
        List<FlightInstance> flights = new ArrayList<>();
        String sql = "SELECT fi.*, fr.flight_number, fr.departure_airport_id, fr.arrival_airport_id, " +
                     "da.code dep_code, da.name dep_name, da.city dep_city, " +
                     "aa.code arr_code, aa.name arr_name, aa.city arr_city, " +
                     "ac.id aircraft_id, ac.registration, ac.model, ac.total_seats " +
                     "FROM flight_instances fi " +
                     "JOIN flight_routes fr ON fi.route_id=fr.id " +
                     "JOIN airports da ON fr.departure_airport_id=da.id " +
                     "JOIN airports aa ON fr.arrival_airport_id=aa.id " +
                     "LEFT JOIN aircrafts ac ON fi.aircraft_id=ac.id " +
                     "WHERE fi.status='scheduled' AND fi.departure_time>CURRENT_TIMESTAMP " +
                     "ORDER BY fi.departure_time";

        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                FlightInstance fi = new FlightInstance();
                fi.setId(rs.getInt("id"));
                fi.setRouteId(rs.getInt("route_id"));
                fi.setDepartureTime(rs.getTimestamp("departure_time"));
                fi.setArrivalTime(rs.getTimestamp("arrival_time"));
                fi.setFlightDate(rs.getDate("flight_date"));
                fi.setBasePrice(rs.getDouble("base_price"));
                fi.setStatus(rs.getString("status"));
                flights.add(fi);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        request.setAttribute("flightInstances", flights);
    }

    // ========================== SEARCH PASSENGER ==========================
    private void searchPassenger(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String passportNumber = request.getParameter("passportNumber");
        int flightInstanceId = Integer.parseInt(request.getParameter("flightId"));
        try (Connection conn = DBConnection.getConnection()) {
            String sql = "SELECT id FROM passengers WHERE passport_number = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, passportNumber);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        response.sendRedirect("bookings?action=selectFlight&passengerId=" + rs.getInt("id") + "&flightId=" + flightInstanceId);
                        return;
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        request.setAttribute("errorMessage", "Aucun passager trouvé avec ce numéro de passeport");
        request.getRequestDispatcher("/WEB-INF/jsp/bookings/newBooking.jsp").forward(request, response);
    }
}
