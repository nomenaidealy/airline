package main.project.dao;

import main.project.beans.AircraftClassSeat;
import main.project.utils.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class AircraftClassSeatDAO {

    public AircraftClassSeat save(AircraftClassSeat seat) throws SQLException {
        String sql = "INSERT INTO aircraft_class_seat (id_aircraft, id_aircraftClass, nombre_seat) VALUES (?, ?, ?) RETURNING id";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, seat.getAircraftId());
            ps.setInt(2, seat.getAircraftClassId());
            ps.setInt(3, seat.getNombreSeat());

            ResultSet rs = ps.executeQuery();
            if (rs.next()) seat.setId(rs.getInt("id"));
        }
        return seat;
    }

    public List<AircraftClassSeat> findByAircraftId(int aircraftId) throws SQLException {
        List<AircraftClassSeat> list = new ArrayList<>();
        String sql = "SELECT * FROM aircraft_class_seat WHERE id_aircraft = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, aircraftId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                AircraftClassSeat seat = new AircraftClassSeat();
                seat.setId(rs.getInt("id"));
                seat.setAircraftId(rs.getInt("id_aircraft"));
                seat.setAircraftClassId(rs.getInt("id_aircraftClass"));
                seat.setNombreSeat(rs.getInt("nombre_seat"));
                list.add(seat);
            }
        }
        return list;
    }
}
