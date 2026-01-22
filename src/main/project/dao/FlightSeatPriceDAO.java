package main.project.dao;

import main.project.beans.FlightSeatPrice;
import main.project.utils.DBConnection;
import main.project.beans.FlightSeatPriceDetail;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.math.BigDecimal;


public class FlightSeatPriceDAO {

    // Sauvegarder un prix
    public FlightSeatPrice save(FlightSeatPrice price) throws SQLException {
        String sql = "INSERT INTO flight_seat_price (id_aircraftClassSeat, id_flight_instance, prix_base) VALUES (?, ?, ?) RETURNING id";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, price.getAircraftClassSeatId());
            ps.setInt(2, price.getFlightInstanceId());
            ps.setBigDecimal(3, price.getPrixBase());

            ResultSet rs = ps.executeQuery();
            if (rs.next()) price.setId(rs.getInt("id"));
        }
        return price;
    }

    // Récupérer tous les FlightSeatPrice pour un vol spécifique
    public List<FlightSeatPrice> findByFlightInstanceId(int flightInstanceId) throws SQLException {
        List<FlightSeatPrice> list = new ArrayList<>();
        String sql = "SELECT * FROM flight_seat_price WHERE id_flight_instance = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, flightInstanceId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                FlightSeatPrice fsp = new FlightSeatPrice();
                fsp.setId(rs.getInt("id"));
                fsp.setAircraftClassSeatId(rs.getInt("id_aircraftClassSeat"));
                fsp.setFlightInstanceId(rs.getInt("id_flight_instance"));
                fsp.setPrixBase(rs.getBigDecimal("prix_base"));
                list.add(fsp);
            }
        }
        return list;
    }

    // =============================================
    // Récupérer le détail des classes pour un avion et un vol précis
    // =============================================
 public List<FlightSeatPriceDetail> findClassDetailsByAircraftAndFlight(int aircraftId, int flightInstanceId) throws SQLException {
    List<FlightSeatPriceDetail> list = new ArrayList<>();
    String sql = """
        SELECT
            fi.id AS flight_instance_id,
            fr.flight_number,
            a.registration AS aircraft_registration,
            acs.id AS aircraft_class_seat_id,
            ac.libelle AS class_name,
            acs.nombre_seat AS total_seats,
            (acs.nombre_seat - COALESCE(b.booked_count, 0)) AS available_seats,
            fsp.prix_base AS price
        FROM flight_instances fi
        JOIN flight_routes fr ON fi.route_id = fr.id
        JOIN aircrafts a ON fi.aircraft_id = a.id
        JOIN aircraft_class_seat acs ON acs.id_aircraft = a.id
        JOIN aircraft_class ac ON acs.id_aircraftClass = ac.id
        LEFT JOIN flight_seat_price fsp 
              ON fsp.id_aircraftClassSeat = acs.id
             AND fsp.id_flight_instance = fi.id
        LEFT JOIN (
            SELECT fi.id AS flight_instance_id, acs.id AS aircraft_class_seat_id, COUNT(b.id) AS booked_count
            FROM bookings b
            JOIN flight_instances fi ON b.flight_instance_id = fi.id
            JOIN aircraft_class_seat acs ON acs.id_aircraft = fi.aircraft_id
            WHERE b.status = 'confirmed'
            GROUP BY fi.id, acs.id
        ) b ON b.flight_instance_id = fi.id
             AND b.aircraft_class_seat_id = acs.id
        WHERE a.id = ?
          AND fi.id = ?
        ORDER BY ac.id
        """;

    try (Connection conn = DBConnection.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql)) {

        ps.setInt(1, aircraftId);
        ps.setInt(2, flightInstanceId);

        try (ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                FlightSeatPriceDetail detail = new FlightSeatPriceDetail();
                detail.setFlightInstanceId(rs.getInt("flight_instance_id"));
                detail.setFlightNumber(rs.getString("flight_number"));
                detail.setAircraftRegistration(rs.getString("aircraft_registration"));
                detail.setAircraftClassSeatId(rs.getInt("aircraft_class_seat_id"));
                detail.setClassName(rs.getString("class_name"));
                detail.setTotalSeats(rs.getInt("total_seats"));
                detail.setAvailableSeats(rs.getInt("available_seats"));
                BigDecimal price = rs.getBigDecimal("price");
                detail.setPrice(price != null ? price : BigDecimal.ZERO);

                list.add(detail);
            }
        }
    }

    return list;
}





}
