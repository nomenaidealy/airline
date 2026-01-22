package main.project.beans;

import java.time.LocalDate;
import java.time.LocalTime;

public class Diffusion {

    private int id;
    private Society society;
    private DiffusionPrice diffusionPrice;
    private int flightInstanceId;   // ID du vol
    private LocalDate diffusionDate;
    private int nombreDiffusion;

    // Champs temporaires pour affichage vol
    private String departureAirportName;
    private String arrivalAirportName;
    private LocalTime departureTime;

    public Diffusion() { }

    public Diffusion(int id, Society society, DiffusionPrice diffusionPrice,
                     int flightInstanceId, LocalDate diffusionDate, int nombreDiffusion) {
        this.id = id;
        this.society = society;
        this.diffusionPrice = diffusionPrice;
        this.flightInstanceId = flightInstanceId;
        this.diffusionDate = diffusionDate;
        this.nombreDiffusion = nombreDiffusion;
    }

    // ================= GETTERS / SETTERS =================
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public Society getSociety() { return society; }
    public void setSociety(Society society) { this.society = society; }

    public DiffusionPrice getDiffusionPrice() { return diffusionPrice; }
    public void setDiffusionPrice(DiffusionPrice diffusionPrice) { this.diffusionPrice = diffusionPrice; }

    public int getFlightInstanceId() { return flightInstanceId; }
    public void setFlightInstanceId(int flightInstanceId) { this.flightInstanceId = flightInstanceId; }

    public LocalDate getDiffusionDate() { return diffusionDate; }
    public void setDiffusionDate(LocalDate diffusionDate) { this.diffusionDate = diffusionDate; }

    public int getNombreDiffusion() { return nombreDiffusion; }
    public void setNombreDiffusion(int nombreDiffusion) { this.nombreDiffusion = nombreDiffusion; }

    // ================= Champs temporaires =================
    public String getDepartureAirportName() { return departureAirportName; }
    public void setDepartureAirportName(String departureAirportName) { this.departureAirportName = departureAirportName; }

    public String getArrivalAirportName() { return arrivalAirportName; }
    public void setArrivalAirportName(String arrivalAirportName) { this.arrivalAirportName = arrivalAirportName; }

    public LocalTime getDepartureTime() { return departureTime; }
    public void setDepartureTime(LocalTime departureTime) { this.departureTime = departureTime; }

    // ================= MÉTHODES MÉTIER =================
    public double getMontantTotal() {
        return diffusionPrice.getMontant().doubleValue() * nombreDiffusion;
    }

    @Override
    public String toString() {
        return society.getLibelle() + " - vol " + flightInstanceId + " - " + nombreDiffusion + " diffusions";
    }
}
