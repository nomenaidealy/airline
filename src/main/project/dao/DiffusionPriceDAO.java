package main.project.dao;

import main.project.beans.DiffusionPrice;

import java.sql.*;
import java.math.BigDecimal;
import java.time.LocalDate;

public class DiffusionPriceDAO {

    private Connection connection;

    public DiffusionPriceDAO(Connection connection) {
        this.connection = connection;
    }

    public void insert(DiffusionPrice price) throws SQLException {
        String sql = """
            INSERT INTO diffusion_price (montant, date_debut, date_fin)
            VALUES (?, ?, ?)
        """;

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setBigDecimal(1, price.getMontant());
            ps.setDate(2, Date.valueOf(price.getDateDebut()));

            if (price.getDateFin() != null) {
                ps.setDate(3, Date.valueOf(price.getDateFin()));
            } else {
                ps.setNull(3, Types.DATE);
            }

            ps.executeUpdate();
        }
    }

    public DiffusionPrice findById(int id) throws SQLException {
        String sql = "SELECT * FROM diffusion_price WHERE id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return map(rs);
            }
        }
        return null;
    }

    /**
     * Récupère le prix actif à une date donnée
     */
    public DiffusionPrice findActiveByDate(LocalDate date) throws SQLException {
        String sql = """
            SELECT * FROM diffusion_price
            WHERE date_debut <= ?
              AND (date_fin IS NULL OR date_fin >= ?)
            ORDER BY date_debut DESC
            LIMIT 1
        """;

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setDate(1, Date.valueOf(date));
            ps.setDate(2, Date.valueOf(date));
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return map(rs);
            }
        }
        return null;
    }

    private DiffusionPrice map(ResultSet rs) throws SQLException {
        DiffusionPrice p = new DiffusionPrice();
        p.setId(rs.getInt("id"));
        p.setMontant(rs.getBigDecimal("montant"));
        p.setDateDebut(rs.getDate("date_debut").toLocalDate());

        Date fin = rs.getDate("date_fin");
        if (fin != null) {
            p.setDateFin(fin.toLocalDate());
        }
        return p;
    }
}
