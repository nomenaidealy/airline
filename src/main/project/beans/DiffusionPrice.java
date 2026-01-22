package main.project.beans;

import java.math.BigDecimal;
import java.time.LocalDate;

public class DiffusionPrice {

    private int id;
    private BigDecimal montant;
    private LocalDate dateDebut;
    private LocalDate dateFin; // null si actif

    public DiffusionPrice() {
    }

    public DiffusionPrice(int id, BigDecimal montant, LocalDate dateDebut, LocalDate dateFin) {
        this.id = id;
        this.montant = montant;
        this.dateDebut = dateDebut;
        this.dateFin = dateFin;
    }

    // Getters & Setters
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public BigDecimal getMontant() {
        return montant;
    }

    public void setMontant(BigDecimal montant) {
        this.montant = montant;
    }

    public LocalDate getDateDebut() {
        return dateDebut;
    }

    public void setDateDebut(LocalDate dateDebut) {
        this.dateDebut = dateDebut;
    }

    public LocalDate getDateFin() {
        return dateFin;
    }

    public void setDateFin(LocalDate dateFin) {
        this.dateFin = dateFin;
    }

    public boolean isActif() {
        return dateFin == null || dateFin.isAfter(LocalDate.now());
    }

    @Override
    public String toString() {
        return montant + " Ar";
    }
}

