package main.project.dao;

import main.project.beans.Society;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class SocietyDAO {

    private Connection connection;

    public SocietyDAO(Connection connection) {
        this.connection = connection;
    }

    public void insert(Society society) throws SQLException {
        String sql = "INSERT INTO society (libelle) VALUES (?)";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, society.getLibelle());
            ps.executeUpdate();
        }
    }

    public Society findById(int id) throws SQLException {
        String sql = "SELECT * FROM society WHERE id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return new Society(
                        rs.getInt("id"),
                        rs.getString("libelle")
                );
            }
        }
        return null;
    }

    public List<Society> findAll() throws SQLException {
        List<Society> list = new ArrayList<>();
        String sql = "SELECT * FROM society";

        try (Statement st = connection.createStatement();
             ResultSet rs = st.executeQuery(sql)) {

            while (rs.next()) {
                list.add(new Society(
                        rs.getInt("id"),
                        rs.getString("libelle")
                ));
            }
        }
        return list;
    }
}
