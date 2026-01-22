package main.project.dao;



import main.project.beans.AircraftClass;
import main.project.utils.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class AircraftClassDAO {

    public AircraftClass save(AircraftClass ac) throws SQLException {
        String sql = "INSERT INTO aircraft_class (libelle) VALUES (?) RETURNING id";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, ac.getLibelle());
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                ac.setId(rs.getInt("id"));
            }
        }
        return ac;
    }

    public List<AircraftClass> findAll() throws SQLException {
        List<AircraftClass> list = new ArrayList<>();
        String sql = "SELECT * FROM aircraft_class";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                AircraftClass ac = new AircraftClass();
                ac.setId(rs.getInt("id"));
                ac.setLibelle(rs.getString("libelle"));
                list.add(ac);
            }
        }
        return list;
    }
}
