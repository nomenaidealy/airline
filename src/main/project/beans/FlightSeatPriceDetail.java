package main.project.beans;

import java.math.BigDecimal;

public class FlightSeatPriceDetail {

    private int flightInstanceId;      // ID de l'instance de vol
    private String flightNumber;       // Numéro du vol
    private String aircraftRegistration; // Immatriculation de l'avion
    private String className;          // Libellé de la classe (Economy, Business, etc.)
    private int totalSeats;            // Nombre total de sièges dans cette classe
    private int availableSeats;        // Nombre de sièges disponibles
    private BigDecimal price;          // Prix adulte pour cette classe sur ce vol
    private BigDecimal childPrice;     // Prix enfant pour cette classe sur ce vol
    private int aircraftClassSeatId;   // ID de la classe de l'avion

    // ================== Constructeurs ==================
    public FlightSeatPriceDetail() {}

    public FlightSeatPriceDetail(int flightInstanceId, String flightNumber, String aircraftRegistration,
                                 String className, int totalSeats, int availableSeats, BigDecimal price, BigDecimal childPrice) {
        this.flightInstanceId = flightInstanceId;
        this.flightNumber = flightNumber;
        this.aircraftRegistration = aircraftRegistration;
        this.className = className;
        this.totalSeats = totalSeats;
        this.availableSeats = availableSeats;
        this.price = price;
        this.childPrice = childPrice;
    }

    // ================== Getters et Setters ==================
    public int getFlightInstanceId() {
        return flightInstanceId;
    }

    public void setFlightInstanceId(int flightInstanceId) {
        this.flightInstanceId = flightInstanceId;
    }

    public String getFlightNumber() {
        return flightNumber;
    }

    public void setFlightNumber(String flightNumber) {
        this.flightNumber = flightNumber;
    }

    public String getAircraftRegistration() {
        return aircraftRegistration;
    }

    public void setAircraftRegistration(String aircraftRegistration) {
        this.aircraftRegistration = aircraftRegistration;
    }

    public String getClassName() {
        return className;
    }

    public void setClassName(String className) {
        this.className = className;
    }

    public int getTotalSeats() {
        return totalSeats;
    }

    public void setTotalSeats(int totalSeats) {
        this.totalSeats = totalSeats;
    }

    public int getAvailableSeats() {
        return availableSeats;
    }

    public void setAvailableSeats(int availableSeats) {
        this.availableSeats = availableSeats;
    }

    public BigDecimal getPrice() {
        return price;
    }

    public void setPrice(BigDecimal price) {
        this.price = price;
    }

    public BigDecimal getChildPrice() {
        return childPrice;
    }

    public void setChildPrice(BigDecimal childPrice) {
        this.childPrice = childPrice;
    }

    public int getAircraftClassSeatId() {
        return aircraftClassSeatId;
    }

    public void setAircraftClassSeatId(int aircraftClassSeatId) {
        this.aircraftClassSeatId = aircraftClassSeatId;
    }

    // ================== toString ==================
    @Override
    public String toString() {
        return "FlightSeatPriceDetail{" +
                "flightInstanceId=" + flightInstanceId +
                ", flightNumber='" + flightNumber + '\'' +
                ", aircraftRegistration='" + aircraftRegistration + '\'' +
                ", className='" + className + '\'' +
                ", totalSeats=" + totalSeats +
                ", availableSeats=" + availableSeats +
                ", price=" + price +
                ", childPrice=" + childPrice +
                ", aircraftClassSeatId=" + aircraftClassSeatId +
                '}';
    }
}
